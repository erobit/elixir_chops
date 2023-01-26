defmodule Store.Repo.Migrations.AlterTableCustomerNotesAddTypeAndMetadata do
  use Ecto.Migration
  use Store.Model

  def change do
    alter table(:customer_notes) do
      add(:type, :string, default: "note")
      add(:metadata, :map)
    end

    flush()

    Repo.update_all(CustomerNote, set: [type: "note"])
  end
end
