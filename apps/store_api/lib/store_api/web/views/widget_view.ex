defmodule StoreAPI.Web.WidgetView do
  use StoreAPI.Web, :view

  def render("index.json", %{reward: reward}) do
    case reward do
      nil -> %{reward_name: nil}
      _ -> %{reward_name: reward.name}
    end
  end

  def render("joined.json", %{result: result}) do
    result
  end
end
