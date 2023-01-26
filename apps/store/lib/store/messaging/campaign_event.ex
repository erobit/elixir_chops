defmodule Store.Messaging.CampaignEvent do
  use Store.Model

  # @event_types ~w(bounce click)

  schema "campaigns_events" do
    belongs_to(:campaign, Store.Messaging.Campaign)
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)
    field(:type, :string)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %CampaignEvent{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def get(campaign_id, customer_id, location_id, type) do
    from(e in CampaignEvent,
      where:
        e.campaign_id == ^campaign_id and e.customer_id == ^customer_id and
          e.location_id == ^location_id and e.type == ^type
    )
    |> Repo.one()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(campaign_id customer_id location_id type)a)
    |> validate_required(~w(campaign_id customer_id location_id type)a)

    # |> validate_subset(:type, @event_types)
  end
end
