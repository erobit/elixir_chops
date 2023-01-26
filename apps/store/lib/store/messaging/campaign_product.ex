defmodule Store.Messaging.CampaignProduct do
  use Store.Model

  schema "campaigns_products" do
    field(:campaign_id, :integer)
    field(:product_id, :integer)
  end

  def delete_by_product_ids(product_ids) do
    from(p in CampaignProduct, where: p.product_id in ^product_ids)
    |> Repo.delete_all()
  end
end
