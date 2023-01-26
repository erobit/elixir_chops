defmodule Store.Billing do
  @moduledoc """
  Billing context
  """
  alias Billing.Schemas.{Profile, Card, Transaction}
  alias Store.Billing.Integration.Paysafe
  require Logger

  def in_good_standing?(location_id) do
    profile = Profile.get_by_location_id(location_id)
    Transaction.in_good_standing?(profile.id)
  end

  def trial_periods(business_id) do
    case Profile.get_trial_periods(business_id) do
      {:error, error} -> {:error, error}
      trials -> {:ok, trials}
    end
  end

  def create_profile(%{location: %{id: id}}) do
    %{
      location_id: id,
      payment_type: "credit_card",
      billing_start: Date.add(Date.utc_today(), 30),
      package_id: 1
    }
    |> Profile.create()
  end

  def update_profile(profile) do
    # @TODO - If there are billing transactions we cannot
    # change the billing_start date SO SORRY
    Profile.create(profile)
  end

  def get_profile(location_id) do
    case Profile.get_by_location_id(location_id) do
      nil -> {:error, "no_profile"}
      profile -> {:ok, profile}
    end
  end

  def get_card(id) do
    case Card.get_by_id(id) do
      nil -> {:error, "card_not_found"}
      card -> {:ok, populate_address(card)}
    end
  end

  defp get_billing_address(card) do
    case Paysafe.get_billing_address(card.profile.profile_id, card.billing_address_id) do
      {:ok, address} -> create_address_from_paysafe(address)
      {:error, _} -> card
    end
  end

  defp populate_address(card) do
    Map.put(card, :address, get_billing_address(card))
  end

  def get_cards(location_id) do
    case Card.get_by_location_id(location_id) do
      [] -> {:ok, []}
      cards -> {:ok, cards}
    end
  end

  def create_card(location_id, single_use_token) do
    env = Application.get_env(:store, :environment)
    merchant_customer_id = "yourdomain-customer-#{env}-#{location_id}"

    with profile <- Profile.get_by_location_id(location_id),
         {:ok, auth_transaction} <-
           Transaction.create(%{type: "authorization", profile_id: profile.id}),
         {:ok, _authWithoutSettlement} <-
           Paysafe.authorize(
             single_use_token,
             auth_transaction.uuid,
             100,
             true,
             false
           ),
         {:ok, paysafe_profile} <-
           Paysafe.get_or_create_profile(merchant_customer_id, single_use_token),
         {:ok, profile} <- link_profile(location_id, paysafe_profile["id"]),
         {:ok, paysafe_card} <- Paysafe.create_card(paysafe_profile["id"], single_use_token),
         {:ok, card} <- create_card_from_paysafe(profile.id, paysafe_card),
         {:ok, card} <- set_card_default_if_no_default(card) do
      {:ok, card}
    else
      {:error, error} ->
        # IO.inspect(error)
        Logger.error("Billing : Error Creating Card", event: error)
        {:error, error}
    end
  end

  def set_card_default_if_no_default(card) do
    case Card.no_default_card?(card.profile_id) do
      true -> set_default_card(card.id)
      false -> {:ok, card}
    end
  end

  def update_card(id, expiry_month, expiry_year) do
    with card <- Card.get_card_and_profile(id),
         {:ok, _paysafe_card} <-
           Paysafe.update_card(%{
             profile_id: card.profile.profile_id,
             card_id: card.card_id,
             expiry_month: expiry_month,
             expiry_year: expiry_year,
             is_default: card.is_default
           }),
         # verify the card after it's been updated
         # profile <- Profile.get_by_location_id(card.profile.location_id),
         # {:ok, _verification} <- verify_card(profile.id, card.id, card.payment_token),
         {:ok, card} <- Card.update_expiry(id, expiry_month, expiry_year) do
      {:ok, card}
    else
      err -> err
    end
  end

  def delete_card(id) do
    with card <- Card.get_card_and_profile(id),
         {:ok, deleted_card} <- Card.mark_deleted(id),
         _beleted <- Paysafe.delete_card(card.profile.profile_id, card.card_id) do
      {:ok, deleted_card}
    else
      err -> err
    end
  end

  # @WARNING - this is only used for 
  # manually clearing the sandbox environment
  # of cards
  def clean_sandbox() do
    cards = Card.get_all()

    cards
    |> Enum.each(fn card -> Paysafe.delete_card(card.profile_id, card.card_id) end)
  end

  def set_default_card(id) do
    with card <- Card.get_card_and_profile(id),
         {:ok, _defaulted} <-
           Paysafe.update_card(%{
             profile_id: card.profile.profile_id,
             card_id: card.card_id,
             expiry_month: card.expiry_month,
             expiry_year: card.expiry_year,
             is_default: true
           }),
         {_num_cleared, _results} <- Card.clear_default(card.profile_id),
         {:ok, card} <- Card.set_default(id) do
      {:ok, card}
    else
      err -> err
    end
  end

  # private helper functions
  defp verify_card(profile_id, card_id, payment_token) do
    {:ok, transaction} =
      %{type: "verification", profile_id: profile_id, card_id: card_id}
      |> Transaction.create()

    with {:ok, verification} <- Paysafe.verify(payment_token, transaction.uuid),
         {:ok, _updated} <- update_transaction(transaction.id, "SUCCESS", verification),
         {:ok, _verified} <- Card.set_status(card_id, "verified") do
      {:ok, verification}
    else
      {:error, error} ->
        update_transaction(transaction.id, "FAILED", error)

        status =
          case error.code do
            "3006" -> "expired"
            _ -> "invalid"
          end

        Card.set_status(card_id, status)

        error = Map.put(error, :card_id, card_id)
        {:error, error}
    end
  end

  defp link_profile(location_id, profile_id) do
    Profile.link(location_id, profile_id)
  end

  defp create_address_from_paysafe(paysafe_address) do
    %{
      city: paysafe_address["city"],
      country: paysafe_address["country"],
      state: paysafe_address["state"],
      street: paysafe_address["street"],
      street2: paysafe_address["street2"],
      zip: paysafe_address["zip"]
    }
  end

  defp create_card_from_paysafe(profile_id, paysafe_card) do
    %{
      card_id: paysafe_card["id"],
      profile_id: profile_id,
      payment_token: paysafe_card["paymentToken"],
      billing_address_id: paysafe_card["billingAddressId"],
      type: paysafe_card["cardType"],
      category: paysafe_card["cardCategory"],
      last_digits: paysafe_card["lastDigits"],
      expiry_month: paysafe_card["cardExpiry"]["month"],
      expiry_year: paysafe_card["cardExpiry"]["year"],
      status: "verified",
      is_default: false
    }
    |> Card.create()
  end

  def process_monthly_payments() do
    # note: we should also store last_billing on the profile and set
    # it in the case that the location is de-activated. This should also 
    # become a superadmin feature rather than a customer feature!
    with profiles <- Profile.get_active_credit_profiles(),
         {:ok, payments} <- Enum.map(profiles, &monthly_payment/1) do
      {:ok, payments}
    else
      err -> err
    end
  end

  defp monthly_payment(profile) do
    with {:ok, card} <- Card.get_default(profile.id),
         # {:ok, _verification} <- verify_card(profile.id, card.id, card.payment_token),
         is_first_payment <- Transaction.is_first_payment?(profile.id),
         has_been_paid <- Transaction.has_been_paid?(profile.id) do
      # for now we'll always charge the full monthly billing amount
      # and we'll introduce trial_end along with billing_start potentially
      # in the future
      amount_to_bill = profile.billing_amount
      # case is_first_payment and not is_nil(profile.billing_start) do
      #   true ->
      #     amount_in_cents =
      #       Money.new(:USD, profile.billing_amount)
      #       |> calcuate_pro_rated_amount(profile.billing_start)

      #     Decimal.from_float(amount_in_cents / 100)

      #   false ->
      #     profile.billing_amount
      # end

      # apply credits, calculate amount_to_bill and remainding credits
      {amount_to_bill, credit_remaining} =
        calculate_amount_to_bill(amount_to_bill, profile.billing_credit)

      amount_in_cents =
        Money.new(:USD, amount_to_bill)
        |> amount_in_cents()

      case has_been_paid do
        true ->
          {:error, "already_paid_this_month"}

        false ->
          process_payment(
            profile.id,
            card.id,
            card.payment_token,
            amount_in_cents,
            credit_remaining,
            is_first_payment
          )
      end
    else
      {:error, error} ->
        transaction = %{
          profile_id: profile.id,
          type: "payment"
        }

        case error do
          # verification failed
          %{code: code, message: message, card_id: card_id} ->
            transaction
            |> Map.put(:status, "FAILED")
            |> Map.put(:code, code)
            |> Map.put(:message, message)
            |> Map.put(:card_id, card_id)
            |> Transaction.create()

            send_billing_email(profile.id, code)

          # no_default_card_assigned
          error ->
            transaction
            |> Map.put(:status, "FAILED")
            |> Map.put(:message, error)
            |> Transaction.create()

            # @TODO - we should send an email indicating
            # no default billing card has been added to their account

            # send_billing_email(profile.id, "declined")
        end

        {:error, error}
    end
  end

  defp calculate_amount_to_bill(amount, credit) do
    case credit == 0 do
      true ->
        {amount, 0}

      false ->
        case credit <= amount do
          true ->
            {Decimal.sub(amount, credit), 0}

          false ->
            {0, Decimal.sub(credit, amount)}
        end
    end
  end

  # we are assuming that billing happens on the first of the month
  # otherwise we need to change some logic in here and pro-rate
  # based on when the last payment was made etc...
  defp calcuate_pro_rated_amount(amount_to_bill, billing_start) do
    today = Date.utc_today()
    start_of_month = Timex.to_date(Timex.beginning_of_month(today))
    last_day_of_last_month = Date.add(start_of_month, -1)
    days_in_last_month = Date.days_in_month(last_day_of_last_month)
    days_to_bill = Date.diff(last_day_of_last_month, billing_start)

    days_to_bill =
      case days_to_bill > days_in_last_month do
        true -> days_in_last_month
        false -> days_to_bill
      end

    price_per_day = Money.div!(amount_to_bill, days_in_last_month)
    pro_rated_amount = Money.mult!(price_per_day, days_to_bill)
    amount_in_cents(pro_rated_amount)
  end

  defp amount_in_cents(money) do
    {_currency, amount_in_cents, _exp, _remainder} = Money.to_integer_exp(money)
    amount_in_cents
  end

  defp process_payment(
         profile_id,
         card_id,
         payment_token,
         amount_in_cents,
         credit_remaining,
         is_first_payment
       ) do
    transaction = %{
      profile_id: profile_id,
      card_id: card_id,
      amount: amount_in_cents,
      type: "payment"
    }

    {:ok, transaction} = Transaction.create(transaction)

    with {:ok, paysafe_transaction} <-
           (case amount_in_cents > 0 do
              true ->
                Paysafe.authorize(
                  payment_token,
                  transaction.uuid,
                  amount_in_cents,
                  is_first_payment,
                  true
                )

              false ->
                {:error, %{code: "zero", message: "Amount to charge was less than zero."}}
            end) do
      Profile.update_billing_credit(profile_id, credit_remaining)
      update_transaction(transaction.id, "SUCCESS", paysafe_transaction)
    else
      {:error, error} ->
        update_transaction(transaction.id, "FAILED", error)

        case error.code do
          "zero" ->
            :noop

          "3006" ->
            Card.set_status(card_id, "expired")
            send_billing_email(profile_id, "3006")

          # "3002 = declined"
          _ ->
            Card.set_status(card_id, "declined")
            send_billing_email(profile_id, "declined")
        end

        {:error, error}
    end
  end

  defp update_transaction(transaction_id, status, fields) do
    transaction = %{
      id: transaction_id,
      status: status
    }

    transaction =
      case status do
        "SUCCESS" ->
          Map.merge(
            transaction,
            %{
              payment_id: fields["id"]
            }
          )

        "FAILED" ->
          Map.merge(transaction, fields)

        _ ->
          transaction
      end

    Transaction.create(transaction)
  end

  defp send_billing_email(profile_id, error_code) do
    error_type =
      case error_code do
        "3006" -> "expired"
        _ -> "declined"
      end

    profile = Profile.get_with_preloads(profile_id)
    employees = Store.Employee.get_owners(profile.location_id)

    Enum.each(employees, fn employee ->
      Billing.Email.send_error(profile, employee.email, error_type)
      |> Store.Mailer.deliver()
    end)
  end
end
