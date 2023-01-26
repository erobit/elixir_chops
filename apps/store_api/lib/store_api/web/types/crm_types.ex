defmodule StoreAPI.Schema.CrmTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Store.Repo
  import StoreAPI.Schema.SharedTypes
  import_types(Absinthe.Type.Custom)

  # Sample
  # https://seanclayton.me/post/phoenix-1-3-and-graphql-with-absinthe/

  @desc """
  Store Member
  """
  object :membership do
    field(:id, :integer)
    field(:business_id, :integer)
    field(:customer_id, :integer)
  end

  @desc """
  Business Employees paged
  """
  object :employees_paged do
    field(:entries, list_of(:employee))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  @desc """
  Store Customers paged
  """
  object :customers_paged do
    field(:entries, list_of(:customer))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  @desc """
  Store Customer Segments paged
  """
  object :customer_segments_paged do
    field(:entries, list_of(:customer))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :loyalty_card do
    field(:balance, :integer)
    field(:total, :integer)
  end

  @desc """
  Deals paged
  """
  object :deals_paged do
    field(:entries, list_of(:deal))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  @desc """
  Campaign
  """
  object :campaign do
    field(:id, :integer)
    field(:business_id, :integer)
    field(:message, :string)
    field(:send_now, :boolean)
    field(:send_date, :string)
    field(:send_time, :string)
    field(:groups, list_of(:member_group))
    field(:categories, list_of(:category))
    field(:products, list_of(:product))
    field(:location, :location)
    field(:location_id, :integer)
    field(:clicks, :integer)
    field(:deal, :deal)
    field(:survey, :survey)
    field(:bounces, :integer)
    field(:reach, :integer)
    field(:ctr, :integer)
    field(:visits, :integer)
    field(:is_active, :boolean)
  end

  @desc """
  Campaigns paged
  """
  object :campaigns_paged do
    field(:entries, list_of(:campaign))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  @desc """
  Campaign Report (sms_log)
  """
  object :campaign_report do
    field(:id, :integer)
    field(:customer, :customer)
    field(:location_id, :integer)
    field(:error_message, :string)
    field(:error_code, :integer)
    field(:status, :string)
    field(:location_sms_enabled, :boolean)
  end

  @desc """
  Campaign Reports paged (sms_log paged)
  """
  object :campaign_report_paged do
    field(:entries, list_of(:campaign_report))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  @desc """
  MemberGroup
  """
  object :member_group do
    field(:id, :integer)
    field(:name, :string)
  end

  @desc """
  Province
  https://github.com/substack/provinces
  """
  object :province do
    field(:name, :string)
    field(:country, :string)
    field(:short, :string)
    field(:alt, :string)
    field(:region, :string)
  end

  # Note: Schema resolvers for mutations complain with embedded
  # types if we do not use input_objects
  input_object :daily_hours_input do
    field(:weekday, non_null(:string))
    field(:start, non_null(:string))
    field(:end, non_null(:string))
    field(:closed, non_null(:boolean))
  end

  input_object :days_of_week_input do
    field(:weekday, non_null(:string))
    field(:active, non_null(:boolean))
  end

  input_object :sms_settings_input do
    field(:id, :integer)
    field(:location_id, :integer)
    field(:provider, non_null(:string))
    field(:phone_number, non_null(:string))
    field(:max_sms, non_null(:integer))
    field(:send_distributed, non_null(:boolean))
    field(:distributed_uuid, :string)
  end

  object :geo_address do
    field(:address, non_null(:string))
    field(:street, non_null(:string))
    field(:city, non_null(:string))
    field(:country, non_null(:string))
    field(:state, non_null(:string))
    field(:postal, non_null(:string))
    field(:lat, non_null(:float))
    field(:lng, non_null(:float))
  end

  object :qr_code do
    field(:qr_code, :string)
  end

  object :dashboard_metrics do
    field(:signups, :integer)
    field(:visits, :integer)
    field(:stamps, :integer)
    field(:deals, :integer)
    field(:rewards, :integer)
    field(:referrals, :integer)
    field(:total, :integer)
    field(:sms, :integer)
    field(:surveys_sent, :integer)
    field(:surveys_submitted, :integer)
    field(:reviews_submitted, :integer)
    field(:reviews_average, :integer)
  end

  object :tablet do
    field(:name, :string)
    field(:tablet, :string)
  end

  object :customer_metrics do
    field(:all, :integer)
    field(:loyal, :integer)
    field(:casual, :integer)
    field(:lapsed, :integer)
    field(:last_mile, :integer)
    field(:hoarders, :integer)
    field(:spenders, :integer)
    field(:referrals, :integer)
    field(:birthdays, :integer)
    field(:no_shows, :integer)
  end

  object :send_stats do
    field(:max_sms, :integer)
    field(:sent_this_month, :integer)
    field(:number_to_send, :integer)
  end

  object :metric do
    field(:id, :integer)
    field(:created, :integer)
    field(:value, :integer)
  end

  object :referral do
    field(:recipient_phone, :string)
    field(:is_completed, :boolean)
    field(:business_id, :integer)
    field(:location_id, :integer)
    field(:from_customer_id, :integer)
    field(:to_customer_id, :integer)
  end

  object :shop do
    field(:name, :string)
    field(:logo, :string)
    field(:reward, :string)
  end

  object :reviews_paged do
    field(:entries, list_of(:review))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :review_setting do
    field(:enabled, :boolean)
    field(:business_id, :integer)
  end

  object :surveys_paged do
    field(:entries, list_of(:survey))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :survey do
    field(:id, :integer)
    field(:is_active, :boolean)
    field(:name, :string)
    field(:content, :string)
    field(:submissions, :integer)
    field(:inserted_at, :integer)
  end

  object :survey_submission do
    field(:id, :integer)
    field(:answers, :string)
    field(:inserted_at, :integer)
    field(:customer, :customer)
  end

  object :survey_submissions_paged do
    field(:entries, list_of(:survey_submission))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :product_integration do
    field(:id, :integer)
    field(:client_id, :integer)
    field(:location_id, :integer)
    field(:ext_location_id, :integer)
    field(:name, :string)
    field(:api_key, :string)
    field(:is_active, :boolean)
  end

  object :product_sync_items_paged do
    field(:entries, list_of(:product_sync_item))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :product_sync_item do
    field(:id, :integer)
    field(:name, :string)
    field(:category, :category)
    field(:description, :string)
    field(:thumb_image, :string)
    field(:type, :string)
    field(:is_active, :boolean)
    field(:in_stock, :boolean)
  end

  object :tfn do
    field(:number, :string)
  end

  object :billing_profile do
    field(:id, :integer)
    field(:payment_type, :string)
    field(:billing_start, :integer)
    field(:billing_credit, :decimal)
    field(:billing_amount, :decimal)
    field(:cards, list_of(:billing_card))
  end

  object :billing_trial_period do
    field(:location_id, :integer)
    field(:days_left, :integer)
    field(:name, :string)
    field(:billing_start, :date)
  end

  object :billing_card do
    field(:id, :integer)
    field(:last_digits, :string)
    field(:type, :string)
    field(:expiry_month, :integer)
    field(:expiry_year, :integer)
    field(:status, :string)
    field(:is_default, :boolean)
    field(:address, :address)
  end

  object :address do
    field(:street, :string)
    field(:street2, :string)
    field(:city, :string)
    field(:zip, :string)
    field(:country, :string)
    field(:state, :string)
  end

  scalar :map do
    description("Converts Keyword List to Map")

    serialize(fn keywordList ->
      StoreAPI.Utility.KeywordListToMap.convert_keyword_list_to_map(keywordList)
      |> Poison.encode!()
    end)
  end

  object :notification do
    field(:id, :integer)
    field(:type, :string)
    field(:is_read, :boolean)
    field(:is_deleted, :boolean)
    field(:metadata, :map)
    field(:employee, :employee)
    field(:location, :location)
    field(:inserted_at, :integer)
  end

  object :notifications_paged do
    field(:entries, list_of(:notification))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :notification_preference do
    # notification type
    field(:id, :string)
    field(:disabled, :boolean)
  end

  object :notification_count do
    field(:id, :integer)
    field(:count, :integer)
  end

  input_object :tier do
    field(:id, :integer)
    field(:unit_price, :float)
  end
end
