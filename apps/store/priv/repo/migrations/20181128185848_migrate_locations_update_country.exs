defmodule Store.Repo.Migrations.MigrateLocationsUpdateCountry do
  use Ecto.Migration
  import Ecto.Query
  use Store.Model

  def change do
    set_location_country()
  end

  defp set_location_country do
    Location
    |> Repo.all()
    |> Enum.map(fn loc ->
      country =
        case Integer.parse(loc.postal_code) do
          :error -> "Canada"
          {_int, ""} -> "USA"
          {_int, _invalid} -> "Canada"
        end

      loc
      |> Ecto.Changeset.change(%{country: country})
      |> Repo.update()
    end)
  end
end
