defmodule Store.Repo.Migrations.MigrateBusinessCountryFromLocationCountry do
  use Ecto.Migration
  import Ecto.Query
  use Store.Model

  def change do
    set_business_countries()
  end

  defp set_business_countries do
    Business
    |> preload(:locations)
    |> Repo.all()
    |> Enum.each(fn biz ->
      case biz.locations |> List.first() do
        nil ->
          :noop

        loc ->
          biz
          |> Ecto.Changeset.change(%{country: loc.country})
          |> Repo.update()
      end
    end)
  end
end
