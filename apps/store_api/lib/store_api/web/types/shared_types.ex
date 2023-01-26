defmodule StoreAPI.Schema.SharedTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Store.Repo

  # Sample
  # https://seanclayton.me/post/phoenix-1-3-and-graphql-with-absinthe/

  # This file to be used to store shared types so that we do not duplicate
  # types between the Crm and Mobile graphql schemas - keeping it DRY!!!

  @desc """
  Business Employee
  """
  object :employee do
    field(:id, :integer)
    field(:business_id, :integer)
    field(:email, :string)
    field(:customer, :customer_sanitized)
    field(:phone, :string)
    field(:role, :string)
    field(:password, :string)
    field(:is_active, :boolean)
    field(:locations, list_of(:location), resolve: assoc(:locations))
  end

  @desc """
  Business Employee / Customer
  """
  object :employee_customer do
    field(:customer, :customer)
    field(:email, :string)
    field(:phone, :string)
    field(:role, :string)
  end

  @desc """
  Business is the top level entity for a store
  """
  object :business do
    field(:id, :integer)
    field(:type, :string)
    field(:name, :string)
    field(:subdomain, :string)
    field(:is_verified, :boolean)
    field(:is_active, :boolean)
    field(:country, :string)
    field(:language, :string)
    field(:inserted_at, :integer)
  end

  @desc """
  Customer of a dispensary
  """
  object :customer do
    field(:id, :integer)
    field(:phone, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:email_verified, :boolean)
    field(:gender, :string)
    field(:birthdate, :date)
    field(:birthdate_verified, :boolean)
    field(:avatar, :string)
    field(:facebook_token, :string)
    field(:facebook_id, :string)
    field(:qr_code, :string)
    field(:employee_locations, list_of(:location))
    field(:categories, list_of(:category))
    field(:products, list_of(:product))
    field(:stamps, :integer)
    field(:visits, :integer)
    field(:last_visit, :string)
    field(:first_visit, :string)
    field(:experience_level, :string)
    field(:rewards_claimed, :integer)
    field(:rewards_unclaimed, :integer)
    field(:notifications_enabled, :boolean)
    field(:opted_out, :boolean)
  end

  @desc """
  Customer Note Metadata
  """
  object :customer_note_metadata do
    field(:count, :integer)
    field(:reward_name, :string)
  end

  @desc """
  Customer Note
  """
  object :customer_note do
    field(:id, :integer)
    field(:body, :string)
    field(:type, :string)
    field(:metadata, :customer_note_metadata)
    field(:flagged, :boolean)
    field(:customer, :customer)
    field(:customer_id, :integer)
    field(:location, :location)
    field(:location_id, :integer)
    field(:employee, :employee)
    field(:inserted_at, :integer)
  end

  @desc """
  Customer of a dispensary, sanitized due to potential exploitation.
  """
  object :customer_sanitized do
    field(:id, :integer)
  end

  @desc """
  Business Location
  """
  object :location do
    field(:id, :integer)
    field(:business_id, :integer)
    field(:business, :business)
    field(:name, :string)
    field(:address, :string)
    field(:address_line2, :string)
    field(:city, :string)
    field(:province, :string)
    field(:postal_code, :string)
    field(:country, :string)
    field(:phone, :string)
    field(:email, :string)
    field(:website_url, :string)
    field(:facebook_url, :string)
    field(:instagram_url, :string)
    field(:youtube_url, :string)
    field(:twitter_url, :string)
    field(:menu_url, :string)
    field(:about, :string)
    field(:hero, :string)
    field(:logo, :string)
    field(:rating, :float)
    field(:rating_count, :integer)
    field(:point, :point)
    field(:polygon, :polygon)
    field(:deals, list_of(:deal))
    field(:rewards, list_of(:reward))
    field(:hours, list_of(:daily_hours))
    field(:is_active, :boolean)
    field(:service_types, list_of(:string))
    field(:is_member, :boolean)
    field(:customer_has_earned_stamp, :boolean)
    field(:timezone, :timezone_object)
    field(:notifications_enabled, :boolean)
    field(:sms_settings, :sms_settings)
  end

  @desc """
  Condition
  """
  object :condition do
    field(:id, :integer)
    field(:name, :string)
  end

  @desc """
  Locations paged
  """
  object :locations_paged do
    field(:entries, list_of(:location))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  object :shop_opt do
    field(:shop_name, :string)
    field(:background_color, :string)
    field(:background_image, :string)
    field(:foreground_color, :string)
  end

  @desc """
  SMS setting
  """
  object :sms_settings do
    field(:id, :integer)
    field(:location_id, :integer)
    field(:provider, :string)
    field(:phone_number, :string)
    field(:max_sms, :integer)
    field(:send_distributed, :boolean)
    field(:distributed_uuid, :string)
  end

  @desc """
  Reward
  """
  object :reward do
    field(:id, :integer)
    field(:business_id, :integer)
    field(:location_id, :integer)
    field(:location, :location)
    field(:name, :string)
    field(:type, :string)
    field(:points, :integer)
    field(:is_active, :boolean)
    field(:inserted_at, :integer)
    field(:categories, list_of(:category), resolve: assoc(:categories))
  end

  @desc """
  Inventory Category
  """
  object :category do
    field(:id, :integer)
    field(:name, :string)
  end

  @desc """
  Inventory Product
  """
  object :product do
    field(:id, :integer)
    field(:name, :string)
    field(:description, :string)
    field(:sync_item_id, :integer)
    field(:image, :string)
    field(:type, :string)
    field(:category, :category)
    field(:location, :location)
    field(:is_active, :boolean)
    field(:in_stock, :boolean)
    field(:tier, :pricing_tier)
    field(:is_favourite, :boolean)
    field(:basic_tier, :pricing_tier)
    field(:tier_id, :integer)
    field(:preference, :pricing_preference)
  end

  @desc """
  Inventory Products paged
  """
  object :products_paged do
    field(:entries, list_of(:product))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  @desc """
  Inventory Pricing Tier
  """
  object :pricing_tier do
    field(:id, :integer)
    field(:name, :string)
    field(:is_active, :boolean)
    field(:unit_price, :float)
  end

  @desc """
  Inventory Pricing Preference
  """
  object :pricing_preference do
    field(:id, :integer)
    field(:is_basic, :boolean)
  end

  @desc """
  Business Deal
  """
  object :deal do
    field(:id, :integer)
    field(:name, :string)
    field(:business_id, :integer)
    field(:start_time, :string)
    field(:end_time, :string)
    field(:expiry, :string)
    field(:frequency_type, :string)
    field(:is_active, :boolean)
    field(:days_of_week, list_of(:days_of_week))
    field(:inserted_at, :integer)
    field(:claims, :integer)
    field(:location, :location)
    field(:location_id, :integer)
    field(:categories, list_of(:category), resolve: assoc(:categories))
  end

  @desc """
  Deal days of week
  """
  object :days_of_week do
    field(:weekday, :string)
    field(:active, :boolean)
  end

  @desc """
  Location operating hours
  """
  object :daily_hours do
    field(:weekday, :string)
    field(:start, :string)
    field(:end, :string)
    field(:closed, :boolean)
  end

  @desc """
  Timezone object stored on locations
  """
  object :timezone_object do
    field(:id, :string)
    field(:name, :string)
    field(:dst_offset, :integer)
    field(:raw_offset, :integer)
  end

  @desc """
  Employee session object
  """
  object :session do
    field(:token, :string)
  end

  @desc """
  Simple result of an operation
  """
  object :result do
    field(:success, :boolean)
    field(:id, :integer)
  end

  @desc """
  Validate api result
  """
  object :validate_api do
    field(:success, :boolean)
    field(:locations, list_of(:api_location))
  end

  object :api_location do
    field(:id, :integer)
    field(:name, :string)
  end

  @desc """
  Employee reset
  """
  object :reset do
    field(:id, :string)
    field(:email, :string)
    field(:strength, :strength)
  end

  @desc """
  Password strength
  """
  object :strength do
    field(:score, :integer)
    field(:message, :string)
  end

  @desc """
  AWS Auth V4 payload
  """
  object :s3_payload do
    field(:key, :string)
    field(:content_type, :string)
    field(:acl, :string)
    field(:action, :string)
    field(:bucket, :string)
    field(:access_key, :string)
    field(:policy, :string)
    field(:signature, :string)
    field(:date, :string)
    field(:credential, :string)
    field(:timestamp, :string)
  end

  object :coordinates do
    field(:lat, :float)
    field(:lng, :float)
  end

  object :review do
    field(:id, :integer)
    field(:content, :string)
    field(:rating, :integer)
    field(:is_yours, :boolean)
    field(:customer, :customer)
    field(:completed, :boolean)
    field(:location, :location)
    field(:location_id, :integer)
    field(:inserted_at, :integer)
  end

  input_object :options do
    field(:search, :string)
    field(:filters, list_of(:filter))
    field(:sort, :sorter)
    field(:page, :pager)
  end

  @desc """
  Customer Import Result
  """
  object :customer_import_results do
    field(:success, :boolean)
    field(:id, :integer)
    field(:imported, list_of(:customer))
    field(:failed, list_of(:customer))
  end

  input_object :filter do
    field(:field, :string)
    field(:args, list_of(:string))
  end

  input_object :sorter do
    field(:field, :string)
    field(:order, :integer)
  end

  input_object :pager do
    field(:offset, non_null(:integer))
    field(:limit, non_null(:integer))
  end

  input_object :crs_properties do
    field(:name, :string)
  end

  input_object :crs do
    field(:type, :string)
    field(:properties, :crs_properties)
  end

  input_object :polygon_in do
    field(:type, :string)
    field(:coordinates, list_of(list_of(list_of(:float))))
    field(:crs, :crs)
  end

  input_object :customer_opt_in do
    field(:phone, :string)
    field(:categories, list_of(:integer))
  end

  # custom scalar types
  scalar :point, name: "Point" do
    description("""
    The `Point` scalar type represents a Geo.Geometry Point object from the
    https://github.com/bryanjos/geo library.
    """)

    serialize(fn point ->
      point =
        case point do
          %Geo.Point{} -> point
          _ -> Geo.WKB.decode!(point)
        end

      Geo.JSON.encode!(point)
    end)

    parse(&parse_geo/1)
  end

  # custom scalar types
  scalar :polygon, name: "Polygon" do
    description("""
    The `Point` scalar type represents a Geo.Geometry Polygon object from the
    https://github.com/bryanjos/geo library.
    """)

    serialize(&Geo.JSON.encode!/1)
    parse(&parse_geo/1)
  end

  defp parse_geo(geometry) do
    geometry
    |> Poison.decode!()
    |> Geo.JSON.decode()
  end
end
