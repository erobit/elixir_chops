defmodule Store.Billing.Integration.Paysafe do
  use Tesla
  alias Store.Billing.Integration.Paysafe

  @version "v1"
  @merchantRefNum "acme"
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.BasicAuth, username: username(), password: password())

  plug(Tesla.Middleware.FormUrlencoded,
    encode: &Plug.Conn.Query.encode/1,
    decode: &Plug.Conn.Query.decode/1
  )

  def monitor() do
    {:ok, %Tesla.Env{} = response} = Paysafe.get("#{api_endpoint()}/customervault/monitor")

    case response.status do
      200 ->
        {:ok, response.body}

      code ->
        {:error, "paysafe api monitor responding with http status code =#{code}"}
    end
  end

  # https://developer.paysafe.com/en/vault/api/#/reference/0/profiles/create-a-profile
  def create_profile(merchant_customer_id, single_use_token) do
    profile = %{
      merchantCustomerId: merchant_customer_id,
      locale: "en_US",
      # "firstName": "John",
      # "middleName": "James",
      # "lastName": "Smith",
      # "dateOfBirth": {
      #  "year": 1981,
      #  "month": 10,
      #  "day": 24
      # },
      # "email": "john.smith@email.com",
      # "phone": "777-444-8888",
      # "ip": "192.0.126.111",
      # "gender": "M",
      # "nationality": "Canadian",
      # "cellPhone": "777-555-8888",
      card: %{
        singleUseToken: single_use_token
      }
    }

    {:ok, %Tesla.Env{} = response} = Paysafe.post(customer_vault_endpoint(), profile)
    # IO.inspect(response)

    case response.status do
      200 ->
        {:ok, response.body}

      201 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://developer.paysafe.com/en/vault/api/#/reference/0/profiles/get-profile
  def get_profile(%{profile_id: profile_id}) do
    endpoint = "#{customer_vault_endpoint()}/#{profile_id}"
    # query = [fields: "addresses,cards"]
    {:ok, %Tesla.Env{} = response} = Paysafe.get(endpoint)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://developer.paysafe.com/en/vault/api/#/reference/0/profiles/get-profile-using-merchant-customer-id
  def get_profile(%{merchant_customer_id: merchant_customer_id}) do
    endpoint = "#{customer_vault_endpoint()}"
    query = [merchantCustomerId: merchant_customer_id]
    {:ok, %Tesla.Env{} = response} = Paysafe.get(endpoint, query: query)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  def get_or_create_profile(merchant_customer_id, single_use_token) do
    case get_profile(%{merchant_customer_id: merchant_customer_id}) do
      {:ok, profile} ->
        {:ok, profile}

      {:error, _error} ->
        create_profile(merchant_customer_id, single_use_token)
    end
  end

  # https://developer.paysafe.com/en/payments/cards/api/#/reference/0/verifications/get-verification
  def get_verification(verification_id) do
    endpoint = "#{card_payments_endpoint()}/verifications/#{verification_id}"
    {:ok, %Tesla.Env{} = response} = Paysafe.get(endpoint)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  def get_verifications() do
    endpoint = "#{card_payments_endpoint()}/verifications"
    # limit, offset, startDate, endDate
    query = [merchantRefNum: @merchantRefNum]
    {:ok, %Tesla.Env{} = response} = Paysafe.get(endpoint, query: query)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://developer.paysafe.com/en/payments/cards/api/#/reference/0/verifications/verification
  def verify(single_use_token, merchant_ref_num) do
    endpoint = "#{card_payments_endpoint()}/verifications"

    data = %{
      card: %{
        paymentToken: single_use_token
      },
      merchantRefNum: merchant_ref_num,
      description: "This is a Verification transaction."
    }

    {:ok, %Tesla.Env{} = response} = Paysafe.post(endpoint, data)
    # IO.inspect(response)

    case response.status do
      200 ->
        # Note: not_processed added for card updates as cvv is not processed again in this case
        # but required to see if the card is expired :)
        avs_match = response.body["avsResponse"] in ["MATCH", "NOT_PROCESSED"]
        cvv_match = response.body["cvvVerification"] in ["MATCH", "NOT_PROCESSED"]

        case avs_match and cvv_match do
          true -> {:ok, response.body}
          false -> {:error, %{code: "1337", message: "address_or_cvv_do_not_match"}}
        end

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://api.test.paysafe.com/customervault/v1/profiles/profile_id/cards
  def create_card(profile_id, single_use_token) do
    endpoint = "#{customer_vault_endpoint()}/#{profile_id}/cards"
    data = %{singleUseToken: single_use_token}
    {:ok, %Tesla.Env{} = response} = Paysafe.post(endpoint, data)
    # IO.inspect(response)

    case response.status do
      201 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://developer.paysafe.com/en/vault/api/#/reference/0/cards/get-card
  def get_card(profile_id, card_id) do
    endpoint = "#{customer_vault_endpoint()}/#{profile_id}/cards/#{card_id}"
    {:ok, %Tesla.Env{} = response} = Paysafe.get(endpoint)
    # IO.inspect(response)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://developer.paysafe.com/en/vault/api/#/reference/0/cards/update-a-card
  def update_card(%{
        profile_id: profile_id,
        card_id: card_id,
        expiry_month: expiry_month,
        expiry_year: expiry_year,
        is_default: is_default
      }) do
    endpoint = "#{customer_vault_endpoint()}/#{profile_id}/cards/#{card_id}"

    card = %{
      cardExpiry: %{
        month: expiry_month,
        year: expiry_year
      },
      # nickName: "John Corporate Card",
      # merchantRefNum: "Our own internal card identification number if we choose to send",
      # holderName: "John Smith",
      # billingAddressId: "794b2b05-1a3b-4544-a59c-8612d0a4711e",
      defaultCardIndicator: is_default
    }

    {:ok, %Tesla.Env{} = response} = Paysafe.put(endpoint, card)
    # IO.inspect(response)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://developer.paysafe.com/en/vault/api/#/reference/0/cards/delete-a-card
  def delete_card(profile_id, card_id) do
    endpoint = "#{customer_vault_endpoint()}/#{profile_id}/cards/#{card_id}"
    {:ok, %Tesla.Env{} = response} = Paysafe.delete(endpoint)
    # IO.inspect(response)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  def authorize(payment_token, merchant_ref_num, amount_in_cents, is_initial, settleWithAuth) do
    endpoint = "#{card_payments_endpoint()}/auths"
    occurrence = if is_initial, do: "INITIAL", else: "SUBSEQUENT"

    payment = %{
      card: %{
        paymentToken: payment_token
      },
      merchantRefNum: merchant_ref_num,
      amount: amount_in_cents,
      storedCredential: %{
        type: "RECURRING",
        occurrence: occurrence
      },
      settleWithAuth: settleWithAuth,
      description: "Acme Subscription"
    }

    {:ok, %Tesla.Env{} = response} = Paysafe.post(endpoint, payment)
    # IO.inspect(response)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # https://developer.paysafe.com/en/vault/api/#/reference/0/addresses/get-address
  def get_billing_address(profile_id, billing_address_id) do
    endpoint = "#{customer_vault_endpoint()}/#{profile_id}/addresses/#{billing_address_id}"
    {:ok, %Tesla.Env{} = response} = Paysafe.get(endpoint)
    # IO.inspect(response)

    case response.status do
      200 ->
        {:ok, response.body}

      _code ->
        {:error,
         %{code: response.body["error"]["code"], message: response.body["error"]["message"]}}
    end
  end

  # private helpers
  defp api_endpoint() do
    Application.get_env(:store, :paysafe)[:endpoint] || System.get_env("PAYSAFE_API_ENDPOINT")
  end

  defp username() do
    Application.get_env(:store, :paysafe)[:username] || System.get_env("PAYSAFE_USERNAME")
  end

  defp password() do
    Application.get_env(:store, :paysafe)[:password] || System.get_env("PAYSAFE_PASSWORD")
  end

  defp account_id() do
    Application.get_env(:store, :paysafe)[:account_id] || System.get_env("PAYSAFE_ACCOUNT_ID")
  end

  defp card_payments_endpoint() do
    "#{api_endpoint()}/cardpayments/#{@version}/accounts/#{account_id()}"
  end

  defp customer_vault_endpoint() do
    "#{api_endpoint()}/customervault/#{@version}/profiles"
  end
end
