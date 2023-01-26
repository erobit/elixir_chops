defmodule Plivo.Numbers do
  @page_size 20
  @max_concurrency 6

  defp get_numbers(limit \\ 20, offset \\ 0) do
    Plivo.API.get("/Number/", %{limit: limit, offset: offset})
  end

  def get_num_records() do
    %HTTPoison.Response{body: body} = get_numbers()
    body.meta.total_count
  end

  def get_all(type \\ "tollfree", country \\ "United States") do
    num_records = get_num_records()
    num_pages = div(num_records, @page_size) + 1

    1..num_pages
    |> Task.async_stream(
      fn page_num ->
        get_numbers(@page_size, page_num * @page_size)
      end,
      timeout: :infinity,
      max_concurrency: @max_concurrency
    )
    |> Enum.map(fn {:ok, %HTTPoison.Response{body: body}} ->
      Enum.filter(body.objects, fn number ->
        number.active == true and number.sms_enabled == true and number.number_type == type and
          number.country == country
      end)
    end)
    |> Enum.concat()
  end

  def set_alias(phone, name) do
    Plivo.API.post("/Number/#{phone}/", %{alias: name})
  end
end
