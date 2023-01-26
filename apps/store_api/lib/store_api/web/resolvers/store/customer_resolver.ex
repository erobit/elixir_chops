defmodule StoreAPI.Resolvers.Customer do
  alias Store
  alias Store.Account

  ### Queries

  def get_customer_details(%{id: id, location_id: location_id}, %{context: %{employee: employee}}) do
    with true <- Store.employee_member_of_location?(employee, location_id),
         true <- Store.has_joined_shop?(id, location_id) do
      Store.get_customer_details(id, location_id)
    else
      _ -> {:error, "forbidden"}
    end
  end

  def get_customer_details(args, %{context: %{customer: customer}}) do
    case Store.get_employee_by_customer_and_location(customer.id, args.location_id) do
      {:ok, employee} -> get_customer_details(args, %{context: %{employee: employee}})
      e -> e
    end
  end

  def exists(params, _) do
    params = Map.merge(%{email: ""}, params)

    case Store.customer_exists(params.phone, params.email) do
      nil -> {:ok, %{success: false}}
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def facebook_user_auth(%{facebook_token: facebook_token}, _) do
    with {:ok, customer} <- Store.facebook_auth_and_verify(facebook_token),
         {:ok, jwt, _} <- Mobile.Guardian.encode_and_sign(customer, token_type: :access) do
      {:ok, %{token: jwt}}
    else
      _ -> {:error, "User not found"}
    end
  end

  def me(_, %{context: %{customer: customer}}) do
    case Store.get_customer_profile(customer.id) do
      nil -> {:error, "Cannot get profile for #{customer.id}"}
      customer -> {:ok, customer}
    end
  end

  def metric_counts(args, %{context: %{employee: employee}}) do
    location_id = args.location_id

    location_ids =
      Enum.map(Enum.filter(employee.locations, fn l -> l.is_active end), fn l -> l.id end)

    unless Enum.member?(location_ids, location_id) do
      throw("Forbidden")
    end

    with {:ok, all} <-
           StoreMetrics.customers_all_count([location_id], Map.get(args, :customer_id)),
         {:ok, loyal} <-
           StoreMetrics.customers_loyal_count([location_id], Map.get(args, :customer_id)),
         {:ok, casual} <-
           StoreMetrics.customers_casual_count([location_id], Map.get(args, :customer_id)),
         {:ok, lapsed} <-
           StoreMetrics.customers_lapsed_count([location_id], Map.get(args, :customer_id)),
         {:ok, last_mile} <-
           StoreMetrics.customers_last_mile_count([location_id], Map.get(args, :customer_id)),
         {:ok, hoarders} <-
           StoreMetrics.customers_hoarder_count([location_id], Map.get(args, :customer_id)),
         {:ok, spenders} <-
           StoreMetrics.customers_spender_count([location_id], Map.get(args, :customer_id)),
         {:ok, referrals} <-
           StoreMetrics.customers_referral_count([location_id], Map.get(args, :customer_id)),
         {:ok, birthdays} <-
           StoreMetrics.customers_birthday_count([location_id], Map.get(args, :customer_id)),
         {:ok, no_shows} <-
           StoreMetrics.customers_no_show_count([location_id], Map.get(args, :customer_id)) do
      customer_metrics = %{
        all: all,
        loyal: loyal,
        casual: casual,
        lapsed: lapsed,
        last_mile: last_mile,
        hoarders: hoarders,
        spenders: spenders,
        referrals: referrals,
        birthdays: birthdays,
        no_shows: no_shows
      }

      {:ok, customer_metrics}
    else
      err -> err
    end
  end

  def segments(%{type: type, options: options, location_id: location_id}, %{
        context: %{employee: employee}
      }) do
    type = String.to_atom(type)
    options = %{options: options}

    location_ids =
      Enum.map(Enum.filter(employee.locations, fn l -> l.is_active end), fn l -> l.id end)

    case Enum.member?(location_ids, location_id) do
      true ->
        case StoreMetrics.customer_segments(employee.business_id, [location_id], options, type) do
          {:ok, customers} -> {:ok, customers}
          {:error, error} -> {:error, error}
        end

      false ->
        {:error, "Forbidden"}
    end
  end

  ### Mutations

  def reset(%{phone: phone}, _) do
    case Store.customer_reset(phone) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def send_email_verification(%{email: email}, %{context: %{customer: customer}}) do
    case Account.send_email_verification(customer.phone, email) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def verify_email(%{email: email, code: code}, %{context: %{customer: customer}}) do
    case Account.verify_email(customer.phone, email, code) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def send_email_recovery(%{email: email}, _) do
    case Account.send_email_recovery(email) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def verify_recovery(%{old_phone: old_phone, new_phone: new_phone, code: code}, _) do
    case Account.verify_recovery(old_phone, new_phone, code) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def create(params, _) do
    params = Map.merge(%{email: ""}, params)

    with {:ok, customer} <- Store.create_account(params.phone, params.code, params.email),
         {:ok, jwt, _} <- Mobile.Guardian.encode_and_sign(customer, token_type: :access) do
      {:ok, %{token: jwt}}
    else
      err -> err
    end
  end

  def customer_create(
        %{
          first_name: first_name,
          last_name: last_name,
          phone: phone,
          email: email,
          location_id: location_id
        },
        %{context: %{employee: employee}}
      ) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)
    customer = %{first_name: first_name, last_name: last_name, phone: phone, email: email}

    if is_location_member do
      case Store.crm_opt_in(customer, location_id) do
        {:ok, customer} -> {:ok, %{success: true, id: customer.id}}
        {:error, _error} -> {:error, "email_in_use"}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def opt_in(%{subdomain: subdomain, tablet: tablet, customer: customer}, _) do
    customer = Map.merge(%{email: ""}, customer)

    case Store.opt_in(subdomain, tablet, customer) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, _} -> {:ok, %{success: false}}
    end
  end

  def sign_in(%{phone: phone, code: code}, _) do
    with {:ok, customer} <- Store.sign_in(phone, code),
         {:ok, jwt, _} <- Mobile.Guardian.encode_and_sign(customer, token_type: :access) do
      {:ok, %{token: jwt}}
    else
      err -> err
    end
  end

  def update(customer_obj, %{context: %{customer: customer}}) do
    confirmation = Map.get(customer_obj, :confirmation, false)

    customer_obj =
      customer_obj
      |> Map.put(:id, customer.id)
      |> Map.delete(:confirmation)

    case Store.update_customer(customer_obj, confirmation) do
      {:ok, customer} -> {:ok, customer}
      {:error, err} -> {:error, err}
    end
  end

  def update(customer_obj, %{context: %{employee: employee}}) do
    location_id = Map.get(customer_obj, :location_id)
    customer_obj = Map.delete(customer_obj, :location_id)

    is_location_member = Store.employee_member_of_location?(employee, location_id)

    with true <- is_location_member,
         true <- Store.has_joined_shop?(customer_obj.id, location_id) do
      case Store.update_customer(customer_obj) do
        {:ok, customer} -> {:ok, customer}
        {:error, err} -> {:error, err}
      end
    else
      _err -> {:error, "Unauthorized"}
    end
  end

  def feedback(%{feedback: feedback}, %{context: %{customer: customer}}) do
    case Store.customer_feedback(customer.id, feedback) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  def notify(%{lat: lat, lon: lon}, %{context: %{customer: customer}}) do
    case Store.notify(customer.id, lat, lon) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  def locations(%{customer_id: customer_id}, %{context: %{employee: employee}}) do
    case Store.customer_locations(employee.business_id, customer_id) do
      {:ok, locations} -> {:ok, locations}
      {:error, error} -> {:error, error}
    end
  end

  def toggle_crm_notifications(
        %{customer_id: customer_id, location_id: location_id, enabled: enabled},
        %{
          context: %{employee: employee}
        }
      ) do
    case Store.toggle_customer_location_notifications(
           employee.business_id,
           location_id,
           customer_id,
           enabled,
           "crm-toggle"
         ) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  def save_note(note, %{context: %{employee: employee}}) do
    is_member = Store.employee_member_of_location?(employee, note.location_id)
    inverted = Map.get(note, :inverted, false)
    note = Map.delete(note, :inverted)

    note =
      case Map.get(note, :id) do
        nil -> Map.put(note, :employee_id, employee.id)
        _ -> note
      end

    case is_member do
      false ->
        {:error, "unauthorized"}

      true ->
        Store.save_customer_note(note, inverted)
    end
  end

  def save_note(note, %{context: %{customer: customer}}) do
    note = Map.put(note, :inverted, true)

    case Store.get_employee_by_customer_and_location(customer.id, note.location_id) do
      {:ok, employee} -> save_note(note, %{context: %{employee: employee}})
      e -> e
    end
  end

  def get_customer_notes(args, %{context: %{employee: employee}}) do
    is_member = Store.employee_member_of_location?(employee, args.location_id)

    case is_member do
      false ->
        {:error, "unauthorized"}

      true ->
        Store.get_customer_notes(
          args.customer_id,
          args.location_id,
          Map.get(args, :inverted, false)
        )
    end
  end

  def get_customer_notes(args, %{context: %{customer: customer}}) do
    case Store.get_employee_by_customer_and_location(customer.id, args.location_id) do
      {:ok, employee} ->
        get_customer_notes(Map.put(args, :inverted, true), %{context: %{employee: employee}})

      e ->
        e
    end
  end

  def delete_account(_, %{context: %{customer: customer}}) do
    case Account.delete(customer.id) do
      {:ok, _} ->
        {:ok, %{success: true}}

      err ->
        err
    end
  end
end
