defmodule Store.Repo.Migrations.ChangeTableLocationsSetIsActiveDefaultFalse do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      modify(:is_active, :boolean, default: false)
    end

    Store.Repo.update_all("locations", set: [is_active: true])
  end
end
