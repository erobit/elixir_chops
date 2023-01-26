defmodule StoreAPI.Schema.AdminTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Store.Repo
  import StoreAPI.Schema.SharedTypes
  import_types(Absinthe.Type.Custom)

  @desc """
  Businesses paged
  """
  object :businesses_paged do
    field(:entries, list_of(:business))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  @desc """
  SMS Log
  """
  object :sms_log do
    field(:phone, :boolean)
    field(:status, :integer)
  end

  @desc """
  Customer Import Status Result
  """
  object :customer_import_sms_results do
    field(:sending, list_of(:sms_log))
    field(:delivered, list_of(:sms_log))
    field(:failed, list_of(:sms_log))
    field(:undelivered, list_of(:sms_log))
  end

  @desc """
  Admin Employee
  """
  object :admin_employee do
    field(:id, :integer)
    field(:email, :string)
    field(:name, :string)
    field(:phone, :string)
    field(:role, :string)
    field(:is_active, :boolean)
  end

  @desc """
  Admin Employees Paged
  """
  object :admin_employees_paged do
    field(:entries, list_of(:admin_employee))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end
end
