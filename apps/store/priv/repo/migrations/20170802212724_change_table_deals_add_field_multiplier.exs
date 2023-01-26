defmodule Store.Repo.Migrations.ChangeTableDealsAddFieldMultiplier do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      add(:multiplier, :integer)
    end
  end
end
