defmodule StoreAPI.Plug.MobileAuth do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    # absinthe / authentication    
    case Mobile.Guardian.Plug.current_resource(conn) do
      nil ->
        handle_unauthenticated(conn)

      {:error, _error} ->
        handle_unauthenticated(conn)

      customer ->
        put_private(conn, :absinthe, %{context: %{customer: customer, ip: get_remote_ip(conn)}})
    end
  end

  def get_remote_ip(conn) do
    # Get the remote IP from the X-Forwarded-For header if present, so this
    # works as expected when behind a load balancer
    remote_ips = Plug.Conn.get_req_header(conn, "x-forwarded-for")
    remote_ip = List.first(remote_ips)

    # If there was nothing in X-Forarded-For, use the remote IP directly
    case remote_ip do
      nil ->
        # Extract the remote IP from the connection
        remote_ip_as_tuple = conn.remote_ip

        # The remote IP is a tuple like `{127, 0, 0, 1}`, so we need join it into
        # a string for the API. Note that this works for IPv4 - IPv6 support is
        # exercise for the reader!
        Enum.join(Tuple.to_list(remote_ip_as_tuple), ".")

      remote_ip ->
        remote_ip
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

  # We would really prefer to deal with unauthenticated at the http layer
  # by returning a 401 error which the client will use to clear the token
  # forcing the user to login (see graphql/ApolloClient.js:19)
  # @TODO - we need to write some integration tests around this sucker!!!
  defp handle_unauthenticated(conn) do
    case is_insecure?(conn) do
      true ->
        put_private(conn, :absinthe, %{context: %{ip: get_remote_ip(conn)}})

      false ->
        forbidden(conn)
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
