defmodule Store.Repo.Migrations.ChangeTableLocationAddTimezone do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:timezone, :map)
    end
  end
end
