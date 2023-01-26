defmodule Store.Repo.Migrations.ChangeTableLocationAddAddressLine2 do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:address_line2, :string)
    end
  end
end
