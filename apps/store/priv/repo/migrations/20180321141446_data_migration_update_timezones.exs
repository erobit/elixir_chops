defmodule Store.Repo.Migrations.DataMigrationUpdateTimezones do
  use Ecto.Migration
  use Store.Model

  def change do
    Repo.all(Store.Location)
    |> Enum.map(fn location ->
      %Geo.Point{coordinates: {lon, lat}} = location.point
      {:ok, timezone} = Store.Geo.Timezone.get_by_lat_lon(lat, lon)

      location
      |> Ecto.Changeset.change(%{timezone: timezone})
      |> Repo.update()
    end)
  end
end
