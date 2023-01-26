defmodule Mobile.Api.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "crm api Plug"))
    |> Mobile.Api.Router.call(opts)
  end
end

defmodule Mobile.Api.Router do
  use StoreAPI.Web, :router

  pipeline :custom do
    plug(StoreAPI.Plug.MobileAuth)
  end

  pipe_through(Mobile.AuthAccessPipeline)
  pipe_through(:custom)

  forward("/", Absinthe.Plug, schema: StoreAPI.MobileSchema)
end
