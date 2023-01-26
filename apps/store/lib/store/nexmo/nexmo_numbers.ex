defmodule Nexmo.Numbers do
  @page_size 20
  @max_concurrency 1

  def get_numbers(size \\ 20, index \\ 0) do
    Process.sleep(1000)
    Nexmo.API.get("/account/numbers", %{size: size, index: index})
  end

  def get_num_records() do
    %HTTPoison.Response{body: body} = get_numbers()
    body.count
  end

  def get_all(country \\ "US") do
    num_records = get_num_records()
    num_pages = div(num_records, @page_size) + 1
    reserved = System.get_env("NEXMO_SMS_NUMBER")

    1..num_pages
    |> Task.async_stream(
      fn page_num ->
        get_numbers(@page_size, page_num)
      end,
      timeout: :infinity,
      max_concurrency: @max_concurrency
    )
    |> Enum.map(fn {:ok, %HTTPoison.Response{body: body}} ->
      Enum.filter(body.numbers, fn number ->
        number.country == country and number.msisdn != reserved
      end)
    end)
    |> Enum.concat()
  end
end
