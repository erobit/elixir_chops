defmodule Store.Repo.Migrations.AddTierIdToProduct do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add(:tier_id, references(:pricing_tiers))
    end
  end
end
