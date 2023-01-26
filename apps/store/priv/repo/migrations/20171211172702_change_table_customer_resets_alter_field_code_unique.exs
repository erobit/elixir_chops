defmodule Store.Repo.Migrations.ChangeTableCustomerResetsAlterFieldCodeUnique do
  use Ecto.Migration

  def up do
    create(unique_index(:customer_resets, [:code], name: :customer_resets_code_index))
  end

  def down do
    drop(index(:customer_resets, [:code]))
  end
end
