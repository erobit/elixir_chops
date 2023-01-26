defmodule Brightlink.Numbers do
  @page_size 10000

  def get_numbers(size \\ 10000, index \\ 0) do
    # Process.sleep(1000)

    data = %{
      paginationData: %{
        pageNo: index,
        resultCount: size
      },
      searchColumn: %{
        assignedNumber: "Active",
        availableNumber: "Available",
        sortColumnName: "CUSTOMER",
        accending: "true"
      }
    }

    Brightlink.CPAAS.API.post("/did/numbers", data)
  end

  def get_num_records() do
    %HTTPoison.Response{body: body} = get_numbers()
    body["numberTotalCount"]
  end

  def get_all() do
    reserved = System.get_env("SMS_DEFAULT_NUMBER")
    %HTTPoison.Response{body: body} = get_numbers(@page_size, 0)

    numbers =
      case Map.has_key?(body, "numbers") do
        true -> body["numbers"]
        false -> []
      end

    Enum.filter(numbers, fn number ->
      Integer.to_string(number["didNumber"]) != reserved
    end)
    |> Enum.map(fn number -> Integer.to_string(number["didNumber"]) end)
  end
end
