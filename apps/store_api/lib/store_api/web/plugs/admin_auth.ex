defmodule StoreAPI.Plug.AdminAuth do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    # absinthe / authentication
    case Guardian.Plug.current_resource(conn) do
      nil ->
        handle_unauthenticated(conn)

      {:error, _} ->
        handle_unauthenticated(conn)

      admin_employee ->
        put_private(conn, :absinthe, %{context: %{admin_employee: admin_employee}})
    end
  end

  defp forbidden(conn) do
    error = """
    {"errors": [{"message": "401 Unauthorized"}]}
    """

    conn
    |> send_resp(401, error)
    |> halt()
  end

  defp handle_unauthenticated(conn) do
    case is_insecure?(conn) do
      true -> conn
      false -> forbidden(conn)
    end
  end

  defp is_insecure?(conn) do
    Map.get(conn.params, "query", "graphql")
    |> String.contains?([
      "graphql"
    ])
  end
end
