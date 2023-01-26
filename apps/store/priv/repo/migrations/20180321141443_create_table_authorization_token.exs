defmodule Store.Repo.Migrations.CreateTableAuthorizationToken do
  use Ecto.Migration
  use Store.Model

  def change do
    create table(:authorization_tokens) do
      add(:guid, :binary_id, null: false)
      add(:business_id, references(:businesses))
      timestamps(type: :timestamptz)
    end

    from(e in Employee,
      where: e.email in ["dan@toke.co", "ryan@toke.co"]
    )
    |> Repo.all()
    |> Enum.map(&Repo.delete/1)

    from(e in Employee,
      where: e.email == "peter@toke.co"
    )
    |> Repo.update_all(
      set: [
        email: "superadmin@super.admin",
        role: "superadmin"
      ]
    )
  end
end
