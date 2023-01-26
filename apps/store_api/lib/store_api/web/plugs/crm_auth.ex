defmodule StoreAPI.Plug.CrmAuth do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    # absinthe / authentication
    case CRM.Guardian.Plug.current_resource(conn) do
      nil ->
        handle_unauthenticated(conn)

      employee ->
        put_private(conn, :absinthe, %{context: %{employee: employee}})
    end
  end

  # We would really prefer to deal with unauthenticated at the http layer
  # by returning a 401 error which the client will use to clear the token
  # forcing the user to login (see graphql/ApolloClient.js:19)
  # @TODO - we need to write some integration tests around this sucker!!!
  defp handle_unauthenticated(conn) do
    error = """
    {"errors": [{"message": "401 Unauthorized"}]}
    """

    case is_insecure?(conn) do
      true ->
        conn

      false ->
        conn
        |> send_resp(401, error)
        |> halt()
    end
  end

  # Note: this is a little bit hackish - need to ensure no other queries contain
  # the login( string which is quite whack, otherwise they could exploit this
  # @TODO - convert this into a regular expression to properly match the
  # login graphql mutation for login
  defp is_insecure?(conn) do
    Map.get(conn.params, "query", "graphql")
    |> String.contains?([
      "graphql"
    ])
  end
end
