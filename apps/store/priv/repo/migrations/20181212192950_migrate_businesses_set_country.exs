defmodule Store.Repo.Migrations.MigrateBusinessesSetCountry do
  use Ecto.Migration
  import Ecto.Query
  use Store.Model

  def change do
    set_business_country()
  end

  defp set_business_country do
    Business
    |> Repo.all()
    |> Enum.each(fn biz ->
      country =
        case biz.country do
          "CA" -> "Canada"
          "Canada" -> "Canada"
          _ -> "USA"
        end

      biz
      |> Ecto.Changeset.change(%{country: country})
      |> Repo.update()
    end)
  end
end
