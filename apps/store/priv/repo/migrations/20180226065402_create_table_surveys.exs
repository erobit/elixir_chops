defmodule Store.Repo.Migrations.CreateTableSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add(:name, :string, null: false)
      add(:content, :text, null: false)
      add(:business_id, references(:businesses), null: false)
      add(:is_active, :bool, default: true)
      timestamps(type: :timestamptz)
    end
  end
end
