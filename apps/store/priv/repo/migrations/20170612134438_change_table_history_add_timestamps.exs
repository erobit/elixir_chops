defmodule Store.Repo.Migrations.ChangeTableHistoryAddTimestamps do
  use Ecto.Migration

  def change do
    alter table(:history) do
      timestamps(type: :timestamptz)
    end
  end
end
