defmodule Store.Repo.Migrations.CreateTableDeleteAccountRequests do
  use Ecto.Migration

  def change do
    create table(:delete_account_requests) do
      add(:customer_id, :integer, null: false)
      add(:processed_date, :timestamptz, null: true)
      timestamps(type: :timestamptz)
    end
  end
end
