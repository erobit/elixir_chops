defmodule Store.Repo.Migrations.UpdateUsersPeterToSuperadminAndDeleteOthers do
  use Ecto.Migration
  use Store.Model

  def change do
    from(e in Employee,
      where: e.email in ["dan@acme.com", "ryan@acme.com"]
    )
    |> Repo.all()
    |> Enum.map(&Repo.delete/1)

    from(e in Employee,
      where: e.email == "peter@acme.com"
    )
    |> Repo.update_all(
      set: [
        email: "superadmin@super.admin",
        role: "superadmin"
      ]
    )
  end
end
