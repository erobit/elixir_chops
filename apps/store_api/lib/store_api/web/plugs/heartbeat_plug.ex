defmodule Heartbeat.Plug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> send_resp(200, "I'm alive!")
  end
end
