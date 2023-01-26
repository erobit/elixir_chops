defmodule Admin.Api.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "admin api Plug"))
    |> Admin.Api.Router.call(opts)
  end
end

defmodule Admin.Api.Router do
  use StoreAPI.Web, :router

  pipeline :custom do
    plug(StoreAPI.Plug.AdminAuth)
    plug(StoreAPI.Plug.AdminSubdomain)
  end

  pipe_through(Admin.AuthAccessPipeline)
  pipe_through(:custom)

  forward("/", Absinthe.Plug, schema: StoreAPI.AdminSchema)
end
