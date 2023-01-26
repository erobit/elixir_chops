defmodule Store.Repo.Migrations.ChangeTableLocationsRefactorImageFields do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      remove(:landscape_image)
      add(:hero, :string)
      add(:logo, :string)
    end
  end
end
