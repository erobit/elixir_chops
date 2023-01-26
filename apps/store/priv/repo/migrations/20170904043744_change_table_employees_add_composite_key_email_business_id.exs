defmodule Store.Repo.Migrations.ChangeTableEmployeesAddCompositeKeyEmailBusinessId do
  use Ecto.Migration

  def change do
    drop(index(:employees, [:email]))

    create(
      unique_index(:employees, [:email, :business_id], name: :employees_email_business_id_index)
    )
  end
end
