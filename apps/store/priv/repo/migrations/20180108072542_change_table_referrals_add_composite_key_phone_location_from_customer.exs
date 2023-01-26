defmodule Store.Repo.Migrations.ChangeTableReferralsAddCompositeKeyPhoneLocationFromCustomer do
  use Ecto.Migration

  def change do
    Store.Repo.delete_all("referrals")
    create(unique_index(:referrals, [:from_customer_id, :location_id, :recipient_phone]))
  end
end
