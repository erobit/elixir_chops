defmodule Store.Repo.Migrations.CreateTableHistory do
  use Ecto.Migration

  def change do
    create table(:history) do
      add(:action, :string, null: false)
      add(:type, :string, null: false)
      add(:meta, :map, null: false)
      add(:member_id, references(:members), null: true)
      add(:business_id, references(:businesses), null: true)
      add(:location_id, references(:locations), null: true)
    end
  end
end
