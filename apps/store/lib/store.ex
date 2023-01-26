defmodule Store do
  @moduledoc """
  Contains the main business logic of the project.

  `Store` is used by the `API` phoenix app.
  """

  use Store.Model
  import Store.Utility.Randomizer
  alias Store.Utility.Security, as: Security
  alias Store.Billing
  require Logger

  # When we scale we may want to set this to true
  @send_distributed false

  defp sms_default_number do
    System.get_env("SMS_DEFAULT_NUMBER")
  end

  defp sms_default_provider do
    System.get_env("SMS_DEFAULT_PROVIDER")
  end

  ##################################
  # Employee related functions
  ##################################

  def in_roles?(employee, roles) when is_list(roles) do
    Enum.member?(roles, employee.role)
  end

  def in_role?(employee, role) when is_binary(role) do
    in_roles?(employee, [role])
  end

  def employee_member_of_location?(nil, _), do: false

  def employee_member_of_location?(employee, location_id) do
    employee.locations
    |> Enum.filter(fn l -> l.is_active end)
    |> Enum.map(fn l -> l.id end)
    |> Enum.member?(location_id)
  end

  # Caution, this method authenticates a customer from the CRM as an employee.
  # Change cautiously!
  def get_employee_by_customer_and_location(employee_customer_id, location_id) do
    employee = Employee.get_by_location_customer_id(employee_customer_id, location_id)

    is_member = employee_member_of_location?(employee, location_id)

    case is_member do
      true -> {:ok, employee}
      false -> {:error, "no_longer_part_of_shop"}
    end
  end

  def authenticate(subdomain, email, password, repo \\ Repo) do
    Employee.authenticate(subdomain, email, password, repo)
  end

  def get_employee(id) do
    Employee.get(id)
  end

  def get_employee_customer(id) do
    case Employee.me(id) do
      nil ->
        nil

      employee ->
        customer =
          case Customer.get_by_phone_unsanitized(employee.phone) do
            nil -> nil
            customer -> Map.take(customer, [:avatar, :first_name, :last_name])
          end

        Map.merge(employee, %{customer: customer})
    end
  end

  def get_employees(business_id, location_ids, options) do
    Employee.get_all(business_id, location_ids, options)
  end

  def create_employee(employee) do
    case Map.has_key?(employee, :id) do
      true ->
        # If e-mail is changing, we want to soft_delete the current employee
        # and create a new one as a copy with the new e-mail for security
        # reasons.
        case Employee.get_email_by_id(employee.id) == employee.email do
          true ->
            Employee.create(employee)

          false ->
            Employee.soft_delete(employee)

            new_employee =
              Map.take(employee, [
                :email,
                :phone,
                :role,
                :is_active,
                :locations,
                :business_id
              ])

            create_employee(new_employee)
        end

      false ->
        # Find if existing employee already exists under e-mail/business.
        {is_new, employee_changeset} =
          case Employee.get_by_email_and_business_id_bypass_deleted(
                 employee.email,
                 employee.business_id
               ) do
            # Is new employee, regular changeset.
            nil ->
              {true, Employee.changeset(%Employee{}, employee)}

            # Employee has existed before. Re-enable and re-apply changeset.
            existing_employee ->
              employee =
                Map.put(employee, :id, existing_employee.id)
                |> Map.merge(%{is_active: true, is_deleted: false})

              {false, Employee.changeset(existing_employee, employee)}
          end

        multi =
          case is_new do
            true ->
              Multi.new()
              |> Multi.insert(:employee, employee_changeset)
              |> Multi.run(:employee_reset, &create_reset/1)

            false ->
              Multi.new()
              |> Multi.update(:employee, employee_changeset)
              |> Multi.run(:employee_reset, &create_reset/1)
          end

        case Repo.transaction(multi) do
          {:ok, %{employee: employee, employee_reset: _reset}} ->
            {:ok, employee}

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            {:error, failed_value}
        end
    end
  end

  def delete_employee_expired_resets() do
    case EmployeeReset.delete_expired() do
      nil -> {:ok, []}
      {num_affected, _} -> {:ok, num_affected}
    end
  end

  def delete_customer_expired_resets() do
    case CustomerReset.delete_expired() do
      nil -> {:ok, []}
      {num_affected, _} -> {:ok, num_affected}
    end
  end

  def delete_admin_employee_expired_resets() do
    case AdminEmployeeReset.delete_expired() do
      nil -> {:ok, []}
      {num_affected, _} -> {:ok, num_affected}
    end
  end

  def delete_expired_authorization_tokens() do
    case AuthorizationToken.delete_expired() do
      nil -> {:ok, []}
      {num_affected, _} -> {:ok, num_affected}
    end
  end

  def employee_reset(email, subdomain) do
    case Business.get_by_subdomain(subdomain) do
      nil ->
        {:error, "Business with subdomain not found"}

      business ->
        case Employee.get_by_email_and_business_id(email, business.id) do
          nil -> {:error, "Employee record not found"}
          employee -> create_reset(business, employee)
        end
    end
  end

  def get_employee_reset(id) do
    EmployeeReset.get(id)
  end

  def set_employee_password(id, password, ip_address \\ "") do
    case Security.check_password_strength(password) do
      {:error, message} ->
        {:error, message}

      {:ok, %{score: score, message: message}} ->
        reset = EmployeeReset.get(id)

        multi =
          Multi.new()
          |> Multi.update(
            :employee,
            Employee.password_reset_changeset(reset.business_id, reset.email, password)
          )
          |> Multi.update(:employee_reset, EmployeeReset.used_changeset(id, ip_address))

        case Repo.transaction(multi) do
          {:ok, %{employee: _employee, employee_reset: _reset}} ->
            {:ok, %{email: reset.email, strength: %{score: score, message: message}}}

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            {:error, failed_value}
        end
    end
  end

  defp create_reset(result) do
    employee = result.employee
    business = Business.get(employee.business_id)
    create_reset(business, employee)
  end

  defp create_reset(business, employee) do
    reset = %{
      business_id: business.id,
      employee_id: employee.id,
      subdomain: business.subdomain,
      email: employee.email,
      sent: false,
      used: false
    }

    case EmployeeReset.create(reset) do
      {:ok, employee_reset} ->
        send_reset_email(employee_reset)
        {:ok, employee_reset}

      {:error, error} ->
        {:error, error}
    end
  end

  defp send_reset_email(employee_reset) do
    # @TODO: Note: this hoists the execution context outside
    # of the regular runtime execution as the EmployeeReset.create above wasn't
    # actually inserting the record before the update in the mark_as_sent below
    # was executing which is total bonkers. All background processing for async
    # actions will happen via genserver kafka consumers anyhow!
    # Task.start(fn ->
    employee_reset
    |> EmployeeEmail.password_reset_email()
    |> Store.Mailer.deliver()
    |> mark_as_sent(employee_reset.id)

    # end)
  end

  defp mark_as_sent(result, id) do
    case result do
      {:ok, _result} -> EmployeeReset.sent(id)
      {:error, error} -> {:error, error}
    end
  end

  def get_admin_user_from_token(guid) do
    case AuthorizationToken.digest_login_token(guid) do
      nil -> {:error, "Token not found, expired, or has already been used."}
      %{business_id: business_id} -> Employee.get_business_admin(business_id)
    end
  end

  def send_customer_export_email(business, employee, type) do
    token = AuthorizationToken.generate_customer_export_token(business.id, type)
    email = EmployeeEmail.customer_export_email(business, employee, token)
    Store.Mailer.deliver(email)
    {:ok, %{success: true}}
  end

  def use_customer_export_token(token) do
    AuthorizationToken.digest_customer_export_token(token)
  end

  def log_customer_export(ip_address, type, employee_id) do
    CustomerExportLog.create(%{
      ip_address: ip_address,
      type: type,
      employee_id: employee_id
    })
  end

  ##################################
  # Business related functions
  ##################################

  def get_business(id) do
    Business.get(id)
  end

  defp get_business_by_subdomain(subdomain) do
    case Business.get_by_subdomain(subdomain) do
      nil -> {:error, "Business not found by subdomain #{subdomain}"}
      business -> {:ok, business}
    end
  end

  defp set_business_country_if_first_location(id, country) do
    with [] <- Location.get_by_business(id),
         {:ok, business} <- set_business_country(id, country) do
      {:ok, business}
    else
      _err -> {:ok, :noop}
    end
  end

  defp set_business_country(id, country) do
    country_scrubbed =
      case country do
        "United States" -> "USA"
        result -> result
      end

    Business
    |> Repo.get(id)
    |> change(%{country: country_scrubbed})
    |> Repo.update()
  end

  ##################################
  # CRM - Location related functions
  ##################################

  def get_location(id, business_id) do
    Location.get_by_business_id(id, business_id)
  end

  def get_locations_by_no_product_count(employee) do
    Location.get_locations_by_no_product_count(employee)
  end

  def get_locations_for_employee(employee) do
    Location.get_valid_employee_locations(employee)
  end

  def get_locations(business_id, location_ids, options) do
    Location.get_all(business_id, location_ids, options)
  end

  def get_locations(business_id, options) do
    Location.get_all(business_id, options)
  end

  def get_locations(options) do
    Location.get_all(options)
  end

  def get_location_reviews(business_id, location_ids, options) do
    Review.get_all(business_id, location_ids, options)
  end

  def get_location_reviews(location_id, customer_id) do
    {:ok, Review.get_all(location_id, customer_id)}
  end

  def create_store(location) do
    location = Store.Geo.set_point(location)
    location = Store.Geo.set_polygon(location)
    location = Store.Geo.set_timezone(location)

    set_business_country_if_first_location(location.business_id, location.country)

    has_sms_settings = Map.has_key?(location, :sms_settings)

    sms_settings =
      case has_sms_settings do
        true -> location.sms_settings
        false -> %{phone_number: "0000000000000"}
      end

    # check tfn and fail out if it's already been assigned to another business!
    case SMSSetting.in_use?(sms_settings.phone_number, location.business_id) do
      true ->
        {:error, "toll_free_number_already_in_use"}

      false ->
        case Map.has_key?(location, :id) do
          true ->
            multi =
              Multi.new()
              |> Multi.run(:location, fn _ -> Location.create(location) end)
              |> Multi.run(:alias, fn _ ->
                if has_sms_settings do
                  {:ok,
                   Store.Messaging.SMS.set_alias(
                     location.sms_settings.provider,
                     location.sms_settings.phone_number,
                     location.name
                   )}
                else
                  {:ok, :noop}
                end
              end)

            case Repo.transaction(multi) do
              {:ok, %{location: location}} ->
                {:ok, location}

              {:error, _failed_operation, failed_value, _changes_so_far} ->
                {:error, failed_value}
            end

          false ->
            location_changeset = Location.changeset(%Location{}, location)

            multi =
              Multi.new()
              |> Multi.insert(:location, location_changeset)
              |> Multi.run(:profile, &Store.Billing.create_profile/1)
              |> Multi.run(:rewards, &Store.Loyalty.generate_rewards/1)
              |> Multi.run(:alias, fn _ ->
                if has_sms_settings do
                  {:ok,
                   Store.Messaging.SMS.set_alias(
                     location.sms_settings.provider,
                     location.sms_settings.phone_number,
                     location.name
                   )}
                else
                  {:ok, :noop}
                end
              end)

            case Repo.transaction(multi) do
              {:ok, %{location: location}} ->
                {:ok, location}

              {:error, _failed_operation, failed_value, _changes_so_far} ->
                {:error, failed_value}
            end
        end
    end
  end

  ##################################
  # Mobile Client - Location related functions
  ##################################

  def create_review(review, customer) do
    multi =
      Multi.new()
      |> Multi.run(:review_is_complete, fn _ ->
        {:ok, Review.is_complete?(review)}
      end)
      |> Multi.run(:get_reward, fn %{review_is_complete: is_complete} ->
        case is_complete do
          true -> {:ok, nil}
          false -> {:ok, Reward.get_by_location_and_type(review.location_id, "review")}
        end
      end)
      |> Multi.run(:create_review_reward, fn %{get_reward: reward} ->
        case reward do
          nil ->
            {:ok, nil}

          _ ->
            case Store.Loyalty.create_customer_reward(customer.id, reward.id) do
              {:ok, customer_reward} -> {:ok, Map.put(customer_reward, :reward, reward)}
              _ -> {:error, "Error creating customer reward."}
            end
        end
      end)
      |> Multi.run(:save_review, fn _ ->
        case save_review(review, customer) do
          {:ok, result} -> {:ok, result}
          {:error, error} -> {:error, error}
        end
      end)
      |> Multi.run(:notify, fn %{review_is_complete: is_complete, save_review: review} ->
        case is_complete do
          true ->
            Store.Notify.customer_updated_review(customer.id, review.location_id, review.id)
            {:ok, true}

          false ->
            Store.Notify.customer_created_review(customer.id, review.location_id, review.id)
            {:ok, true}
        end
      end)

    case Repo.transaction(multi) do
      {:ok, %{create_review_reward: customer_reward, save_review: review}} ->
        {:ok, %{success: true, customer_reward: customer_reward, review: review}}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp save_review(review, customer) do
    review
    |> Map.put(:customer_id, customer.id)
    |> Map.put(:completed, true)
    |> Review.create()
  end

  def get_customer_review(customer_id, location_id) do
    Review.get_review_by_customer_and_location(customer_id, location_id)
  end

  def visit(customer_id, lat, lng) do
    point = %Geo.Point{coordinates: {lng, lat}, srid: 4326}

    with {:ok, locations} <- Location.find_intersection(lat, lng),
         {:ok, result} <- create_visit_location(customer_id, locations, point) do
      {:ok, result}
    else
      _err -> {:error, %{success: false, id: nil}}
    end
  end

  defp create_visit_location(customer_id, locations, point) do
    case List.first(locations) do
      nil ->
        {:ok, %{success: false, id: nil}}

      location ->
        case Visit.last_hour_count(customer_id, location.id) do
          0 ->
            case Visit.create(%{customer_id: customer_id, location_id: location.id, point: point}) do
              {:ok, _visit} -> {:ok, %{success: true, id: location.id}}
              {:error, _err} -> {:ok, %{success: false, id: nil}}
            end

          _count ->
            {:ok, %{success: true, id: location.id}}
        end
    end
  end

  def discover_locations(_customer_id, options) do
    # we could log the request for the customer and id if we wanted to
    Location.discover(options)
  end

  def get_store_page(customer_id, location_id) do
    with {:ok, location} <- Location.get_store_page(location_id) do
      location = exclude_redemptions_by_location(customer_id, location)
      is_member = has_joined_shop?(customer_id, location_id)
      customer_has_earned_stamp = Transaction.customer_has_earned_stamp(customer_id, location_id)

      location =
        location
        |> Map.put(:is_member, is_member)
        |> Map.put(:customer_has_earned_stamp, customer_has_earned_stamp)

      {:ok, location}
    else
      err -> err
    end
  end

  defp exclude_redemptions_by_location(customer_id, location) do
    with {:ok, deals_to_exclude} <- CustomerDeal.redeemed_at_location(customer_id, location.id),
         {:ok, rewards_to_exclude} <-
           CustomerReward.single_use_rewards_by_location(customer_id, location.id) do
      filtered_deals =
        Enum.filter(location.deals, fn deal ->
          Enum.member?(deals_to_exclude, deal.id) == false
        end)

      filtered_rewards =
        Enum.filter(location.rewards, fn reward ->
          Enum.member?(rewards_to_exclude, reward.id) == false
        end)

      location = Map.put(location, :deals, filtered_deals)
      Map.put(location, :rewards, filtered_rewards)
    else
      _ -> location
    end
  end

  def customer_feedback(customer_id, feedback) do
    customer_feedback = %{customer_id: customer_id, feedback: feedback}

    with customer <- Customer.get(customer_id),
         {:ok, customer_feedback} <- CustomerFeedback.create(customer_feedback),
         {:ok, _} <- CustomerEmail.feedback(customer, feedback) do
      {:ok, customer_feedback}
    else
      err -> err
    end
  end

  def notify(customer_id, lat, lon) do
    %{
      customer_id: customer_id,
      sent: false,
      point: %Geo.Point{coordinates: {lat, lon}, srid: 4326}
    }
    |> CustomerNotify.create()
  end

  def crm_opt_in(customer, location_id) do
    with {:ok, customer} <- get_or_create_customer(customer),
         {:ok, _joined} <- join_shop(customer.id, location_id) do
      {:ok, customer}
    else
      err -> err
    end
  end

  def opt_in(subdomain, tablet, customer) do
    with {:ok, business} <- get_biz_by_subdomain(subdomain),
         {:ok, location} <- get_location_by_tablet(business.id, tablet),
         {:ok, customer} <- get_or_create_customer(customer),
         {:ok, _joined} <- join_shop(customer.id, location.id),
         {:ok, _optlog} <- opt_log(customer.id, location.id, true, "join") do
      {:ok, %{success: true}}
    else
      err -> err
    end
  end

  def widget_opt_in(customer, location_id) do
    with {:ok, customer} <- get_or_create_customer(customer),
         {:ok, result} <- join_shop(customer.id, location_id) do
      {:ok, %{joined: result.location_joined}}
    else
      err -> err
    end
  end

  defp get_sms_settings(location_id) do
    case SMSSetting.get_by_location(location_id) do
      nil -> {:error, "SMS settings not found for location"}
      settings -> {:ok, settings}
    end
  end

  def location_tablets(subdomain) do
    with {:ok, business} <- get_biz_by_subdomain(subdomain),
         {:ok, locations} <- get_locations_by_business_id(business.id) do
      {:ok, locations}
    else
      err -> err
    end
  end

  defp get_locations_by_business_id(id) do
    case Location.get_by_business_id(id) do
      {:error, error} -> {:error, error}
      locations -> {:ok, locations}
    end
  end

  defp get_or_create_customer(customer) do
    case Customer.get_by_phone_or_email(customer.phone, "") do
      nil ->
        # send sms message
        send_download_sms(customer.phone)
        Customer.create(customer)

      customer ->
        {:ok, customer}
    end
  end

  defp send_download_sms(customer_phone) do
    sms_settings = %{
      provider: sms_default_provider(),
      phone_number: sms_default_number(),
      send_distributed: @send_distributed
    }

    msg = "To unlock rewards download the app:\r\n\r\n http://yourdomain.com"
    # msg = msg <> "\r\n\r\n\r\nReply STOP to opt out."
    case Application.get_env(:store, :environment) do
      :dev -> send_download_sms_email(msg)
      _ -> SMS.send(customer_phone, msg, sms_settings)
    end
  end

  defp send_download_sms_email(msg) do
    msg
    |> CustomerEmail.send_download_sms_email()
    |> Store.Mailer.deliver()
  end

  def shop_opt(subdomain, tablet) do
    with {:ok, business} <- get_biz_by_subdomain(subdomain),
         {:ok, location} <- get_location_by_tablet(business.id, tablet) do
      {:ok,
       %{
         shop_name: location.name,
         background_color: location.tablet_background_color,
         background_image: location.tablet_background_image,
         foreground_color: location.tablet_foreground_color
       }}
    else
      err -> err
    end
  end

  def locations_by_phone(phone) do
    case SMSSetting.get_by_phone(phone) do
      [] -> []
      settings -> {:ok, Enum.map(settings, fn s -> s.location_id end)}
    end
  end

  def tablet_is_member(subdomain, tablet, phone) do
    with {:ok, business} <- get_biz_by_subdomain(subdomain),
         {:ok, customer} <- get_customer_by_phone(phone),
         {:ok, location} <- get_location_by_tablet(business.id, tablet),
         {:ok, membership} <- get_membership_by_business_and_customer(business.id, customer.id) do
      {:ok, %{business: business, customer: customer, location: location, membership: membership}}
    else
      err -> err
    end
  end

  defp get_biz_by_subdomain(subdomain) do
    case Business.get_by_subdomain(subdomain) do
      nil -> {:error, "Business with subdomain not found"}
      business -> {:ok, business}
    end
  end

  def get_customer_by_phone(phone) do
    case Customer.get_by_phone_or_email(phone, "") do
      nil -> {:error, "Customer with phone not found"}
      customer -> {:ok, customer}
    end
  end

  defp get_location_by_tablet(business_id, tablet) do
    case Location.get_by_tablet(business_id, tablet) do
      nil -> {:error, "Location with tablet not found"}
      location -> {:ok, location}
    end
  end

  defp get_membership_by_business_and_customer(business_id, customer_id) do
    case Membership.get_by_customer_and_business(customer_id, business_id) do
      nil -> {:error, "Membership not found"}
      membership -> {:ok, membership}
    end
  end

  def memberships(customer_id) do
    case Membership.get_by_customer(customer_id) do
      {:error, _} ->
        {:error, "Cannot get membership for customer"}

      {:ok, []} ->
        {:ok, []}

      {:ok, memberships} ->
        memberships = map_customer_deals_and_rewards_to_memberships(customer_id, memberships)
        {:ok, memberships}
    end
  end

  defp map_customer_deals_and_rewards_to_memberships(customer_id, memberships) do
    memberships
    |> exclude_redemptions(customer_id)
    |> map_deals(customer_id)
    |> map_rewards(customer_id)
  end

  defp exclude_redemptions(memberships, customer_id) do
    with {:ok, deals_to_exclude} <- CustomerDeal.redeemed_by_customer(customer_id),
         {:ok, rewards_to_exclude} <- CustomerReward.single_use_rewards(customer_id) do
      Enum.map(memberships, fn membership ->
        locations =
          Enum.map(membership.locations, fn location ->
            filtered_deals =
              Enum.filter(location.deals, fn deal ->
                Enum.member?(deals_to_exclude, deal.id) == false
              end)

            filtered_rewards =
              Enum.filter(location.rewards, fn reward ->
                Enum.member?(rewards_to_exclude, reward.id) == false
              end)

            location = Map.put(location, :deals, filtered_deals)
            Map.put(location, :rewards, filtered_rewards)
          end)

        Map.put(membership, :locations, locations)
      end)
    else
      _ -> memberships
    end
  end

  defp map_deals(memberships, customer_id) do
    customer_deals = CustomerDeal.get_deals(customer_id) || []

    memberships
    |> Enum.map(fn m ->
      deals =
        Enum.flat_map(m.locations, fn l ->
          Enum.filter(customer_deals, fn d -> d.location_id == l.id end)
        end)

      Map.put(m, :customer_deals, deals || [])
    end)
  end

  defp map_rewards(memberships, customer_id) do
    customer_rewards = CustomerReward.get_rewards(customer_id) || []

    memberships
    |> Enum.map(fn m ->
      rewards =
        Enum.flat_map(m.locations, fn l ->
          Enum.filter(customer_rewards, fn r -> r.location_id == l.id end)
        end)

      Map.put(m, :customer_rewards, rewards || [])
    end)
  end

  def get_qr_code(location_id) do
    Location.get_qr_code(location_id)
  end

  def set_qr_code(location_id) do
    Location.set_qr_code(location_id)
  end

  ########################################################
  # Mobile Client - Member and loyalty related functions
  ########################################################

  def join_shop(customer_id, location_id, offer_reward \\ true, _notify_employees \\ false) do
    location = Location.get(location_id)
    customer = Customer.get(customer_id)
    business_id = location.business_id

    case Membership.get_by_customer_and_business(customer_id, business_id) do
      nil ->
        membership = %{customer_id: customer_id, business_id: business_id}
        membership_changeset = Membership.changeset(%Membership{}, membership)

        member_multi =
          Multi.new()
          |> Multi.insert(:membership, membership_changeset)

        location_multi = membership_location_multi(location_id)
        reward_multi = customer_reward_multi(customer_id, location_id, offer_reward)

        member_and_location_multi = Multi.append(member_multi, location_multi)
        multi = Multi.append(member_and_location_multi, reward_multi)

        case Repo.transaction(multi) do
          {:ok,
           %{
             membership: _,
             membership_location: location_joined,
             reward: _,
             customer_reward: customer_reward
           }} ->
            if location_joined do
              send_welcome_sms(location.id, location.name, customer.phone)
              opt_log(customer_id, location_id, true, "join")
              Store.Notify.notify_customer_joined_shop(customer_id, location_id)
            end

            {:ok,
             %{
               success: true,
               customer_reward: customer_reward,
               location_joined: location_joined
             }}

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            {:error, failed_value}
        end

      membership ->
        member_multi =
          Multi.new()
          |> Multi.run(:membership, fn _ -> {:ok, membership} end)

        location_multi = membership_location_multi(location_id)
        reward_multi = customer_reward_multi(customer_id, location_id, offer_reward)

        member_and_location_multi = Multi.append(member_multi, location_multi)
        multi = Multi.append(member_and_location_multi, reward_multi)

        case Repo.transaction(multi) do
          {:ok,
           %{
             membership_location: location_joined,
             reward: _,
             customer_reward: customer_reward
           }} ->
            if location_joined do
              send_welcome_sms(location.id, location.name, customer.phone)
              opt_log(customer_id, location_id, true, "join")
              Store.Notify.notify_customer_joined_shop(customer_id, location_id)
            end

            {:ok,
             %{
               success: true,
               customer_reward: customer_reward,
               location_joined: location_joined
             }}

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            {:error, failed_value}
        end
    end
  end

  def create_referral(phone, cipher) do
    with {:ok, link} <- ReferralLink.get_link(cipher),
         {:ok} <- isnt_already_a_member(phone, link.location_id),
         {:ok, referral} <- build_referral(phone, link),
         {:ok} <- check_already_redeemed(phone, link),
         _ <- Referral.create(referral) do
      {:ok, referral}
    else
      err -> err
    end
  end

  defp isnt_already_a_member(phone, location_id) do
    case Customer.get_by_phone(phone) do
      {:ok, customer} ->
        case MembershipLocation.get_by_customer_and_location(customer.id, location_id) do
          nil -> {:ok}
          _ -> {:error, "Phone number is already a member of this shop"}
        end

      _ ->
        {:ok}
    end
  end

  defp check_already_redeemed(phone, link) do
    case Referral.has_completed?(phone, link.location_id) do
      true -> {:error, "Referral has already been redeemed for this location"}
      false -> {:ok}
    end
  end

  defp build_referral(phone, link) do
    referral = %{
      recipient_phone: phone,
      is_completed: false,
      business_id: link.location.business_id,
      location_id: link.location.id,
      from_customer_id: link.customer_id,
      to_customer_id: nil
    }

    {:ok, referral}
  end

  def latest_referral(customer_id) do
    with {:ok, customer} <- get_customer_by_id(customer_id),
         {:ok, referral} <- get_referral_by_phone(customer.phone),
         {:ok, location} <- get_location(referral.location_id) do
      {:ok, %{id: location.id, name: location.name}}
    else
      err -> err
    end
  end

  defp get_location(id) do
    case Location.get(id) do
      nil -> {:error, "Location with id not found"}
      location -> {:ok, location}
    end
  end

  def get_location_loyalty_reward(location_id) do
    case Reward.get_by_location_and_type(location_id, "loyalty") do
      nil -> {:error, "reward_not_found_or_is_inactive"}
      reward -> {:ok, reward}
    end
  end

  defp get_customer_by_id(customer_id) do
    case Customer.get(customer_id) do
      nil -> {:error, "Customer with id not found"}
      customer -> {:ok, customer}
    end
  end

  defp get_referral_by_phone(phone) do
    case Referral.get_not_completed_by_phone(phone) do
      nil -> {:error, "No referrals found"}
      referral -> {:ok, referral}
    end
  end

  defp referral_multi(customer_id, location_id) do
    location = Location.get(location_id)

    Multi.new()
    |> Multi.run(:referral_reward, fn _ ->
      case Customer.get(customer_id) do
        nil ->
          {:ok, "Carry on"}

        customer ->
          case Referral.get(customer.phone, location.id) do
            nil ->
              {:ok, "Carry on"}

            referral ->
              # award a referral reward to the customer who referred it
              # and mark this referral as complete
              with {:ok, referral_reward} <- Reward.get_by_location(location.id, "referral"),
                   {:ok, customer_reward} <-
                     Store.Loyalty.create_referral_reward(
                       referral.from_customer_id,
                       referral_reward.id
                     ),
                   {:ok, updated_referral} <- Referral.mark_as_completed(referral.id, customer_id) do
                fcm_push(
                  [referral.from_customer_id],
                  "You've earned your referral reward! Your friend just joined #{location.name}. Check your rewards to see your coupon for #{
                    customer_reward.name
                  }.",
                  "Congratulations!",
                  %{id: "REFERRAL_REWARD_NOTIF_ID", location_id: location.id}
                )

                {:ok, updated_referral}
              else
                err -> err
              end
          end
      end
    end)
  end

  defp membership_location_multi(location_id) do
    Multi.new()
    |> Multi.run(:membership_location, fn %{membership: membership} ->
      case MembershipLocation.get(membership.id, location_id) do
        nil ->
          record = %{
            membership_id: membership.id,
            location_id: location_id,
            is_active: true,
            notifications_enabled: true
          }

          case MembershipLocation.create(record) do
            {:error, error} -> {:error, error}
            {:ok, _} -> {:ok, true}
          end

        _ ->
          case MembershipLocation.set_active(membership.id, location_id) do
            {:error, error} -> {:error, error}
            # membership location already exists so we don't want a reward created
            {:ok, _} -> {:ok, false}
          end
      end
    end)
  end

  defp customer_reward_multi(customer_id, location_id, offer_reward) do
    if offer_reward == false do
      Multi.new()
      |> Multi.run(:reward, fn _results -> {:ok, %{id: nil}} end)
      |> Multi.run(:customer_reward, fn _results -> {:ok, nil} end)
    else
      Multi.new()
      |> Multi.run(:reward, fn results ->
        is_new_membership_location = results[:membership_location]

        if is_new_membership_location do
          get_reward(location_id, "first_time")
        else
          # slightly hackish to prevent rewards from being created on existing membership locations
          {:ok, %{id: nil}}
        end
      end)
      |> Multi.run(:customer_reward, fn results ->
        reward = results[:reward]

        case reward.id do
          # it's ok if a first-time reward is not active and rewarded
          nil -> {:ok, nil}
          reward_id -> Store.Loyalty.create_customer_reward(customer_id, reward_id)
        end
      end)
    end
  end

  defp get_reward(location_id, type) do
    case Reward.get_by_location_and_type(location_id, type) do
      # we want the multi transaction to succeed
      nil -> {:ok, %{id: nil}}
      reward -> {:ok, %{id: reward.id}}
    end
  end

  def leave_shop(customer_id, location_id) do
    case MembershipLocation.get_by_customer_and_location(customer_id, location_id) do
      nil ->
        {:error, "Customer not joined to shop"}

      membership ->
        MembershipLocation.set_inactive(membership.id, location_id)
        {:ok, %{success: true, id: membership.id}}
    end
  end

  def set_location_notifications(customer_id, location_id, is_enabled) do
    case MembershipLocation.get_by_customer_and_location(customer_id, location_id) do
      nil ->
        {:error, "Customer not joined to shop"}

      membership ->
        MembershipLocation.set_location_notifications(membership.id, location_id, is_enabled)
        opt_log(customer_id, location_id, is_enabled, "location-toggle")
        {:ok, %{success: true, id: membership.id}}
    end
  end

  defp opt_log(customer_id, location_id, opted_in, source) do
    %{
      customer_id: customer_id,
      location_id: location_id,
      opted_in: opted_in,
      source: source
    }
    |> OptLog.create()
  end

  # @TODO note: update points schema to add deal_id, and location_id
  # points will be an aggregate

  def is_a_member_of_business?(customer_id, business_id) do
    case Membership.get_by_customer_and_business(customer_id, business_id) do
      nil -> false
      {:ok, _} -> true
    end
  end

  def has_joined_shop?(customer_id, location_id) do
    case MembershipLocation.get_by_customer_and_location(customer_id, location_id) do
      nil ->
        false

      membership ->
        MembershipLocation.is_active?(membership.id, location_id)
    end
  end

  ##################################
  # Customer related functions
  ##################################

  defp build_notification(tokens, msg, title, data) do
    arg = %{
      "body" => msg,
      "sound" => "default"
    }

    arg =
      case title do
        nil -> arg
        val -> Map.put(arg, :title, val)
      end

    case data do
      nil -> Pigeon.FCM.Notification.new(tokens, arg)
      _ -> Pigeon.FCM.Notification.new(tokens, arg, data)
    end
  end

  def fcm_push(customers, msg, title \\ nil, data \\ nil) do
    tokens = Customer.get_fcm_tokens(customers)

    case tokens do
      [] -> nil
      t -> fcm_raw_push(t, msg, title, data)
    end
  end

  def fcm_raw_push(tokens, msg, title \\ nil, data \\ nil) do
    Pigeon.FCM.push(build_notification(tokens, msg, title, data),
      on_response: fn x ->
        Logger.info("FCM Push Notification Result", event: %{data: x})
      end
    )

    {:ok, %{success: true}}
  end

  def import_customers(import_data) do
    with {:ok, customer_import} <- CustomerImport.create(import_data),
         {:ok, results} <- create_customers(import_data.customers),
         {:ok, customers_to_sms} <-
           join_shops(results, import_data.location_id, import_data.offer_reward),
         {:ok, _sms_results} <- send_import_sms(customer_import, customers_to_sms) do
      {:ok, %{id: customer_import.id, results: results}}
    else
      err -> err
    end
  end

  def import_results(id) do
    {:ok, SMSLog.get_by_entity(id)}
  end

  defp create_customers(customers) do
    results =
      customers
      |> Enum.map(fn customer ->
        [first_name, last_name, phone, email] = String.split(customer, ",")
        new_customer = %{first_name: first_name, last_name: last_name, phone: phone, email: email}

        case Customer.create(new_customer) do
          {:ok, customer} ->
            ZZZ.Referrals.log(phone)
            {:ok, customer}

          {:error, _error} ->
            {:error, Customer.get_by_phone_unsanitized(phone)}
        end
      end)

    imported = Enum.filter(results, fn {status, _result} -> status == :ok end)
    failed = Enum.filter(results, fn {status, _result} -> status == :error end)

    imported = Enum.map(imported, fn {_status, result} -> result end)
    failed = Enum.map(failed, fn {_status, result} -> result end)
    {:ok, %{imported: imported, failed: failed}}
  end

  defp join_shops(customers, location_id, offer_reward) do
    all_customers = customers.imported ++ customers.failed

    joined_results =
      Enum.map(all_customers, fn customer ->
        {:ok, result} = join_shop(customer.id, location_id, offer_reward)

        if result.location_joined == true do
          {:ok, customer}
        else
          {:error, "shop is already joined"}
        end
      end)

    customers_to_sms =
      Enum.filter(joined_results, fn {status, _c} -> status == :ok end)
      |> Enum.map(fn {_status, customer} -> customer end)
      |> Enum.concat(customers.imported)
      |> Enum.uniq()

    {:ok, customers_to_sms}
  end

  defp send_import_sms(customer_import, customers) do
    %{id: id, send_sms: send_sms, message: message, location_id: location_id} = customer_import
    {:ok, sms_settings} = get_sms_settings(location_id)

    if send_sms == true and message != "" do
      Task.start(fn ->
        Enum.each(customers, fn customer ->
          SMS.send_import_sms(id, customer, location_id, message, sms_settings)
        end)
      end)

      {:ok, true}
    else
      {:ok, nil}
    end
  end

  def customer_locations(business_id, customer_id) do
    case MembershipLocation.get_by_customer(business_id, customer_id) do
      locations -> {:ok, locations}
    end
  end

  def customer_reset(phone) do
    # @TODO - hack to simply not send a reset code for the fake customer
    if phone == "11112223333" do
      {:ok, true}
    else
      reset = %{
        phone: phone,
        code: get_random_unused_reset_code(),
        sent: false,
        received: false,
        used: false
      }

      case CustomerReset.create(reset) do
        {:ok, customer_reset} ->
          case Application.get_env(:store, :environment) do
            :dev -> send_customer_reset_email(customer_reset)
            _ -> send_customer_reset_sms(customer_reset)
          end

          {:ok, customer_reset}

        {:error, error} ->
          {:error, error}
      end
    end
  end

  def customer_exists(phone, email) do
    case Customer.get_by_phone_or_email(phone, email) do
      nil -> nil
      customer -> {:ok, customer}
    end
  end

  def create_account(phone, code, email) do
    customer = %{phone: phone, code: code, email: email}

    with {:ok, reset} <- validate_reset_phone_and_code(phone, code),
         {:ok, customer} <- Customer.create_sanitized(customer),
         {:ok, _send_sms} <- send_sms_if_referral_exists(phone) do
      # this deletes the CustomerReset record
      CustomerReset.used(reset.id)
      ZZZ.Referrals.log(phone)
      {:ok, customer}
    else
      err -> err
    end
  end

  # @TODO - change this to a notification service message after login
  # instead in the future rather than an SMS message
  def send_sms_if_referral_exists(phone) do
    case Referral.get_by_phone(phone) do
      nil ->
        {:ok, "No referral sms required"}

      referral ->
        cipher = ReferralLink.generate_location_hash(referral.location_id)
        intent = get_intent_base() <> "/s/#{cipher}"

        msg =
          "You’re almost there! Please launch Acme and join #{referral.location.name} to claim your reward. Please click the link to proceed #{
            intent
          }"

        sms_settings = %{
          provider: sms_default_provider(),
          phone_number: sms_default_number(),
          send_distributed: @send_distributed
        }

        case Application.get_env(:store, :environment) do
          :dev -> send_referral_sms_email(msg)
          _ -> SMS.send(phone, msg, sms_settings)
        end
    end
  end

  def get_intent_base() do
    "https://app.yourdomain.com/i"
  end

  defp send_referral_sms_email(msg) do
    msg
    |> CustomerEmail.send_referral_sms_email()
    |> Store.Mailer.deliver()
  end

  def update_customer(customer, confirmation \\ false) do
    case Map.get(customer, :categories) do
      nil -> Customer.create(customer)
      _ -> validate_categories_and_create_customer(customer, confirmation)
    end
  end

  defp validate_categories_and_create_customer(customer, confirmation) do
    case customer.id do
      nil ->
        Customer.create(customer)

      _ ->
        fav_category_ids = Category.get_customer_favourites(customer.id)
        removed_categories = fav_category_ids -- customer.categories

        case length(removed_categories) do
          0 ->
            Customer.create(customer)

          _ ->
            customer_product_ids =
              CustomerProduct.get_customer_product_ids_by_categories(
                customer.id,
                removed_categories
              )

            case length(customer_product_ids) do
              0 ->
                Customer.create(customer)

              len ->
                case confirmation do
                  true ->
                    CustomerProduct.unfavourite_product_ids_for_customer(
                      customer.id,
                      customer_product_ids
                    )

                    Customer.create(customer)

                  false ->
                    {:error, "customer_fav_products_in_category:#{len}"}
                end
            end
        end
    end
  end

  def sign_in(phone, code) do
    # @TODO - hack to simply return the phone # for the fake code
    if phone == "11112223333" and code == "1234567" do
      Customer.get_by_phone(phone)
    else
      with {:ok, reset} <- validate_reset_phone_and_code(phone, code),
           {:ok, customer} <- Customer.get_by_phone(reset.phone) do
        # this deletes the CustomerReset record
        CustomerReset.used(reset.id)
        {:ok, customer}
      else
        err -> err
      end
    end
  end

  def get_customer(id) do
    Customer.get(id)
  end

  # Mobile Endpoint to get user profile.
  def get_customer_profile(id) do
    Customer.get_profile(id)
  end

  # CRM Endpoint to get customer details view.
  def get_customer_details(id, location_id) do
    case Customer.get_details(id, location_id) do
      nil -> {:error, "customer_not_found"}
      customer -> {:ok, customer}
    end
  end

  def toggle_opted_and_notifications(location_ids, customer_id, is_enabled, type) do
    with {_records, _result} <-
           MembershipLocation.opted_in_or_out(customer_id, location_ids, is_enabled),
         {:ok, _logs} <- insert_opt_logs(location_ids, customer_id, is_enabled, type) do
      {:ok, %{success: true}}
    else
      err -> err
    end
  end

  def toggle_customer_notifications(location_ids, customer_id, is_enabled, type) do
    with {_records, _result} <-
           MembershipLocation.toggle_notifications_by_location_ids(
             customer_id,
             location_ids,
             is_enabled
           ),
         {:ok, _logs} <- insert_opt_logs(location_ids, customer_id, is_enabled, type) do
      {:ok, %{success: true}}
    else
      err -> err
    end
  end

  def toggle_customer_location_notifications(
        business_id,
        location_id,
        customer_id,
        is_enabled,
        type
      ) do
    with {:ok, membership} <- get_membership(business_id, customer_id),
         {_records, _result} <-
           MembershipLocation.toggle_notifications(membership.id, location_id, is_enabled),
         {:ok, _logs} <- opt_log(customer_id, location_id, is_enabled, type) do
      {:ok, %{success: true}}
    else
      err -> err
    end
  end

  def disable_sms_notifications_for_campaign_error_code(location_id, campaign_id, error_code) do
    SMSLog.get_logs_for_campaign_by_error_code(location_id, campaign_id, error_code)
    |> Enum.map(fn r ->
      toggle_customer_notifications([location_id], r.customer_id, false, "crm-campaign-result")
    end)

    {:ok, %{success: true}}
  end

  defp insert_opt_logs(location_ids, customer_id, opted_in, type) do
    location_ids
    |> Enum.map(fn location_id ->
      opt_log(customer_id, location_id, opted_in, type)
    end)

    {:ok, true}
  end

  defp get_membership(business_id, customer_id) do
    case Membership.get_by_customer_and_business(customer_id, business_id) do
      nil -> {:error, "membership not found"}
      membership -> {:ok, membership}
    end
  end

  # used in the guardian serializer
  def get_customer_sanitized(id) do
    Customer.get_sanitized(id)
  end

  def get_customer_by_facebook_id(facebook_id) do
    case Customer.get_by_facebook_id(facebook_id) do
      {:error, message} -> {:error, message}
      {:ok, customer} -> {:ok, customer}
    end
  end

  defp send_welcome_sms(location_id, location_name, customer_phone) do
    case get_sms_settings(location_id) do
      {:ok, sms_settings} ->
        msg =
          "Welcome to #{location_name}. You have opted in for our text message updates. You can configure notifications in the Acme app in your Profile under Notifications."

        msg = msg <> "\r\n\r\n\r\nReply STOP to opt out."

        case Application.get_env(:store, :environment) do
          :dev -> send_welcome_sms_email(msg)
          _ -> SMS.send(customer_phone, msg, sms_settings)
        end

      _ ->
        :noop
    end
  end

  defp send_welcome_sms_email(msg) do
    msg
    |> CustomerEmail.send_welcome_sms_email()
    |> Store.Mailer.deliver()
  end

  def facebook_auth_and_verify(token) do
    with %{body: %{id: facebook_id}} <- Facebook.API.me(token),
         {:ok, customer} <- get_customer_by_facebook_id(facebook_id) do
      {:ok, customer}
    else
      err -> err
    end
  end

  def get_recommended_rewards(customer_id, options) do
    # @TODO - Maybe geolocate, or revise when we have
    # many more locations. Is unnecessary to get every
    # unjoined shop ID.
    unjoined_location_ids = Location.get_customers_unjoined_location_ids(customer_id, options)
    customer_favourite_category_ids = Category.get_customer_favourites(customer_id)

    recommended_rewards =
      Reward.get_by_locations_categories_and_type(
        unjoined_location_ids,
        customer_favourite_category_ids,
        "first_time"
      )

    {:ok, recommended_rewards}
  end

  def log_add_point_to_customer_notes(customer_id, location_id, employee_id) do
    CustomerNote.log_add_point(customer_id, location_id, employee_id)
  end

  def log_remove_point_to_customer_notes(customer_id, location_id, employee_id) do
    CustomerNote.log_remove_point(customer_id, location_id, employee_id)
  end

  def save_customer_note(note, inverted \\ false) do
    CustomerNote.create(note)
    get_customer_notes(note.customer_id, note.location_id, inverted)
  end

  def get_customer_notes(customer_id, location_id, inverted \\ false) do
    {:ok, CustomerNote.get_all(customer_id, location_id, inverted)}
  end

  #### Private customer related functions

  defp validate_reset_phone_and_code(phone, code) do
    with {:ok, reset} <- get_customer_reset_by_code(code),
         {:ok, _} <- validate_reset_phone(reset, phone) do
      {:ok, reset}
    else
      err -> err
    end
  end

  defp get_customer_reset_by_code(code) do
    case CustomerReset.get_by_code(code) do
      nil -> {:error, "Invalid Verification Code Entered"}
      reset -> {:ok, reset}
    end
  end

  defp validate_reset_phone(reset, phone) do
    case reset.phone == phone do
      true -> {:ok, true}
      false -> {:error, "Reset code phone doesn't match"}
    end
  end

  def get_random_unused_reset_code() do
    code = randomizer(6, :numeric)

    case CustomerReset.get_by_code(code) do
      nil -> code
      _ -> get_random_unused_reset_code()
    end
  end

  defp send_customer_reset_email(customer_reset) do
    customer_reset
    |> CustomerEmail.password_reset_email()
    |> Store.Mailer.deliver()
    |> customer_reset_mark_as_sent(customer_reset.id)
  end

  defp send_customer_reset_sms(customer_reset) do
    msg = "Your Acme verification code is: #{customer_reset.code}"

    sms_settings = %{
      provider: sms_default_provider(),
      phone_number: sms_default_number(),
      send_distributed: @send_distributed
    }

    SMS.send(customer_reset.phone, msg, sms_settings)
    |> customer_reset_mark_as_sent(customer_reset.id)
  end

  defp customer_reset_mark_as_sent(result, id) do
    case result do
      {:ok, _result} -> CustomerReset.sent(id)
      {:error, error} -> {:error, error}
    end
  end

  ##################################
  # Member related functions
  ##################################

  def create_member(business_id, customer_id) do
    Membership.create(%{business_id: business_id, customer_id: customer_id})
  end

  ##################################
  # Campaign related functions
  ##################################

  def get_campaign(business_id, id) do
    Campaign.get_by_business_id(business_id, id)
  end

  def create_campaign(campaign) do
    case campaign.send_now do
      true -> send_campaign_now(campaign)
      false -> send_campaign_later(campaign)
    end
  end

  defp send_campaign_now(campaign) do
    with {:ok, campaign} <- put_sms_customer_segments(campaign),
         # this will perform an update if already exists
         {:ok, new_campaign} <- Campaign.create(campaign),
         {:ok, campaign} <- {:ok, Map.put(campaign, :id, new_campaign.id)},
         {:ok, campaign} <- get_campaign_deal(campaign),
         {:ok, _result} <- send_campaign_email_or_sms(campaign),
         {:ok, _sent} <- Campaign.sent(new_campaign.id) do
      {:ok, new_campaign}
    else
      err -> err
    end
  end

  defp get_campaign_deal(campaign) do
    case Map.has_key?(campaign, :deal_id) do
      false ->
        {:ok, campaign}

      true ->
        campaign = Map.put(campaign, :deal, Deal.get(campaign.deal_id))
        {:ok, campaign}
    end
  end

  defp send_scheduled_campaign(campaign) do
    with true <- Billing.in_good_standing?(campaign.location_id),
         {:ok, campaign} <- put_sms_customer_segments(campaign),
         {:ok, _new_campaign} <- Campaign.update_customers(campaign),
         {:ok, _result} <- send_campaign_email_or_sms(campaign),
         {:ok, _sent} <- Campaign.sent(campaign.id) do
      {:ok, true}
    else
      err -> err
    end
  end

  def sms_test(location_id, message, phones) do
    {:ok, sms_settings} = get_sms_settings(location_id)

    if sms_settings.phone_number == nil do
      {:error, "missing_sms_settings_phone"}
    else
      case Application.get_env(:store, :environment) do
        :prod ->
          _results = Enum.map(phones, fn phone -> SMS.send(phone, message, sms_settings) end)
          {:ok, %{success: true}}

        _ ->
          {:ok, %{success: true}}
      end
    end
  end

  def get_sms(uuid) do
    case SMSLog.get(uuid) do
      nil -> {:error, "Could not get sms log by uuid"}
      log -> {:ok, log}
    end
  end

  def update_sms(uuid, status, error) do
    SMSLog.update_status(uuid, status, error)
  end

  defp monthly_sms_count(location_id) do
    SMSLog.metrics_count([location_id], :this_month, ["campaign"])
  end

  # [customer_id, location_id, survey_id, campaign_id]
  def log_survey_click(ids) do
    customer_id = Enum.at(ids, 0)
    location_id = Enum.at(ids, 1)
    campaign_id = Enum.at(ids, 3)

    case campaign_id do
      nil ->
        {:ok, :noop}

      _ ->
        event = %{
          campaign_id: campaign_id,
          customer_id: customer_id,
          location_id: location_id,
          type: "survey-click"
        }

        case CampaignEvent.get(campaign_id, customer_id, location_id, "survey-click") do
          nil -> CampaignEvent.create(event)
          _ -> {:ok, :noop}
        end
    end
  end

  def log_campaign_click(cipher) do
    {:ok, ids} = ReferralLink.decode(cipher)
    campaign_id = Enum.at(ids, 0)
    customer_id = Enum.at(ids, 1)
    location_id = Enum.at(ids, 2)

    event = %{
      campaign_id: campaign_id,
      customer_id: customer_id,
      location_id: location_id,
      type: "click"
    }

    case CampaignEvent.get(campaign_id, customer_id, location_id, "click") do
      nil -> CampaignEvent.create(event)
      _ -> nil
    end

    campaign = Campaign.get(campaign_id)

    case campaign.deal do
      nil -> {:ok, %{location_id: location_id, deal_id: nil, success: true}}
      deal -> {:ok, %{location_id: location_id, deal_id: deal.id, success: true}}
    end
  end

  def log_campaign_bounce(campaign_id, customer_id, location_id, status) do
    bounce_statuses = ["failed", "undelivered", "rejected", "error"]

    case Enum.member?(bounce_statuses, status) do
      true ->
        event = %{
          campaign_id: campaign_id,
          customer_id: customer_id,
          location_id: location_id,
          type: "bounce"
        }

        CampaignEvent.create(event)

      false ->
        {:ok, false}
    end
  end

  # if we send the campaign later, we don't need to segment now, we can segment
  # at the time of sending to ensure that we have up to date stats
  defp send_campaign_later(campaign) do
    {:ok, sms_settings} = get_sms_settings(campaign.location_id)

    if sms_settings.phone_number == nil do
      {:error, "missing_sms_settings_phone"}
    else
      Campaign.create(campaign)
    end
  end

  def send_scheduled_campaigns(timezone_name) do
    timezone_ids = Location.get_timezone_ids(timezone_name)
    timezone = timezone_ids |> List.first()

    with {:ok, schedule_date_time} <- Timex.now() |> Calendar.DateTime.shift_zone(timezone),
         {:ok, campaigns} <- Campaign.ready_to_send(timezone_ids, schedule_date_time),
         {:ok, results} <- Enum.map(campaigns, &send_scheduled_campaign/1) do
      formatted_time = schedule_date_time |> Calendar.Strftime.strftime!("%d/%m/%Y %H:%M")
      IO.inspect("Sending campaigns for #{timezone_name} - #{timezone} @ #{formatted_time}")
      {:ok, results}
    else
      err -> err
    end
  end

  def campaign_send_stats(location_id, number_to_send) do
    max_sms = SMSSetting.get_by_location(location_id).max_sms
    {:ok, sent_this_month} = monthly_sms_count(location_id)

    number_to_send =
      case sent_this_month + number_to_send >= max_sms do
        true ->
          case sent_this_month >= max_sms do
            true -> 0
            false -> max_sms - sent_this_month
          end

        false ->
          number_to_send
      end

    {:ok, %{max_sms: max_sms, sent_this_month: sent_this_month, number_to_send: number_to_send}}
  end

  defp send_campaign_email_or_sms(campaign) do
    {:ok, sms_settings} = get_sms_settings(campaign.location_id)

    if sms_settings.phone_number == nil do
      {:error, "missing_sms_settings_phone"}
    else
      case Application.get_env(:store, :environment) do
        :dev ->
          send_campaign_emails(campaign.customers, campaign.message)

        _ ->
          Task.start(fn ->
            SMS.send_campaign(campaign, sms_settings)
          end)

          {:ok, true}
      end
    end
  end

  defp send_campaign_emails(recipients, message) do
    recipients
    |> CustomerEmail.send_campaign_emails(message)
    |> Store.Mailer.deliver()
  end

  def campaign_customer_count(campaign) do
    campaign
    |> get_campaign_segments()
    |> add_locations_with_notifications_enabled([campaign.location_id])
    |> remove_customers_not_member_of_locations([campaign.location_id])
    |> Enum.count()
  end

  def cancel_campaign(business_id, id) do
    Campaign.cancel(business_id, id)
  end

  defp get_campaign_segments(campaign) do
    segments = [
      :all,
      :loyal,
      :casual,
      :lapsed,
      :last_mile,
      :hoarders,
      # 0-10
      :spenders,
      :top_referrals,
      :birthdays,
      :no_shows
    ]

    options = %{
      options: %{
        filters: [
          %{field: "category_id", args: campaign.categories}
        ]
      }
    }

    Enum.map(campaign.groups, fn group_id ->
      segment = Enum.at(segments, group_id - 1)

      StoreMetrics.campaign_customer_segments(
        [campaign.location_id],
        options,
        segment
      )
    end)
    |> Enum.concat()
    |> Enum.uniq_by(fn c -> c.id end)
    |> Store.Inventory.filter_favourite_products(Map.get(campaign, :products))
  end

  defp put_sms_customer_segments(campaign) do
    customers =
      campaign
      |> get_campaign_segments()
      |> add_locations_with_notifications_enabled([campaign.location_id])
      |> remove_customers_not_member_of_locations([campaign.location_id])

    campaign = Map.put(campaign, :customers, customers)
    {:ok, campaign}
  end

  defp add_locations_with_notifications_enabled(customers, location_ids) do
    customer_ids = Enum.map(customers, fn c -> c.id end)

    case MembershipLocation.notifications_enabled(customer_ids, location_ids) do
      {:ok, customer_locations_enabled} ->
        locations =
          Enum.group_by(customer_locations_enabled, fn l -> l.customer_id end, fn l ->
            l.location_id
          end)

        Enum.map(customers, fn c ->
          customer_locations = Map.get(locations, c.id, [])
          Map.put(c, :locations, customer_locations)
        end)
    end
  end

  defp remove_customers_not_member_of_locations(customers, locations) do
    locations
    |> Enum.flat_map(fn l ->
      Enum.filter(customers, fn c ->
        Enum.member?(c.locations, l)
      end)
    end)
    |> Enum.uniq_by(fn c -> c.id end)
  end

  def get_campaigns(business_id, location_id, options) do
    Campaign.get_all(business_id, location_id, options)
  end

  def get_campaign_reports(business_id, campaign_id, options) do
    SMSLog.get_campaign_report(business_id, campaign_id, options)
  end

  def get_member_groups() do
    MemberGroup.get_all()
  end

  #######################################
  # Loyalty Transaction related functions
  #######################################

  # @TODO - we can delete this eventually when we write unit tests for the stuff below
  def create_transaction(transaction) do
    Transaction.create(transaction)
  end

  def earn_stamp(customer_id, location_id, qr_code) do
    with {:ok, _valid} <- Location.validate_qr_code(location_id, qr_code),
         {:ok, true} <- Location.is_open(location_id),
         {:ok, true} <- Transaction.has_not_earned_stamp_today(customer_id, location_id),
         {:ok, card} <- generate_transaction(customer_id, location_id),
         {:ok, _was_sent} <- check_send_location_review(customer_id, location_id) do
      {:ok, card}
    else
      err -> err
    end
  end

  def grant_stamp(employee_customer_id, location_id, customer_qr_code) do
    with {:ok, customer} <- get_customer_by_qr_code(customer_qr_code),
         employee <- Employee.get_by_location_customer_id(employee_customer_id, location_id),
         {:ok, true} <- Location.is_open(location_id),
         {:ok, true} <- Transaction.has_not_earned_stamp_today(customer.id, location_id),
         {:ok, true} <- verify_joined_shop(customer.id, location_id),
         {:ok, _card} <- generate_transaction(customer.id, location_id, employee.id),
         {:ok, _was_sent} <- check_send_location_review(customer.id, location_id) do
      {:ok, %{id: customer.id}}
    else
      err -> err
    end
  end

  defp verify_joined_shop(customer_id, location_id) do
    case has_joined_shop?(customer_id, location_id) do
      true ->
        {:ok, true}

      false ->
        case join_shop(customer_id, location_id) do
          {:ok, %{success: true}} -> {:ok, true}
          e -> e
        end
    end
  end

  defp get_customer_by_qr_code(qr_code) do
    case Customer.get_by_qr_code(qr_code) do
      nil -> {:error, "customer_not_found"}
      c -> {:ok, c}
    end
  end

  defp check_send_location_review(customer_id, location_id) do
    case Reward.get_by_location_and_type(location_id, "review") do
      nil ->
        {:ok, false}

      reward ->
        case Review.create(%{customer_id: customer_id, location_id: location_id}) do
          {:ok, _} -> send_location_review_sms(customer_id, location_id, reward.name)
          {:error, _} -> {:ok, false}
        end
    end
  end

  defp send_location_review_sms(customer_id, location_id, reward_name) do
    msg =
      "Thank you for your purchase. Leave us a review so we can improve your shopping experience to earn #{
        reward_name
      }: https://app.yourdomain.com/i/r/#{location_id}"

    with {:ok, sms_settings} <- get_sms_settings(location_id) do
      customer = Customer.get(customer_id)

      case Application.get_env(:store, :environment) do
        :dev ->
          send_location_review_email(msg)

        _ ->
          SMS.send(customer.phone, msg, sms_settings)
          {:ok, true}
      end
    end
  end

  defp send_location_review_email(msg) do
    Store.DevEmail.simple_message(msg, "Leave a Review")
    |> Store.Mailer.deliver()

    {:ok, true}
  end

  def add_point(customer_id, location_id, employee_id) do
    generate_transaction(customer_id, location_id, employee_id, true)
  end

  def remove_point(customer_id, location_id, employee_id) do
    multi =
      Multi.new()
      |> Multi.run(:loyalty_card, fn _ -> Store.Loyalty.loyalty_card(customer_id, location_id) end)
      |> Multi.run(:credit_balance, fn results ->
        card = results[:loyalty_card]

        if card.balance > 0 do
          create_transaction(customer_id, location_id, employee_id, "debit", 1)
        else
          {:error, "Cannot decrement below zero"}
        end
      end)
      |> Multi.run(:customer_note, fn _ ->
        log_remove_point_to_customer_notes(customer_id, location_id, employee_id)
      end)

    case Repo.transaction(multi) do
      {:ok, %{loyalty_card: card, credit_balance: _}} ->
        {:ok, %{balance: card.balance - 1}}

      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:ok, %{balance: 0}}
    end
  end

  # reduce coupling on Visits, and use an event pattern to emit the credit add
  defp generate_transaction(
         customer_id,
         location_id,
         employee_id \\ nil,
         show_in_customer_notes \\ false
       ) do
    credit_changeset = transaction_changeset(customer_id, location_id, employee_id, "credit", 1)

    multi =
      Multi.new()
      |> Multi.insert(:add_credit, credit_changeset)
      |> Multi.run(:loyalty_card, fn _ -> Store.Loyalty.loyalty_card(customer_id, location_id) end)
      |> Multi.run(:customer_reward, fn results ->
        card = results[:loyalty_card]

        if card.balance == card.total do
          with {:ok, customer_reward} <-
                 Store.Loyalty.create_customer_reward(customer_id, card.reward_id),
               {:ok, _t} <-
                 create_transaction(customer_id, location_id, employee_id, "debit", card.total) do
            {:ok, customer_reward} = CustomerReward.get_reward(customer_reward.id)
            card = Map.put(card, :balance, card.balance - card.total)
            card = Map.put(card, :customer_reward, customer_reward)
            card = Map.put(card, :id, location_id)
            {:ok, card}
          else
            err -> err
          end
        else
          card = Map.put(card, :customer_reward, nil)
          {:ok, card}
        end
      end)
      |> Multi.run(:log_visit, fn _ ->
        case Visit.today_count(customer_id, location_id) do
          0 -> Visit.create(%{customer_id: customer_id, location_id: location_id})
          _ -> {:ok, "Carry on"}
        end
      end)
      |> Multi.run(:customer_note, fn _ ->
        if show_in_customer_notes do
          log_add_point_to_customer_notes(customer_id, location_id, employee_id)
        else
          {:ok, nil}
        end
      end)

    referral_multi = referral_multi(customer_id, location_id)
    multi = Multi.append(multi, referral_multi)

    case Repo.transaction(multi) do
      {:ok, %{add_credit: _, loyalty_card: _, customer_reward: card, log_visit: _}} ->
        {:ok, card}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp create_transaction(customer_id, location_id, employee_id, type, units) do
    transaction_changeset(customer_id, location_id, employee_id, type, units)
    |> Repo.insert()
  end

  defp transaction_changeset(customer_id, location_id, employee_id, type, units) do
    transaction = %{
      customer_id: customer_id,
      location_id: location_id,
      employee_id: employee_id,
      meta: %{},
      type: type,
      units: units
    }

    %Transaction{}
    |> Transaction.changeset(transaction)
  end

  ##################################
  # Survey related functions
  ##################################

  def save_survey(survey) do
    case Survey.create(survey) do
      {:ok, %{id: id}} -> {:ok, %{success: true, id: id}}
      error -> error
    end
  end

  def get_survey(%{code: code, subdomain: subdomain}) do
    with {:ok, ids} <- Survey.decode_hash(code),
         {:ok, business} <- get_business_by_subdomain(subdomain),
         {:ok, _survey_click} <- log_survey_click(ids) do
      survey_id = Enum.at(ids, 2)
      get_survey(survey_id, business.id)
    else
      err -> err
    end
  end

  def get_survey(id, business_id) do
    case Survey.get(id, business_id) do
      nil -> {:error, "Survey not found."}
      survey -> {:ok, survey}
    end
  end

  def get_surveys(business_id, location_id, options) do
    with {:ok, page} <- {:ok, Survey.paginate(business_id, location_id, options)},
         {:ok, survey_ids} <- {:ok, Enum.map(page.entries, fn survey -> survey.id end)},
         {:ok, submissions} <- SurveySubmission.get_submission_counts(survey_ids),
         {:ok, surveys_paged} <- map_submissions_to_surveys(page, submissions) do
      {:ok, surveys_paged}
    else
      err -> err
    end
  end

  defp map_submissions_to_surveys(page, submissions) do
    surveys =
      Enum.map(page.entries, fn survey ->
        submission =
          Enum.find(submissions, %{count: 0}, fn submission ->
            submission.survey_id == survey.id
          end)

        Map.put(survey, :submissions, submission.count)
      end)

    {:ok, Map.put(page, :entries, surveys)}
  end

  def get_survey_submissions(business_id, options) do
    {:ok, SurveySubmission.paginate(business_id, options)}
  end

  def save_submission(code, answers) do
    # ids = [customer_id, location_id, survey_id, campaign_id]
    with {:ok, ids} <- Survey.decode_hash(code) do
      customer_id = Enum.at(ids, 0)
      location_id = Enum.at(ids, 1)
      survey_id = Enum.at(ids, 2)

      submission = %{
        answers: answers,
        location_id: location_id,
        customer_id: customer_id,
        survey_id: survey_id
      }

      case SurveySubmission.create(submission) do
        {:ok, _result} -> {:ok, %{success: true}}
        err -> err
      end
    end
  end

  def get_survey_submission(id, business_id) do
    case SurveySubmission.get(id, business_id) do
      nil -> {:error, "Submission not found."}
      submission -> {:ok, submission}
    end
  end

  ##################################
  # Convenience functions
  ##################################
  def toggle_active(schema, id, is_active) do
    schema.toggle_active(id, is_active)
  end

  def replace_campaign_message_variables(
        campaign,
        intent,
        customer,
        location_id,
        business_subdomain
      ) do
    message = campaign.message
    # %app-link% or %deal-link%
    message = Regex.replace(~r/%app-link%/, message, intent)
    message = Regex.replace(~r/%deal-link%/, message, intent)
    # %first-name%
    replacement =
      case Map.get(customer, :first_name, nil) do
        nil -> ""
        name -> name
      end

    message = Regex.replace(~r/%first-name%/, message, replacement)
    # %survey-link%
    survey_link =
      case Map.get(campaign, :survey_id, nil) do
        nil ->
          ""

        survey_id ->
          Survey.generate_url(
            business_subdomain,
            customer.id,
            location_id,
            survey_id,
            campaign.id
          )
      end

    Regex.replace(~r/%survey-link%/, message, survey_link)
  end
end
