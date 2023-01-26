defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldFacebookToken do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      add(:facebook_token, :string, null: true)
    end
  end

  def down do
    alter table(:customers) do
      remove(:facebook_token)
    end
  end
end
