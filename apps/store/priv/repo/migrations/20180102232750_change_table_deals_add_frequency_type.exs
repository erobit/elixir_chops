defmodule Store.Repo.Migrations.ChangeTableDealsAddFrequencyType do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      add(:frequency_type, :string)
    end
  end
end
