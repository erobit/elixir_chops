defmodule StoreAPI.Web.WidgetController do
  use StoreAPI.Web, :controller

  def index(conn, params) do
    {location_id, _} = Integer.parse(params["location_id"])
    reward = Store.Loyalty.get_signup_reward(location_id)
    render(conn, "index.json", reward: reward)
  end

  def submit(conn, params) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    customer = Poison.decode!(body)
    {location_id, _} = Integer.parse(params["location_id"])

    case Store.widget_opt_in(
           %{
             phone: customer["phone"],
             first_name: customer["first_name"],
             last_name: customer["last_name"]
           },
           location_id
         ) do
      {:ok, r} -> render(conn, "joined.json", result: %{joined: r.joined})
      {:error, e} -> render(conn, "joined.json", result: %{error: e})
    end
  end
end
