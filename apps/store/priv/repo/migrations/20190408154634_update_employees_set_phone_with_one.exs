defmodule Store.Repo.Migrations.UpdateEmployeesSetPhoneWithOne do
  use Ecto.Migration

  def change do
    execute(
      "UPDATE employees SET phone=concat('1', employees.phone) WHERE LENGTH(employees.phone) = 10;"
    )
  end
end
