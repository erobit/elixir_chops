defmodule Store.Repo.Migrations.ChangeTableDealsAddFieldDaysOfWeek do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      add(:days_of_week, {:array, :map}, required: true, default: [])
    end
  end
end
