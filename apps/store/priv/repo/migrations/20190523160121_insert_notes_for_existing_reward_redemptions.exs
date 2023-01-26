defmodule Store.Repo.Migrations.InsertNotesForExistingRewardRedemptions do
  use Ecto.Migration

  @create_notes_for_customers_for_redeemed_rewards """
  INSERT INTO customer_notes(
    type,
    customer_id,
    location_id,
    employee_id,
    inserted_at,
    updated_at,
    metadata
  ) SELECT
      'redeemed_reward' as "type",
      cr.customer_id,
      cr.location_id,
      e.id as "employee_id",
      cr.redeemed as "inserted_at",
      cr.redeemed as "updated_at",
      json_build_object('reward_name', cr.name, 'reward_id', cr.id) as "metadata"
    FROM customer_rewards cr
    INNER JOIN locations l ON l.id = cr.location_id
    INNER JOIN employees e ON l.business_id = e.business_id AND e.role = 'superadmin'
    WHERE redeemed IS NOT NULL;
  """

  @create_notes_for_customers_for_redeemed_deals """
  INSERT INTO customer_notes(
    type,
    customer_id,
    location_id,
    employee_id,
    inserted_at,
    updated_at,
    metadata
  ) SELECT
      'redeemed_reward' as "type",
      cd.customer_id,
      cd.location_id,
      e.id as "employee_id",
      cd.redeemed as "inserted_at",
      cd.redeemed as "updated_at",
      json_build_object('reward_name', cd.name, 'reward_id', cd.id) as "metadata"
    FROM customer_deals cd
    INNER JOIN locations l ON l.id = cd.location_id
    INNER JOIN employees e ON l.business_id = e.business_id AND e.role = 'superadmin'
    WHERE redeemed IS NOT NULL;
  """

  def change do
    execute(@create_notes_for_customers_for_redeemed_rewards)
    execute(@create_notes_for_customers_for_redeemed_deals)
  end
end
