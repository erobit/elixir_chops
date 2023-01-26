defmodule StoreAPI.CrmSchema do
  use Absinthe.Schema
  import_types(Absinthe.Plug.Types)
  import_types(StoreAPI.Schema.SharedTypes)
  import_types(StoreAPI.Schema.CrmTypes)
  alias StoreAPI.Resolvers
  import StoreAPI.Helpers.ChangesetHelper

  query do
    field :me, type: :employee_customer do
      resolve(&Resolvers.Employee.me/2)
    end

    field :business, type: :business do
      resolve(&Resolvers.Business.get/3)
    end

    field :location, type: :location do
      arg(:id, non_null(:integer))
      resolve(&Resolvers.Location.get_location/3)
    end

    field :locations, type: :locations_paged do
      arg(:options, non_null(:options))
      resolve(&Resolvers.Location.get_locations/3)
    end

    field :reviews, type: :reviews_paged do
      arg(:options, non_null(:options))
      arg(:location_id, non_null(:integer))
      resolve(&Resolvers.Review.get_location_reviews/3)
    end

    field :location_names, list_of(:location) do
      resolve(&Resolvers.Location.get_locations_for_employee/2)
    end

    field :employees, type: :employees_paged do
      arg(:options, non_null(:options))
      resolve(&Resolvers.Employee.get_employees/3)
    end

    field :deal, type: :deal do
      arg(:id, non_null(:integer))
      resolve(&Resolvers.Deal.get_deal/2)
    end

    field :deals, type: :deals_paged do
      arg(:options, non_null(:options))
      arg(:location_id, non_null(:integer))
      resolve(&Resolvers.Deal.get_deals/3)
    end

    field :campaign, type: :campaign do
      arg(:id, non_null(:integer))
      resolve(&Resolvers.Campaign.get_campaign/2)
    end

    field :campaigns, type: :campaigns_paged do
      arg(:options, non_null(:options))
      arg(:location_id, non_null(:integer))
      resolve(&Resolvers.Campaign.get_campaigns/3)
    end

    field :campaign_report_paged, type: :campaign_report_paged do
      arg(:campaign_id, non_null(:integer))
      arg(:options, non_null(:options))
      resolve(&Resolvers.Campaign.get_campaign_reports/2)
    end

    field :campaign_customer_count, type: :result do
      arg(:categories, non_null(list_of(:integer)))
      arg(:location_id, non_null(:integer))
      arg(:groups, non_null(list_of(:integer)))
      arg(:products, list_of(:integer))

      resolve(handle_errors(&Resolvers.Campaign.customer_count/2))
    end

    field :member_groups, type: list_of(:member_group) do
      resolve(&Resolvers.MemberGroup.get_member_groups/2)
    end

    field :rewards, type: list_of(:reward) do
      resolve(&Resolvers.Reward.get_rewards/3)
    end

    field :geocode, type: :geo_address do
      arg(:address, non_null(:string))
      resolve(&Resolvers.Geocode.get_locality/3)
    end

    field :signature, type: :s3_payload do
      resolve(&Resolvers.S3Signature.sign/2)
    end

    field :categories, list_of(:category) do
      resolve(&Resolvers.Inventory.get_categories/2)
    end

    field :get_reset, type: :reset do
      arg(:id, non_null(:string))
      resolve(&Resolvers.Employee.get_reset/2)
    end

    field :get_qr_code, type: :qr_code do
      arg(:location_id, non_null(:string))
      resolve(&Resolvers.Location.get_qr_code/2)
    end

    field :dashboard, type: :dashboard_metrics do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.metric_counts/2))
    end

    field :dashboard_signups, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.signup_metrics/2))
    end

    field :dashboard_visits, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.visit_metrics/2))
    end

    field :dashboard_stamps, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.stamp_metrics/2))
    end

    field :dashboard_deals, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.deal_metrics/2))
    end

    field :dashboard_rewards, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.reward_metrics/2))
    end

    field :dashboard_referrals, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.referral_metrics/2))
    end

    field :dashboard_totals, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.total_metrics/2))
    end

    field :dashboard_sms, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.sms_metrics/2))
    end

    field :dashboard_surveys_sent, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.surveys_sent_metrics/2))
    end

    field :dashboard_surveys_submitted, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.surveys_submitted_metrics/2))
    end

    field :dashboard_reviews_submitted, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.reviews_submitted_metrics/2))
    end

    field :dashboard_reviews_average, type: list_of(:metric) do
      arg(:period, non_null(:string))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Dashboard.reviews_average_metrics/2))
    end

    field :customer_counts, type: :customer_metrics do
      arg(:location_id, non_null(:integer))
      arg(:customer_id, :integer)
      resolve(handle_errors(&Resolvers.Customer.metric_counts/2))
    end

    field :customers, type: :customer_segments_paged do
      arg(:type, non_null(:string))
      arg(:options, non_null(:options))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Customer.segments/2))
    end

    field :customer_details, type: :customer do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Customer.get_customer_details/2))
    end

    field :customer_notes, type: list_of(:customer_note) do
      arg(:customer_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Customer.get_customer_notes/2))
    end

    field :shop, type: :shop do
      arg(:code, non_null(:string))
      resolve(handle_errors(&Resolvers.Referral.shop/2))
    end

    field :customer_locations, type: list_of(:location) do
      arg(:customer_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Customer.locations/2))
    end

    field :refresh, type: :session do
      arg(:token, non_null(:string))
      resolve(handle_errors(&Resolvers.Token.refresh_employee/2))
    end

    field :campaign_send_stats, type: :send_stats do
      arg(:location_id, non_null(:integer))
      arg(:number_to_send, non_null(:integer))
      resolve(handle_errors(&Resolvers.Campaign.send_stats/2))
    end

    field :provinces, type: list_of(:province) do
      arg(:country_code, non_null(:string))
      resolve(handle_errors(&Resolvers.Geocode.provinces/2))
    end

    field :customer_exists, type: :result do
      arg(:phone, non_null(:string))
      resolve(handle_errors(&Resolvers.Customer.exists/2))
    end

    field :tablet_is_member, type: :result do
      arg(:subdomain, non_null(:string))
      arg(:tablet, non_null(:string))
      arg(:phone, non_null(:string))
      resolve(handle_errors(&Resolvers.Membership.tablet_is_member/2))
    end

    field :shop_opt, type: :shop_opt do
      arg(:subdomain, non_null(:string))
      arg(:tablet, non_null(:string))
      resolve(handle_errors(&Resolvers.Reward.shop_opt/2))
    end

    field :tablets, type: list_of(:tablet) do
      arg(:subdomain, non_null(:string))
      resolve(handle_errors(&Resolvers.Location.tablets/2))
    end

    field :get_survey, type: :survey do
      arg(:id, non_null(:string))
      resolve(handle_errors(&Resolvers.Survey.get_survey/2))
    end

    field :get_surveys_paged, type: :surveys_paged do
      arg(:options, non_null(:options))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Survey.get_paged/2))
    end

    field :get_survey_submissions_paged, type: :survey_submissions_paged do
      arg(:options, non_null(:options))
      resolve(handle_errors(&Resolvers.Survey.get_survey_submissions/2))
    end

    field :get_survey_by_code, type: :survey do
      arg(:code, :string)
      resolve(handle_errors(&Resolvers.Survey.get_survey_by_code/2))
    end

    field :get_session_from_token, type: :session do
      arg(:authorization_token, :string)
      resolve(handle_errors(&Resolvers.Employee.get_session_from_token/2))
    end

    field :get_product, type: :product do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.get_product/2))
    end

    field :get_products, type: :products_paged do
      arg(:location_id, non_null(:integer))
      arg(:options, :options)
      resolve(handle_errors(&Resolvers.Inventory.get_products/2))
    end

    field :product_count, type: :result do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.product_count/2))
    end

    field :get_pricing_preference, type: :pricing_preference do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.get_pricing_preference/2))
    end

    field :get_pricing_tiers, type: list_of(:pricing_tier) do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.get_pricing_tiers/2))
    end

    field :get_product_integration, type: :product_integration do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.get_product_integration/2))
    end

    field :validate_product_integration, type: :validate_api do
      arg(:name, non_null(:string))
      arg(:api_key, non_null(:string))
      arg(:client_id, :integer)
      arg(:ext_location_id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.validate_product_integration/2))
    end

    field :get_product_sync_items, type: :product_sync_items_paged do
      arg(:location_id, non_null(:integer))
      arg(:options, non_null(:options))
      resolve(handle_errors(&Resolvers.Inventory.get_product_sync_items/2))
    end

    field :get_tfn, type: :tfn do
      resolve(handle_errors(&Resolvers.SMSSetting.get_tfn/2))
    end

    field :check_tfn, type: :result do
      arg(:phone, non_null(:string))
      resolve(handle_errors(&Resolvers.SMSSetting.check_tfn/2))
    end

    field :password_strength, type: :strength do
      arg(:password, :string)
      resolve(&Resolvers.Employee.password_strength/2)
    end

    field :billing_profile, type: :billing_profile do
      arg(:location_id, :integer)
      resolve(&Resolvers.Billing.get_profile/2)
    end

    field :billing_card, type: :billing_card do
      arg(:id, :integer)
      arg(:location_id, non_null(:integer))
      resolve(&Resolvers.Billing.get_card/2)
    end

    field :billing_trial_periods, type: list_of(:billing_trial_period) do
      resolve(&Resolvers.Billing.get_trial_periods/2)
    end

    field :in_good_standing, type: :result do
      arg(:location_id, non_null(:integer))
      resolve(&Resolvers.Billing.in_good_standing/2)
    end

    field :get_notifications, type: :notifications_paged do
      arg(:options, non_null(:options))
      resolve(handle_errors(&Resolvers.Notification.get_notifications/2))
    end

    field :get_notification_preferences, type: list_of(:notification_preference) do
      resolve(handle_errors(&Resolvers.Notification.get_notification_preferences/2))
    end

    field :count_unread_notifications, type: :notification_count do
      resolve(handle_errors(&Resolvers.Notification.count_unread_notifications/2))
    end

    field :get_locations_by_no_product_count, type: list_of(:location) do
      resolve(handle_errors(&Resolvers.Location.get_locations_by_no_product_count/2))
    end
  end

  mutation do
    field :login, type: :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Employee.login/2)
    end

    field :location, type: :location do
      arg(:id, :integer)
      arg(:name, non_null(:string))
      arg(:address, non_null(:string))
      arg(:address_line2, :string)
      arg(:city, :string)
      arg(:province, :string)
      arg(:country, :string)
      arg(:postal_code, non_null(:string))
      arg(:phone, non_null(:string))
      arg(:email, :string)
      arg(:website_url, :string)
      arg(:facebook_url, :string)
      arg(:instagram_url, :string)
      arg(:youtube_url, :string)
      arg(:twitter_url, :string)
      arg(:menu_url, :string)
      arg(:about, :string)
      arg(:hero, :string)
      arg(:logo, :string)
      arg(:tablet, :string)
      arg(:tablet_background_color, :string)
      arg(:tablet_background_image, :string)
      arg(:tablet_foreground_color, :string)
      arg(:polygon, non_null(:polygon_in))
      arg(:hours, non_null(list_of(:daily_hours_input)))
      arg(:service_types, non_null(list_of(:string)))
      arg(:sms_settings, :sms_settings_input)
      resolve(&Resolvers.Location.create/2)
    end

    field :location_toggle, type: :location do
      arg(:id, :integer)
      arg(:is_active, :boolean)
      resolve(&Resolvers.Location.toggle_active/2)
    end

    field :employee_toggle, type: :employee do
      arg(:id, :integer)
      arg(:is_active, :boolean)
      resolve(&Resolvers.Employee.toggle_active/2)
    end

    field :deal_toggle, type: :deal do
      arg(:id, :integer)
      arg(:is_active, :boolean)
      resolve(&Resolvers.Deal.toggle_active/2)
    end

    field :employee, type: :employee do
      arg(:id, :integer)
      arg(:email, non_null(:string))
      arg(:phone, non_null(:string))
      arg(:role, non_null(:string))
      arg(:password, non_null(:string))
      arg(:is_active, non_null(:boolean))
      arg(:locations, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Employee.create/2))
    end

    field :deal, type: :deal do
      arg(:id, :integer)
      arg(:name, non_null(:string))
      arg(:start_time, :string)
      arg(:end_time, :string)
      arg(:expiry, :string)
      arg(:frequency_type, non_null(:string))
      arg(:is_active, non_null(:boolean))
      arg(:categories, non_null(list_of(:integer)))
      arg(:location_id, non_null(:integer))
      arg(:days_of_week, non_null(list_of(:days_of_week_input)))
      resolve(&Resolvers.Deal.create/2)
    end

    field :reward, type: :reward do
      arg(:id, non_null(:integer))
      arg(:name, non_null(:string))
      arg(:points, non_null(:integer))
      arg(:is_active, non_null(:boolean))
      arg(:categories, non_null(list_of(:integer)))
      resolve(&Resolvers.Reward.create/2)
    end

    field :employee_reset, type: :reset do
      arg(:email, :string)
      resolve(&Resolvers.Employee.employee_reset/2)
    end

    field :reset_password, type: :reset do
      arg(:id, :string)
      arg(:password, :string)
      resolve(&Resolvers.Employee.reset_password/2)
    end

    field :campaigns, type: :campaign do
      arg(:id, :integer)
      arg(:message, :string)
      arg(:send_now, :boolean)
      arg(:send_date, non_null(:string))
      arg(:send_time, :string)
      arg(:business_id, :integer)
      arg(:deal_id, :integer)
      arg(:survey_id, :integer)
      arg(:location_id, :integer)
      arg(:groups, non_null(list_of(:integer)))
      arg(:categories, non_null(list_of(:integer)))
      arg(:products, non_null(list_of(:integer)))
      resolve(handle_errors(&Resolvers.Campaign.create/2))
    end

    field :cancel_campaign, type: :campaign do
      arg(:id, non_null(:integer))
      resolve(&Resolvers.Campaign.cancel/2)
    end

    field :campaign_sms_test, type: :result do
      arg(:location_id, non_null(:integer))
      arg(:message, non_null(:string))
      arg(:phones, non_null(list_of(:string)))
      resolve(handle_errors(&Resolvers.Campaign.sms_test/2))
    end

    field :set_qr_code, type: :qr_code do
      arg(:location_id, non_null(:string))
      resolve(&Resolvers.Location.set_qr_code/2)
    end

    field :referral, type: :referral do
      arg(:phone, non_null(:string))
      arg(:code, non_null(:string))
      resolve(handle_errors(&Resolvers.Referral.create/2))
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

    field :toggle_customer_notifications, type: :result do
      arg(:customer_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      arg(:enabled, non_null(:boolean))
      resolve(handle_errors(&Resolvers.Customer.toggle_crm_notifications/2))
    end

    field :opt_in, type: :result do
      arg(:subdomain, non_null(:string))
      arg(:tablet, non_null(:string))
      arg(:customer, non_null(:customer_opt_in))
      resolve(handle_errors(&Resolvers.Customer.opt_in/2))
    end

    field :save_survey, type: :result do
      arg(:id, :integer)
      arg(:name, :string)
      arg(:content, :string)
      arg(:is_active, :boolean)
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Survey.save/2))
    end

    field :save_survey_submission, type: :result do
      arg(:code, non_null(:string))
      arg(:answers, non_null(:string))
      resolve(handle_errors(&Resolvers.Survey.save_submission/2))
    end

    field :send_customer_export_email, type: :result do
      arg(:type, non_null(:string))
      resolve(handle_errors(&Resolvers.Employee.create_customer_export_email/2))
    end

    field :save_product, type: :product do
      arg(:id, :integer)
      arg(:location_id, non_null(:integer))
      arg(:name, :string)
      arg(:description, :string)
      arg(:image, :string)
      arg(:type, :string)
      arg(:category_id, :integer)
      arg(:is_active, :boolean)
      arg(:in_stock, :boolean)
      arg(:basic_tier, :tier)
      arg(:tier_id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.save_product/2))
    end

    field :toggle_product, type: :product do
      arg(:id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.toggle_product/2))
    end

    field :toggle_product_stock, type: :product do
      arg(:id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.toggle_product_stock/2))
    end

    field :set_pricing_preference, type: :pricing_preference do
      arg(:is_basic, non_null(:boolean))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.set_pricing_preference/2))
    end

    field :save_pricing_tier, type: :pricing_tier do
      arg(:id, :integer)
      arg(:location_id, non_null(:integer))
      arg(:name, :string)
      resolve(handle_errors(&Resolvers.Inventory.save_pricing_tier/2))
    end

    field :remove_pricing_tier, type: :result do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      arg(:move_to_tier_id, :integer)
      resolve(handle_errors(&Resolvers.Inventory.remove_pricing_tier/2))
    end

    field :customer_import, type: :customer_import_results do
      arg(:location_id, non_null(:integer))
      arg(:send_sms, non_null(:boolean))
      arg(:offer_reward, non_null(:boolean))
      arg(:message, :string)
      arg(:customers, non_null(:upload))
      arg(:confirmation, non_null(:boolean))
      resolve(handle_errors(&Resolvers.CustomerImport.import/2))
    end

    field :product_integration, type: :result do
      arg(:location_id, non_null(:integer))
      arg(:name, :string)
      arg(:id, :integer)
      arg(:api_key, :string)
      arg(:client_id, :integer)
      arg(:ext_location_id, :integer)
      arg(:is_active, non_null(:boolean))
      resolve(handle_errors(&Resolvers.Inventory.set_product_integration/2))
    end

    field :product_import, type: :result do
      arg(:location_id, non_null(:integer))
      arg(:products, non_null(:upload))
      resolve(handle_errors(&Resolvers.Inventory.product_import/2))
    end

    field :refresh_product_integration, type: :result do
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.refresh_product_integration/2))
    end

    field :save_sync_item, type: :result do
      arg(:id, non_null(:integer))
      arg(:category_id, non_null(:integer))
      arg(:type, non_null(:string))
      arg(:in_stock, non_null(:boolean))
      arg(:is_active, non_null(:boolean))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Inventory.save_product_sync_item/2))
    end

    field :disable_sms_notifications_by_error_code, type: :result do
      arg(:campaign_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      arg(:error_code, non_null(:integer))

      resolve(
        handle_errors(&Resolvers.Campaign.disable_sms_notifications_for_campaign_error_code/2)
      )
    end

    field :billing_card_create, type: :result do
      arg(:location_id, non_null(:integer))
      arg(:token, non_null(:string))
      resolve(&Resolvers.Billing.create_card/2)
    end

    field :billing_card_update, type: :billing_card do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      arg(:expiry_month, non_null(:integer))
      arg(:expiry_year, non_null(:integer))
      resolve(&Resolvers.Billing.update_card/2)
    end

    field :billing_card_delete, type: :result do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(&Resolvers.Billing.delete_card/2)
    end

    field :billing_card_default, type: :result do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(&Resolvers.Billing.set_default_card/2)
    end

    field :billing_profile_update, type: :result do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      arg(:payment_type, :string)
      arg(:billing_start, :string)
      arg(:billing_amount, :decimal)
      arg(:billing_credit, :decimal)
      resolve(&Resolvers.Billing.update_profile/2)
    end

    field :save_customer_note, type: list_of(:customer_note) do
      arg(:id, :integer)
      arg(:body, :string)
      arg(:flagged, :boolean)
      arg(:customer_id, :integer)
      arg(:location_id, :integer)
      resolve(handle_errors(&Resolvers.Customer.save_note/2))
    end

    field :save_customer, type: :customer do
      arg(:id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      arg(:birthdate, :string)
      arg(:birthdate_verified, :boolean)
      arg(:first_name, :string)
      arg(:last_name, :string)
      resolve(handle_errors(&Resolvers.Customer.update/2))
    end

    field :customer_create, type: :result do
      arg(:location_id, non_null(:integer))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:phone, non_null(:string))
      arg(:email, :string)
      resolve(handle_errors(&Resolvers.Customer.customer_create/2))
    end

    field :save_notification, type: :notification do
      arg(:id, non_null(:integer))
      arg(:is_read, :boolean)
      arg(:is_deleted, :boolean)
      resolve(handle_errors(&Resolvers.Notification.save_notification/2))
    end

    field :save_notification_preference, type: list_of(:notification_preference) do
      arg(:type, non_null(:string))
      arg(:disabled, non_null(:boolean))
      resolve(handle_errors(&Resolvers.Notification.save_preference/2))
    end

    field :mark_notifications_read, type: :result do
      resolve(handle_errors(&Resolvers.Notification.mark_all_as_read/2))
    end
  end
end
