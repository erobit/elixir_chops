defmodule Mobile.GraphiQL.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "Mobile graphiql plug"))
    |> Mobile.GraphiQL.Router.call(opts)
  end
end

defmodule Mobile.GraphiQL.Router do
  use StoreAPI.Web, :router

  forward("/", Absinthe.Plug.GraphiQL, schema: StoreAPI.MobileSchema)
end
