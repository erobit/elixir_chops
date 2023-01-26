defmodule Mail.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "mail plug"))
    |> Mail.Router.call(opts)
  end
end

defmodule Mail.Router do
  use StoreAPI.Web, :router

  forward("/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox")
end
