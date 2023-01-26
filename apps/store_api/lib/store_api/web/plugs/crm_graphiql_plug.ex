defmodule Crm.GraphiQL.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "Crm grahpiql plug"))
    |> Crm.GraphiQL.Router.call(opts)
  end
end

defmodule Crm.GraphiQL.Router do
  use StoreAPI.Web, :router

  forward("/", Absinthe.Plug.GraphiQL, schema: StoreAPI.CrmSchema)
end
