defmodule Store.Repo.Migrations.AlterTableLocationsChangeHoursToJsonb do
  use Ecto.Migration

  def change do
    locations = Store.Location.get_all(nil)

    rename(table(:locations), :hours, to: :hours_original)

    flush()

    alter table(:locations) do
      add(:hours, :jsonb, default: "[]")
    end

    flush()

    # migrate hour data to the new structure
    locations
    |> Enum.map(fn l -> Store.Location.change_hours(l.id, l.hours) end)

    # drop the original field
    alter table(:locations) do
      remove(:hours_original)
    end

    flush()
  end
end
