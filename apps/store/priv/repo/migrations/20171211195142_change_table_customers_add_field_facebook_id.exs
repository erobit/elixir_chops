defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldFacebookId do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      add(:facebook_id, :string)
    end
  end

  def down do
    remove(:facebook_id)
  end
end
