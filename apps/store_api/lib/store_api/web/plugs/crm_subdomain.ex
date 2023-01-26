defmodule StoreAPI.Plug.CrmSubdomain do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    error = """
    {"errors": [{"message": "401 Unauthorized"}]}
    """

    employee =
      case CRM.Guardian.Plug.current_resource(conn) do
        nil -> nil
        employee -> employee
      end

    case get_subdomain(conn, employee) do
      nil ->
        conn
        # let's 401 the login page
        |> send_resp(401, error)
        |> halt()

      subdomain ->
        conn
        |> put_private(:absinthe, %{context: %{employee: employee, subdomain: subdomain}})
    end
  end

  defp get_subdomain(conn, employee) do
    # get the subdomain of the request (origin) - will be nil for graphql
    subdomain =
      case get_origin(conn) do
        nil -> nil
        origin -> parse_subdomain(origin.host)
      end

    # auth plug has already run, so employee should be set as long as they
    # are not hitting the login route. Get the users' subdomain from their token
    user_subdomain =
      case employee do
        nil -> subdomain
        employee -> employee.business.subdomain
      end

    env = Application.get_env(:store_api, :environment)

    case has_subdomain_mismatch?(subdomain, user_subdomain, env) do
      true -> nil
      false -> user_subdomain || subdomain || "toke"
    end
  end

  # Valid Conditions - we want to return the proper subdomain
  # 1 - User subdomain is empty because they are logging in and don't have a token
  # 2 - Subdomain is empty because query is coming from graphql client without origin
  # 3 - Both are nil because we are logging in from graphql without origin or token

  # Use case #1: User does not have a valid request origin subdomain or a valid token subdomain
  # Throw a 401 as we cannot allow authenticated requests through that do not come from an origin subdomain
  defp has_subdomain_mismatch?(nil, nil, _) do
    true
  end

  # Use case #2: User does not have a valid request origin subdomain but does have a valid token subdomain
  # edge conditions for graphql queries on dev and test environments
  defp has_subdomain_mismatch?(nil, _user_subdomain, :test), do: false
  defp has_subdomain_mismatch?(nil, _user_subdomain, :dev), do: false

  # Use case #3: User does not have a valid request origin subdomain but does have a valid token subdomain
  # Throw a 401 as we want them to login to a subdomain
  defp has_subdomain_mismatch?(nil, _user_subdomain, _) do
    true
  end

  # Use case #4
  # If the subdomain (request) and the user_subdomain (token) are not nil and
  # are different, we should 401 the fuck out as the token is for a different
  # subdomain and they should re-auth, otherwise business as usual
  defp has_subdomain_mismatch?(subdomain, user_subdomain, _)
       when not is_nil(subdomain) and not is_nil(user_subdomain) do
    subdomain != user_subdomain
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
