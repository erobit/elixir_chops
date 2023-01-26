defmodule Store.Repo.Migrations.ChangeTableLocationsAboutFieldToText do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      modify(:about, :text)
    end
  end
end
