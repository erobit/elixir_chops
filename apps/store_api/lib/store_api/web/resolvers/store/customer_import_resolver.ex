defmodule StoreAPI.Resolvers.CustomerImport do
  alias Store

  ### Mutations

  def validate({customer, line_number}) do
    case Map.has_key?(customer, "phone") do
      true ->
        phone =
          case Enum.join(Regex.scan(~r/\d+/, customer["phone"])) do
            nil ->
              raise "Phone Number Missing on Line #{line_number + 2}"

            phone ->
              case String.length(phone) do
                11 -> phone
                10 -> "1#{phone}"
                _ -> raise "Invalid Phone Number on Line #{line_number + 2}"
              end
          end

        %{
          "phone" => phone,
          "first_name" => Map.get(customer, "first_name", ""),
          "last_name" => Map.get(customer, "last_name", ""),
          "email" => Map.get(customer, "email", "")
        }

      false ->
        raise "CSV is missing a \"phone\" column."
    end
  end

  def import(import_data, %{context: %{employee: employee}}) do
    case Store.Location.get_by_business_id(import_data.location_id, employee.business_id) do
      # Ensure no bamboozles from hackers try'na change the location_id :)
      nil ->
        {:error, "You shall not pass"}

      _ ->
        import_data
        |> Map.put(:employee_id, employee.id)
        |> do_import()
    end
  end

  def import(import_data, %{context: %{admin_employee: admin}}) do
    if StoreAdmin.in_role?(admin, "super") do
      do_import(import_data)
    else
      {:error, "Invalid"}
    end
  end

  def do_import(import_data) do
    try do
      customers =
        File.stream!(import_data.customers.path)
        |> CSV.decode!(headers: true)
        |> Enum.with_index()
        |> Enum.map(&validate/1)

      import_data =
        Map.put(
          import_data,
          :customers,
          Enum.map(customers, fn c ->
            "#{c["first_name"]},#{c["last_name"]},#{c["phone"]},#{c["email"]}"
          end)
        )

      {:ok, %{id: id, results: results}} = Store.import_customers(import_data)
      {:ok, %{success: true, id: id, imported: results.imported, failed: results.failed}}
    rescue
      e ->
        {:error, Map.get(e, :message, "Unknown Error Occured")}
    end
  end

  def results(%{id: id}, %{context: %{admin_employee: admin}}) do
    if StoreAdmin.in_role?(admin, "super") do
      {:ok, results} = Store.import_results(id)

      sending =
        Enum.filter(results, fn result ->
          result.status in ["accepted", "queued", "sending", "sent"]
        end)

      delivered = Enum.filter(results, fn result -> result.status == "delivered" end)
      failed = Enum.filter(results, fn result -> result.status == "failed" end)
      undelivered = Enum.filter(results, fn result -> result.status == "undelivered" end)
      {:ok, %{sending: sending, delivered: delivered, failed: failed, undelivered: undelivered}}
    else
      {:error, "Invalid"}
    end
  end
end
