defmodule Store.Repo.Migrations.ChangeTableReferralsDropUniqueCompositeIndex do
  use Ecto.Migration

  def change do
    drop(index(:referrals, [:location_id, :from_customer_id]))
    create(index(:referrals, [:recipient_phone]))
    create(index(:referrals, [:location_id]))
  end
end
