defmodule Store.Repo.Migrations.ChangeTableDealsAllowStartEndTimeNulls do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      modify(:start_time, :time, null: true)
      modify(:end_time, :time, null: true)
    end
  end
end
