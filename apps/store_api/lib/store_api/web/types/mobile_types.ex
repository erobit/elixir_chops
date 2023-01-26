defmodule StoreAPI.Schema.MobileTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Store.Repo
  import StoreAPI.Schema.SharedTypes

  # Sample
  # https://seanclayton.me/post/phoenix-1-3-and-graphql-with-absinthe/

  @desc """
  Customer Reward
  """
  object :customer_reward do
    field(:id, :integer)
    field(:name, :string)
    field(:type, :string)
    field(:points, :integer)
    field(:expires, :datetime)
    field(:redeemed, :datetime)
    field(:reward_id, :integer)
    field(:customer_id, :integer)
    field(:location_id, :integer)
    field(:inserted_at, :integer)
    field(:reward, :reward)
  end

  @desc """
  Customer Deal
  """
  object :customer_deal do
    field(:id, :integer)
    field(:name, :string)
    field(:expires, :datetime)
    field(:redeemed, :datetime)
    field(:deal_id, :integer)
    field(:customer_id, :integer)
    field(:location_id, :integer)
    field(:inserted_at, :integer)
    field(:deal, :deal)
  end

  @desc """
  Customer Reward Result
  """
  object :customer_reward_result do
    field(:success, :boolean)
    field(:customer_reward, :customer_reward)
    field(:review, :review)
  end

  @desc """
  Loyalty Membership
  """
  object :membership do
    field(:id, :integer)
    field(:business_id, :integer)
    field(:customer_id, :integer)
    field(:locations, list_of(:location), resolve: assoc(:locations))
    field(:customer_deals, list_of(:customer_deal))
    field(:customer_rewards, list_of(:customer_reward))
  end

  @desc """
  Customer reset
  """
  object :reset_customer do
    field(:code, :string)
  end

  object :loyalty_card do
    field(:id, :integer)
    field(:balance, :integer)
    field(:total, :integer)
    field(:customer_reward, :customer_reward)
  end

  @desc """
  Coupon History Paged
  """
  object :coupon_history_paged do
    field(:deals, list_of(:customer_deals_paged))
    field(:rewards, list_of(:customer_rewards_paged))
  end

  object :customer_deals_paged do
    field(:entries, list_of(:customer_deal))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :customer_rewards_paged do
    field(:entries, list_of(:customer_reward))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :customer_feedback do
    field(:customer_id, :integer)
    field(:feedback, :string)
  end

  object :shop do
    field(:id, :integer)
    field(:name, :integer)
  end

  object :referral_link do
    field(:id, :integer)
    field(:customer_id, :integer)
    field(:location_id, :integer)
    field(:url, :string)
  end

  object :shop_intent do
    field(:location_id, :integer)
  end

  object :locality do
    field(:city, :string)
    field(:country, :string)
    field(:state, :string)
    field(:postal, :string)
  end

  object :geo_data do
    field(:city, :string)
    field(:country_code, :string)
    field(:country_name, :string)
    field(:ip, :string)
    field(:latitude, :float)
    field(:longitude, :float)
    field(:metro_code, :integer)
    field(:region_code, :string)
    field(:region_name, :string)
    field(:time_zone, :string)
    field(:zip_code, :string)
  end

  object :click_result do
    field(:location_id, :integer)
    field(:deal_id, :integer)
    field(:success, :boolean)
  end

  object :region_result do
    field(:latitude, :float)
    field(:longitude, :float)
    field(:name, :string)
  end

  object :recent_transaction_result do
    field(:location_id, :integer)
    field(:units, :integer)
    field(:loyalty_card, :loyalty_card)
    field(:memberships, list_of(:membership))
    field(:earned_reward, :customer_reward)
  end
end
