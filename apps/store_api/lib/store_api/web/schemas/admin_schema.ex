defmodule StoreAPI.AdminSchema do
  use Absinthe.Schema
  import_types(Absinthe.Plug.Types)
  import_types(StoreAPI.Schema.SharedTypes)
  import_types(StoreAPI.Schema.AdminTypes)
  alias StoreAPI.Resolvers
  import StoreAPI.Helpers.ChangesetHelper

  query do
    field :businesses, type: :businesses_paged do
      arg(:options, non_null(:options))
      resolve(handle_errors(&Resolvers.Business.get_all/2))
    end

    field :business_locations, type: list_of(:location) do
      arg(:business_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Location.get_locations_by_business/2))
    end

    field :business_locations_active, type: list_of(:location) do
      arg(:business_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Location.get_active_locations_by_business/2))
    end

    field :business, type: :business do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Business.get/2))
    end

    field :sms_settings, type: :sms_settings do
      arg(:business_id, non_null(:integer))
      resolve(&Resolvers.SMSSetting.get/2)
    end

    field :get_reset, type: :reset do
      arg(:id, non_null(:string))
      resolve(&Resolvers.Admin.get_reset/2)
    end

    field :get_admins, type: :admin_employees_paged do
      arg(:options, non_null(:options))
      resolve(handle_errors(&Resolvers.Admin.get_all/2))
    end

    field :get_admin, type: :admin_employee do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Admin.get_by_id/2))
    end

    field :import_results, type: list_of(:customer_import_sms_results) do
      arg(:id, non_null(:integer))
      resolve(handle_errors(&Resolvers.CustomerImport.results/2))
    end

    field :password_strength, type: :strength do
      arg(:password, :string)
      resolve(&Resolvers.Admin.password_strength/2)
    end
  end

  mutation do
    field :login, type: :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Admin.login/2)
    end

    field :employee_reset, type: :reset do
      arg(:email, :string)
      resolve(&Resolvers.Admin.employee_reset/2)
    end

    field :reset_password, type: :reset do
      arg(:id, :string)
      arg(:password, :string)
      resolve(&Resolvers.Admin.reset_password/2)
    end

    field :sms_settings, type: :sms_settings do
      arg(:id, non_null(:integer))
      arg(:business_id, non_null(:integer))
      arg(:provider, non_null(:string))
      arg(:phone_number, non_null(:string))
      arg(:max_sms, non_null(:integer))
      arg(:send_distributed, non_null(:boolean))
      arg(:distributed_uuid, :string)
      resolve(&Resolvers.SMSSetting.save/2)
    end

    field :provision, type: :result do
      arg(:name, non_null(:string))
      arg(:phone, non_null(:string))
      arg(:email, non_null(:string))
      arg(:subdomain, non_null(:string))
      arg(:language, :string)
      arg(:type, :string)
      resolve(handle_errors(&Resolvers.Admin.provision/2))
    end

    field :save_business, type: :business do
      arg(:id, non_null(:integer))
      arg(:name, non_null(:string))
      arg(:subdomain, non_null(:string))
      arg(:language, :string)
      resolve(handle_errors(&Resolvers.Business.save/2))
    end

    field :generate_authorization_token, type: :session do
      arg(:business_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Admin.generate_authorization_token/2))
    end

    field :save_admin_employee, type: :admin_employee do
      arg(:id, :integer)
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:phone, non_null(:string))
      arg(:role, non_null(:string))
      arg(:is_active, :boolean)
      resolve(handle_errors(&Resolvers.Admin.save/2))
    end

    field :customer_import, type: :customer_import_results do
      arg(:location_id, non_null(:integer))
      arg(:send_sms, non_null(:boolean))
      arg(:offer_reward, non_null(:boolean))
      arg(:message, :string)
      arg(:customers, non_null(:upload))
      resolve(handle_errors(&Resolvers.CustomerImport.import/2))
    end

    field :raw_push_notification, type: :result do
      arg(:tokens, non_null(list_of(:string)))
      arg(:message, non_null(:string))
      arg(:title, :string)
      arg(:id, :string)
      resolve(handle_errors(&Resolvers.Admin.raw_push_notification/2))
    end

    field :business_toggle, type: :business do
      arg(:id, :integer)
      arg(:is_active, :boolean)
      resolve(handle_errors(&Resolvers.Business.toggle_active/2))
    end

    field :seed_data, type: :result do
      arg(:business_id, non_null(:integer))
      arg(:location_id, non_null(:integer))
      resolve(handle_errors(&Resolvers.Admin.seed_data/2))
    end
  end
end
