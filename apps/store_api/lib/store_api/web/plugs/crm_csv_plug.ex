defmodule Crm.Csv.Plug do
  alias Store
  import Plug.Conn

  def init(opts), do: opts

  defp first_ip(ips) do
    case String.split(ips, ",") do
      [ip] -> ip
      [ip, _proxy_ip] -> ip
    end
  end

  defp valid_ip(ip) do
    re =
      ~r/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/

    case Regex.match?(re, ip) do
      true -> ip
      false -> nil
    end
  end

  def call(conn, _opts) do
    employee = conn.private[:absinthe][:context][:employee]

    case Store.use_customer_export_token(conn.params["token"]) do
      nil ->
        conn
        |> send_resp(400, Poison.encode!(%{message: "error_expired"}))

      authorizing_token ->
        type = Map.get(authorizing_token, :customer_export_type)
        business_id = Map.get(authorizing_token, :business_id)

        case business_id == employee.business_id do
          false ->
            conn
            |> send_resp(400, Poison.encode!(%{message: "Nice try buddy."}))

          true ->
            ip =
              case get_req_header(conn, "x-forwarded-for") do
                [proxy_ip] -> proxy_ip |> first_ip |> valid_ip
                _ -> conn.remote_ip |> Tuple.to_list() |> Enum.join(".") |> valid_ip
              end

            Store.log_customer_export(ip, type, employee.id)

            location_ids =
              Enum.map(Enum.filter(employee.locations, fn l -> l.is_active end), fn l -> l.id end)

            customers =
              StoreMetrics.customer_segments(
                employee.business_id,
                location_ids,
                %{options: nil},
                String.to_atom(type)
              )

            fields = ~w(id phone first_name last_name email stamps visits last_visit)

            csv_content =
              customers
              |> Enum.map(fn c ->
                c = Map.take(c, Enum.map(fields, &String.to_atom/1))
                Map.merge(%Store.Customer{}, c)
              end)
              |> Enum.map(fn m -> [m] end)
              |> CSV.encode()
              |> Enum.to_list()

            head = Enum.join(fields, ",") <> ",\r\n"
            csv = [head | csv_content]

            filename = "customers-#{type}"

            conn
            |> put_resp_content_type("text/csv")
            |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
            |> send_resp(200, csv)
        end
    end
  end
end
