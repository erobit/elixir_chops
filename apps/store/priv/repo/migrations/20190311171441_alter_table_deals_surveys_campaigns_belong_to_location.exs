defmodule Store.Repo.Migrations.AlterTableDealsSurveysCampaignsBelongToLocation do
  use Ecto.Migration

  @create_deals_per_location """
  INSERT INTO deals(
    start_time,
    end_time,
    expiry,
    is_active,
    business_id,
    inserted_at,
    updated_at,
    days_of_week,
    name,
    frequency_type,
    orig_deal_id,
    location_id
  ) SELECT
      d.start_time,
      d.end_time,
      d.expiry,
      d.is_active,
      d.business_id,
      d.inserted_at,
      d.updated_at,
      d.days_of_week,
      d.name,
      d.frequency_type,
      d.id as "orig_deal_id",
      dl.location_id as "location_id"
    FROM deals d
      INNER JOIN deals_locations dl ON dl.deal_id = d.id;
  """

  @create_deals_categories_per_deal """
  INSERT INTO deals_categories(
    deal_id,
    category_id
  ) SELECT
      d.id as "deal_id",
      dc.category_id as "category_id"
    FROM deals d
      INNER JOIN deals_categories dc ON d.orig_deal_id = dc.deal_id
    WHERE d.delete=false;
  """

  @delete_deals_categories_for_old_deals """
  DELETE FROM deals_categories WHERE deal_id IN (
    SELECT orig_deal_id FROM deals WHERE delete=false
  );
  """

  @update_customer_deals_to_new_deal """
  UPDATE customer_deals cd SET
    deal_id=(
      SELECT
        d.id as "deal_id"
      FROM deals d
        WHERE cd.deal_id = d.orig_deal_id AND d.location_id = cd.location_id
    );
  """

  @create_campaigns_per_location """
  INSERT INTO campaigns(
    message,
    business_id,
    inserted_at,
    updated_at,
    send_now,
    scheduled,
    sent,
    send_date,
    is_active,
    send_time,
    survey_id,
    deal_id,
    timezone,
    location_id,
    orig_campaign_id
  ) SELECT
      c.message,
      c.business_id,
      c.inserted_at,
      c.updated_at,
      c.send_now,
      c.scheduled,
      c.sent,
      c.send_date,
      c.is_active,
      c.send_time,
      s.id as "survey_id",
      d.id as "deal_id",
      c.timezone,
      cl.location_id as "location_id",
      c.id as "orig_campaign_id"
    FROM campaigns c
      INNER JOIN campaigns_locations cl ON c.id = cl.campaign_id
      LEFT JOIN deals d ON c.deal_id = d.orig_deal_id AND cl.location_id = d.location_id
      LEFT JOIN surveys s ON c.survey_id = s.orig_survey_id AND cl.location_id = s.location_id;
  """

  @update_sms_log_point_to_new_campaign """
  UPDATE
    sms_log as s
  SET
    entity_id=(
      SELECT
        c.id
      FROM campaigns c 
      WHERE c.orig_campaign_id = s.entity_id AND c.location_id = s.location_id AND s.type = 'campaign'
    );
  """

  @create_campaigns_categories_per_campaign """
  INSERT INTO campaigns_categories(
    campaign_id,
    category_id
  ) SELECT
      c.id as "campaign_id",
      cc.category_id as "category_id"
    FROM campaigns c
      INNER JOIN campaigns_categories cc ON c.orig_campaign_id = cc.campaign_id
    WHERE c.delete=false;
  """

  @delete_campaigns_categories_for_old_campaigns """
  DELETE FROM campaigns_categories WHERE campaign_id IN (
    SELECT orig_campaign_id FROM campaigns WHERE delete=false
  );
  """

  @create_campaigns_customers_per_campaign """
  INSERT INTO campaigns_customers (
    campaign_id,
    customer_id
  ) SELECT
      c.id as "campaign_id",
      cc.customer_id as "customer_id"
    FROM campaigns c
      INNER JOIN campaigns_customers cc ON c.orig_campaign_id = cc.campaign_id
    WHERE c.delete=false;
  """

  @delete_campaigns_customers_for_old_campaigns """
  DELETE FROM campaigns_customers WHERE campaign_id IN (
    SELECT orig_campaign_id FROM campaigns WHERE delete=false
  );
  """

  @create_campaigns_events_per_campaign """
  INSERT INTO campaigns_events (
    campaign_id,
    customer_id,
    location_id,
    type,
    inserted_at,
    updated_at
  ) SELECT
      c.id as "campaign_id",
      ce.customer_id,
      ce.location_id,
      ce.type,
      ce.inserted_at,
      ce.updated_at
    FROM campaigns c
      INNER JOIN campaigns_events ce ON c.orig_campaign_id = ce.campaign_id
    WHERE c.delete = false;
  """

  @delete_campaigns_events_for_old_campaigns """
  DELETE FROM campaigns_events WHERE campaign_id IN (
    SELECT orig_campaign_id FROM campaigns WHERE delete=false
  );
  """

  @create_campaigns_groups_per_campaign """
  INSERT INTO campaigns_groups (
    campaign_id,
    member_group_id
  ) SELECT
      c.id as "campaign_id",
      cg.member_group_id
    FROM campaigns c
      INNER JOIN campaigns_groups cg ON c.orig_campaign_id = cg.campaign_id
    WHERE c.delete=false;
  """

  @delete_campaigns_groups_for_old_campaigns """
  DELETE FROM campaigns_groups WHERE campaign_id IN (
    SELECT orig_campaign_id FROM campaigns WHERE delete=false
  );
  """

  @create_campaigns_products_per_campaign """
  INSERT INTO campaigns_products (
    campaign_id,
    product_id
  ) SELECT
      c.id as "campaign_id",
      cp.product_id
    FROM campaigns c
      INNER JOIN campaigns_products cp ON c.orig_campaign_id = cp.campaign_id
    WHERE c.delete=false;
  """

  @delete_campaigns_products_for_old_campaigns """
  DELETE FROM campaigns_products WHERE campaign_id IN (
    SELECT orig_campaign_id FROM campaigns WHERE delete=false
  );
  """

  @create_surveys_per_location """
  INSERT INTO surveys(
    name,
    content,
    business_id,
    is_active,
    inserted_at,
    updated_at,
    location_id,
    orig_survey_id
  ) SELECT
      s.name,
      s.content,
      s.business_id,
      s.is_active,
      s.inserted_at,
      s.updated_at,
      l.id as "location_id",
      s.id as "orig_survey_id"
    FROM surveys s
      INNER JOIN locations l ON s.business_id = l.business_id;
  """

  @update_survey_submissions_point_to_survey """
  UPDATE
    survey_submissions as ss
  SET
    survey_id=(
      SELECT
        s.id
      FROM surveys s
      WHERE s.orig_survey_id = ss.survey_id AND s.location_id = ss.location_id
    );
  """

  @delete_owner_employee_location_associations """
  DELETE FROM employees_locations WHERE employee_id IN (
    SELECT id FROM employees WHERE role='owner'
  );
  """

  def change do
    alter table(:deals) do
      add(:location_id, references(:locations))
      add(:orig_deal_id, :integer)
      add(:delete, :boolean, default: false)
    end

    alter table(:surveys) do
      add(:location_id, references(:locations))
      add(:orig_survey_id, :integer)
      add(:delete, :boolean, default: false)
    end

    alter table(:campaigns) do
      add(:location_id, references(:locations))
      add(:orig_campaign_id, :integer)
      add(:delete, :boolean, default: false)
    end

    flush()

    execute("UPDATE deals SET delete=true;")
    execute("UPDATE surveys SET delete=true;")
    execute("UPDATE campaigns SET delete=true;")

    ###################
    # Deal Migrations #
    ###################
    execute(@create_deals_per_location)
    execute(@create_deals_categories_per_deal)
    execute(@delete_deals_categories_for_old_deals)
    execute(@update_customer_deals_to_new_deal)

    #####################
    # Survey Migrations #
    #####################
    execute(@create_surveys_per_location)
    execute(@update_survey_submissions_point_to_survey)

    #######################
    # Campaign Migrations #
    #######################
    execute(@create_campaigns_per_location)
    execute(@update_sms_log_point_to_new_campaign)
    # campaigns_categories
    execute(@create_campaigns_categories_per_campaign)
    execute(@delete_campaigns_categories_for_old_campaigns)
    # campaigns_customers
    execute(@create_campaigns_customers_per_campaign)
    execute(@delete_campaigns_customers_for_old_campaigns)
    # campaigns_events
    execute(@create_campaigns_events_per_campaign)
    execute(@delete_campaigns_events_for_old_campaigns)
    # campaigns_groups
    execute(@create_campaigns_groups_per_campaign)
    execute(@delete_campaigns_groups_for_old_campaigns)
    # campaigns_products
    execute(@create_campaigns_products_per_campaign)
    execute(@delete_campaigns_products_for_old_campaigns)

    #######################
    # Employee Migrations #
    #######################
    execute(@delete_owner_employee_location_associations)

    drop(table(:deals_locations))
    drop(table(:campaigns_locations))
    execute("DELETE FROM campaigns WHERE delete=true;")
    execute("DELETE FROM deals WHERE delete=true;")
    execute("DELETE FROM surveys WHERE delete=true;")

    alter table(:deals) do
      remove(:delete)
      remove(:orig_deal_id)
    end

    alter table(:surveys) do
      remove(:delete)
      remove(:orig_survey_id)
    end

    alter table(:campaigns) do
      remove(:delete)
      remove(:orig_campaign_id)
    end
  end
end
