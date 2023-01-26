defmodule StoreAPI.Resolvers.Transaction do
  alias Store

  def earn_stamp(%{location_id: location_id, qr_code: qr_code}, %{context: %{customer: customer}}) do
    case Store.earn_stamp(customer.id, location_id, qr_code) do
      {:ok, loyalty_card} -> {:ok, loyalty_card}
      {:error, error} -> {:error, error}
    end
  end

  def grant_stamp(%{location_id: location_id, qr_code: qr_code}, %{context: %{customer: customer}}) do
    profile = Store.get_customer_profile(customer.id)

    location =
      Enum.find(profile.employee_locations, fn l ->
        l.id == location_id
      end)

    case location do
      nil ->
        {:error, "no_longer_part_of_shop"}

      _ ->
        Store.grant_stamp(customer.id, location_id, qr_code)
    end
  end

  def add_point(args, %{context: %{customer: customer}}) do
    case Store.get_employee_by_customer_and_location(customer.id, args.location_id) do
      {:ok, employee} -> add_point(args, %{context: %{employee: employee}})
      e -> e
    end
  end

  def remove_point(args, %{context: %{customer: customer}}) do
    case Store.get_employee_by_customer_and_location(customer.id, args.location_id) do
      {:ok, employee} -> remove_point(args, %{context: %{employee: employee}})
      e -> e
    end
  end

  def loyalty_card(%{location_id: location_id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.loyalty_card(customer.id, location_id) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  def get_transaction_after_time(%{start_time: start_time}, %{context: %{customer: customer}}) do
    Store.Loyalty.get_transaction_after_time_for_customer(start_time, customer.id)
  end

  ######################################
  # CRM & Mobile resolvers
  ######################################
  def add_point(args, %{context: %{employee: employee}}) do
    case Store.add_point(args.customer_id, args.location_id, employee.id) do
      {:ok, card} -> {:ok, card}
      {:error, error} -> {:error, error}
    end
  end

  def remove_point(args, %{context: %{employee: employee}}) do
    case Store.remove_point(args.customer_id, args.location_id, employee.id) do
      {:ok, card} -> {:ok, card}
      {:error, error} -> {:error, error}
    end
  end
end
