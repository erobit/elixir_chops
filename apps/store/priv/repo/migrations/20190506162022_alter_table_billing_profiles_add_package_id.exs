defmodule Store.Repo.Migrations.AlterTableBillingProfilesAddPackageId do
  use Ecto.Migration

  def change do
    alter table(:billing_profiles) do
      add(:package_id, references(:billing_packages))
    end
  end
end
