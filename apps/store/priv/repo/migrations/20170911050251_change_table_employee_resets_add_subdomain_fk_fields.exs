defmodule Store.Repo.Migrations.ChangeTableEmployeeResetsAddSubdomainFkFields do
  use Ecto.Migration

  def change do
    alter table(:employee_resets) do
      add(:subdomain, :string, null: false)
      add(:business_id, references(:businesses), null: false)
      add(:employee_id, references(:employees), null: false)
    end
  end
end
