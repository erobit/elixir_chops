defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldUrlAndMenuFields do
  use Ecto.Migration

  def up do
    alter table(:locations) do
      add(:youtube_url, :string)
      add(:twitter_url, :string)
      add(:menu_url, :string)
    end
  end

  def down do
    alter table(:locations) do
      remove(:youtube_url)
      remove(:twitter_url)
      remove(:menu_url)
    end
  end
end
