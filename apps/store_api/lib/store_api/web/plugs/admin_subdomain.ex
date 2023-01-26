defmodule StoreAPI.Plug.AdminSubdomain do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    subdomain = get_subdomain(conn)
    context_obj = conn.private[:absinthe]

    case context_obj do
      nil ->
        put_private(conn, :absinthe, %{context: %{subdomain: subdomain}})

      obj ->
        put_private(conn, :absinthe, %{
          context: %{subdomain: subdomain, admin_employee: obj.context.admin_employee}
        })
    end
  end

  defp get_subdomain(conn) do
    case get_origin(conn) do
      nil -> nil
      origin -> parse_subdomain(origin.host)
    end
  end

  defp parse_subdomain(host) do
    parts = String.split(host, ".")

    if length(parts) > 1 do
      Enum.at(parts, 0)
    else
      nil
    end
  end

  defp get_origin(conn) do
    origin =
      conn
      |> get_req_header("origin")
      |> Enum.at(0)

    case origin do
      nil -> nil
      "null" -> nil
      origin -> origin |> URI.parse()
    end
  end
end
