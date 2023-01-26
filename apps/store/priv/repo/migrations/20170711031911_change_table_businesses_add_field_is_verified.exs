defmodule Store.Repo.Migrations.ChangeTableBusinessesAddFieldIsVerified do
  use Ecto.Migration

  def change do
    alter table(:businesses) do
      add(:is_verified, :boolean)
    end
  end
end
