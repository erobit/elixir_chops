defmodule Store.Repo.Migrations.UpdateTableProductsPerLocation do
  use Ecto.Migration

  @create_pricing_tiers_per_location """
  INSERT INTO pricing_tiers(
    business_id,
    name,
    is_active,
    unit_price,
    location_id,
    orig_tier_id
  ) SELECT
      p.business_id,
      p.name,
      p.is_active,
      p.unit_price,
      l.id as "location_id",
      p.id as "orig_tier_id"
    FROM pricing_tiers p 
      INNER JOIN locations l ON p.business_id = l.business_id
    WHERE
      p.product_id IS NULL;
  """

  @create_products_per_location """
  INSERT INTO products(
    name,
    business_id,
    description,
    image,
    type,
    is_active,
    category_id,
    inserted_at,
    updated_at,
    tier_id,
    orig_product_id,
    location_id
  ) SELECT
      p.name,
      p.business_id,
      p.description,
      p.image,
      p.type,
      p.is_active,
      p.category_id,
      p.inserted_at,
      p.updated_at,
      pt.id as "tier_id",
      p.id as "orig_product_id",
      l.id as "location_id"
    FROM products p
      INNER JOIN locations l ON p.business_id = l.business_id
      INNER JOIN pricing_tiers pt ON p.tier_id = pt.orig_tier_id AND pt.location_id = l.id;
  """

  @create_pricing_preference_per_location """
  INSERT INTO pricing_preferences(
    location_id,
    business_id,
    is_basic
  ) SELECT
      l.id as "location_id",
      pp.business_id,
      pp.is_basic
    FROM pricing_preferences pp
      INNER JOIN locations l ON pp.business_id = l.business_id;
  """

  @create_pricing_tiers_per_unit_product """
  INSERT INTO pricing_tiers(
    business_id,
    product_id,
    unit_price
  ) SELECT
      pt.business_id,
      p.id as "product_id",
      pt.unit_price
    FROM pricing_tiers pt
      INNER JOIN products p ON pt.product_id = p.orig_product_id
    WHERE
      pt.product_id IS NOT NULL;
  """

  @update_products_set_is_in_stock """
  UPDATE
    products as p
  SET
    in_stock=EXISTS (
      SELECT * FROM product_locations pl WHERE pl.product_id = p.orig_product_id AND pl.location_id = p.location_id
    );
  """

  def change do
    alter table(:products) do
      add(:location_id, references(:locations))
      add(:orig_product_id, :integer)
      add(:in_stock, :boolean)
      add(:delete, :boolean, default: false)
    end

    alter table(:pricing_tiers) do
      add(:location_id, references(:locations))
      add(:delete, :boolean, default: false)
      add(:orig_tier_id, :integer)
    end

    alter table(:pricing_preferences) do
      add(:location_id, references(:locations))
      add(:delete, :boolean, default: false)
    end

    drop(index(:products, [:business_id]))
    create(index(:products, [:location_id]))

    flush()

    execute("UPDATE products SET delete=true;")
    execute("UPDATE pricing_tiers SET delete=true;")
    execute("UPDATE pricing_preferences SET delete=true;")

    execute(@create_pricing_tiers_per_location)
    execute(@create_products_per_location)
    execute(@create_pricing_preference_per_location)
    execute(@create_pricing_tiers_per_unit_product)
    execute(@update_products_set_is_in_stock)

    execute(
      "DELETE FROM pricing_tiers WHERE product_id IN (SELECT orig_product_id FROM products);"
    )

    drop(table(:product_locations))
    execute("DELETE FROM products WHERE delete=true;")
    execute("DELETE FROM pricing_tiers WHERE delete=true;")
    execute("DELETE FROM pricing_preferences WHERE delete=true;")

    alter table(:products) do
      remove(:delete)
      remove(:business_id)
      remove(:orig_product_id)
    end

    alter table(:pricing_tiers) do
      remove(:delete)
      remove(:business_id)
      remove(:orig_tier_id)
    end

    alter table(:pricing_preferences) do
      remove(:delete)
      remove(:business_id)
    end
  end
end
