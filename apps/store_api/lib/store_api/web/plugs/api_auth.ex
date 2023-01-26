defmodule StoreAPI.Plug.APIAuth do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case conn |> get_req_header("authorization") do
      [] -> forbidden(conn)
      token -> validate_token(conn, token)
    end
  end

  defp validate_token(conn, token) do
    <<"Bearer ", token::binary>> = token |> List.first()
    match = System.get_env("PLATFORM_API_KEY")

    if token == match do
      conn
    else
      forbidden(conn)
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
end
