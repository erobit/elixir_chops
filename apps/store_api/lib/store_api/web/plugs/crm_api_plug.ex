defmodule Crm.Api.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "crm api Plug"))
    |> Crm.Api.Router.call(opts)
  end
end

defmodule Crm.Api.Router do
  use StoreAPI.Web, :router

  pipeline :custom do
    plug(StoreAPI.Plug.CrmAuth)
    plug(StoreAPI.Plug.CrmSubdomain)
  end

  pipe_through(CRM.AuthAccessPipeline)
  pipe_through(:custom)

  forward("/csv/products", CrmProducts.Csv.Plug)
  forward("/csv", Crm.Csv.Plug)
  forward("/", Absinthe.Plug, schema: StoreAPI.CrmSchema)
end
