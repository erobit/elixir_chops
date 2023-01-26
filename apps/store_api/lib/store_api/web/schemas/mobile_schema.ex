defmodule StoreAPI.MobileSchema do
  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import_types(StoreAPI.Schema.SharedTypes)
  import_types(StoreAPI.Schema.MobileTypes)
  alias StoreAPI.Resolvers
  import StoreAPI.Helpers.ChangesetHelper

  query do
    field :me, type: :customer do
      resolve(&Resolvers.Customer.me/2)
    end

    field :signature, type: :s3_payload do
      resolve(&Resolvers.S3Signature.sign/2)
    end

    field :discover_locations, type: :locations_paged do
      arg(:options, non_null(:options))
      arg(:lng, :float)
      arg(:lat, :float)
      arg(:radius, :integer)
      arg(:business_type, non_null(:string))
      resolve(&Resolvers.Location.discover_locations/2)
    end

    field :facebook_user_auth, type: :session do
      arg(:facebook_token, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.facebook_user_auth/2))
    end

    field :get_store_page, type: :location do
      arg(:id, non_null(:integer))
      resolve(&Resolvers.Location.get_store_page/2)
    end

    field :customer_exists, type: :result do
      arg(:phone, non_null(:string))
      arg(:email, :string)
      resolve(&Resolvers.Customer.exists/2)
    end

    field :memberships, type: list_of(:membership) do
      resolve(&Resolvers.Membership.memberships/2)
    end

    field :loyalty_card, type: :loyalty_card do
      arg(:location_id, :integer)
      resolve(&Resolvers.Transaction.loyalty_card/2)
    end

    field :customer_reward, type: :customer_reward do
      arg(:id, :integer)
      resolve(&Resolvers.CustomerReward.get/2)
    end

    field :customer_deal, type: :customer_deal do
      arg(:id, :integer)
      resolve(&Resolvers.CustomerDeal.get/2)
    end

    field :coupon_history, type: :coupon_history_paged do
      arg(:options, :options)
      resolve(&Resolvers.Coupon.history/2)
    end

    field :get_coordinates, type: :coordinates do
      arg(:code, :string)
      resolve(&Resolvers.Geocode.get_coordinates/2)
    end

    field :shop, type: :shop_intent do
      arg(:code, non_null(:string))
      resolve(handle_errors(&Resolvers.Referral.shop_intent/2))
    end

    field :locality, type: :locality do
      arg(:lat, :float)
      arg(:lon, :float)
      resolve(&Resolvers.Geocode.get_by_lat_lon/2)
    end

    field :geo_ip, type: :geo_data do
      resolve(&Resolvers.Geocode.ip/2)
    end

    field :get_regions, type: list_of(:region_result) do
      arg(:search, non_null(:string))
      resolve(&Resolvers.Geocode.get_region/2)
    end

    field :refresh, type: :session do
      arg(:token, non_null(:string))
      resolve(handle_errors(&Resolvers.Token.refresh_customer/2))
    end

    field :latest_referral, type: :shop do
      resolve(handle_errors(&Resolvers.Referral.latest/2))
    end

    field :my_review, type: :review do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Review.get_customer_review/2))
    end

    field :get_recommended_rewards, type: list_of(:reward) do
      arg(:lat, :float)
      arg(:lng, :float)
      arg(:radius, :integer)
      resolve(handle_errors(&Resolvers.Reward.get_recommended_rewards/2))
    end

    field :quick_glance_menu, type: list_of(:product) do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.get_quick_glance_menu/2))
    end

    field :products, type: list_of(:product) do
      arg(:location_id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.get_products_by_location_in_stock/2))
    end

    field :products_paged, type: :products_paged do
      arg(:location_id, :integer)
      arg(:options, non_null(:options))
      resolve(handle_errors(&Resolvers.Inventory.get_products_paged/2))
    end

    field :product, type: :product do
      arg(:id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.get_product/2))
    end

    field :pricing_preference, type: :pricing_preference do
      arg(:location_id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.get_pricing_preference/2))
    end

    field :get_favourite_products, type: list_of(:product) do
      resolve(handle_errors(&Resolvers.Inventory.get_favourite_products/2))
    end

    field :get_transaction_after_time, type: :recent_transaction_result do
      arg(:start_time, :integer)
      resolve(handle_errors(&Resolvers.Transaction.get_transaction_after_time/2))
    end

    field :location_loyalty_reward, type: :reward do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Reward.get_location_loyalty_reward/2))
    end

    field :get_customer_details, type: :customer do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Customer.get_customer_details/2))
    end

    field :customer_notes, type: list_of(:customer_note) do
      arg(:customer_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Customer.get_customer_notes/2))
    end

    field :get_reviews, type: list_of(:review) do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Review.get_location_reviews_for_customer/2))
    end
  end

  mutation do
    field :customer_reset, type: :result do
      arg(:phone, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.reset/2))
    end

    field :create_account, type: :session do
      arg(:phone, non_null(:string))
      arg(:code, non_null(:string))
      arg(:email, :string)
      resolve(handle_errors(&Resolvers.Customer.create/2))
    end

    field :sign_in, type: :session do
      arg(:phone, non_null(:string))
      arg(:code, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.sign_in/2))
    end

    field :customer_update, type: :customer do
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:birthdate, :date)
      arg(:email, :string)
      arg(:gender, :string)
      arg(:avatar, :string)
      arg(:notifications_enabled, :boolean)
      arg(:facebook_token, :string)
      arg(:facebook_id, :string)
      arg(:categories, list_of(:integer))
      arg(:fcm_token, :string)
      arg(:confirmation, :boolean)
      arg(:experience_level, :string)
      resolve(handle_errors(&Resolvers.Customer.update/2))
    end

    field :join_shop, type: :customer_reward_result do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Membership.join_shop/2))
    end

    field :leave_shop, type: :result do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Membership.leave_shop/2))
    end

    field :earn_stamp, type: :loyalty_card do
      arg(:location_id, non_null(:integer))
      arg(:qr_code, non_null(:string))
      resolve(handle_errors(&Resolvers.Transaction.earn_stamp/2))
    end

    field :grant_stamp, type: :customer do
      arg(:location_id, non_null(:integer))
      arg(:qr_code, non_null(:string))
      resolve(handle_errors(&Resolvers.Transaction.grant_stamp/2))
    end

    field :add_point, type: :loyalty_card do
      arg(:customer_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Transaction.add_point/2))
    end

    field :remove_point, type: :loyalty_card do
      arg(:customer_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Transaction.remove_point/2))
    end

    field :queue_deal, type: :customer_deal do
      arg(:deal_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Deal.queue/2))
    end

    field :queue_reward, type: :customer_reward do
      arg(:reward_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Reward.queue/2))
    end

    field :queue_customer_reward, type: :customer_reward do
      arg(:reward_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.CustomerReward.queue/2))
    end

    field :redeem_deal, type: :result do
      arg(:deal_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Coupon.redeem_deal/2))
    end

    field :redeem_reward, type: :result do
      arg(:reward_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Coupon.redeem_reward/2))
    end

    field :visit, type: :result do
      arg(:lat, non_null(:float))
      arg(:lng, non_null(:float))
      resolve(handle_errors(&Resolvers.Visit.visit/2))
    end

    field :customer_feedback, type: :customer_feedback do
      arg(:feedback, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.feedback/2))
    end

    field :referral_link, type: :referral_link do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Referral.link/2))
    end

    field :location_notifications, type: :result do
      arg(:location_id, non_null(:integer))
      arg(:is_enabled, non_null(:boolean))
      resolve(handle_errors(&Resolvers.Membership.set_location_notifications/2))
    end

    field :notify, type: :result do
      arg(:lat, non_null(:float))
      arg(:lon, non_null(:float))
      resolve(handle_errors(&Resolvers.Customer.notify/2))
    end

    field :campaign_click, type: :click_result do
      arg(:code, non_null(:string))
      resolve(handle_errors(&Resolvers.Campaign.click/2))
    end

    field :location_review, type: :customer_reward_result do
      arg(:id, :integer)
      arg(:content, :string)
      arg(:rating, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Review.create_review/2))
    end

    field :toggle_favourite_product, type: :result do
      arg(:is_active, non_null(:boolean))
      arg(:product_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.toggle_favourite_product/2))
    end

    field :save_customer_note, type: list_of(:customer_note) do
      arg(:id, :integer)
      arg(:body, :string)
      arg(:flagged, :boolean)
      arg(:customer_id, :integer)
      arg(:location_id, :integer)
      resolve(handle_errors(&Resolvers.Customer.save_note/2))
    end


    field :send_email_verification, type: :result do
      arg(:email, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.send_email_verification/2))
    end

    field :verify_email, type: :result do
      arg(:email, non_null(:string))
      arg(:code, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.verify_email/2))
    end

    field :send_email_recovery, type: :result do
      arg(:email, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.send_email_recovery/2))
    end

    field :verify_recovery, type: :result do
      arg(:old_phone, non_null(:string))
      arg(:new_phone, non_null(:string))
      arg(:code, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.verify_recovery/2))
    end

    field :delete_account, type: :result do
      resolve(handle_errors(&Resolvers.Customer.delete_account/2))
    end
  end
end
