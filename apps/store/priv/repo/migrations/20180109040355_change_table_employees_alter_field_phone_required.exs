defmodule Store.Repo.Migrations.ChangeTableEmployeesAlterFieldPhoneRequired do
  use Ecto.Migration

  def change do
    Store.Repo.update_all("employees", set: [phone: "12223334444"])

    alter table(:employees) do
      modify(:phone, :string, null: false)
    end
  end
end
