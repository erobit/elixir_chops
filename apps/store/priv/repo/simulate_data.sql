CREATE OR REPLACE FUNCTION public.simulate(biz_id integer, loc_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE 
  DATABASE VARCHAR;
  MONTH INTEGER;
  MONTH_DATE VARCHAR;
  FINISH_AT INTEGER;
  START_AT INTEGER;
  VISIT_LIMIT INTEGER;
  DEAL_LIMIT INTEGER;
  REWARD_LIMIT INTEGER;
  REFERRAL_LIMIT INTEGER;
  SMS_LIMIT INTEGER;
  DATE1 TIMESTAMP;
  DATE2 TIMESTAMP;
  DATE3 TIMESTAMP;
  DATE4 TIMESTAMP;
  DATE5 TIMESTAMP;
  NUM_CUSTOMERS INTEGER;
  TIMEZONE VARCHAR;
  CUSTOMERS_GENERATED BOOLEAN;
  CUSTOMERS_CATEGORIES BOOLEAN;
  HAS_MEMBERSHIP BOOLEAN;
  HAS_SURVEY BOOLEAN;
  SURVEY_DOMAIN VARCHAR;
  REFERRAL_ID INTEGER;
  CUSTOMERS_ID INTEGER;
BEGIN

  /* ENSURE THIS CODE CAN NEVER RUN ON PRODUCTION!!!!! */
  DATABASE := (SELECT current_database());
  IF DATABASE = 'platform' THEN 
    RETURN;
  END IF;

  /* Set the domain for use in looking up surveys sent */
  IF DATABASE = 'platform_dev' THEN
    SURVEY_DOMAIN := '/s/';
  END IF;

  IF DATABASE = 'platform_staging' THEN
    SURVEY_DOMAIN := 'platform-staging.com/s/';
  END IF;

  IF DATABASE = 'platform_demo' THEN
    SURVEY_DOMAIN := 'platform-demo.com/s/';
  END IF;

  /*
  * Purpose: Simulate yearly Acme traffic for a single shop and location
  * by creating new customers, having them join the shop and transacting
  * visits, deal redemptions and rewards.
  */

  /* Add extension to give us uuid_generate_v4() capabilities */
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

  /* Delete existing records */ 
  DROP TABLE IF EXISTS BIZ_CUSTOMERS;
  CREATE TEMP TABLE BIZ_CUSTOMERS AS
  SELECT customer_id FROM memberships WHERE business_id = biz_id;

  DELETE FROM transactions WHERE location_id = loc_id;
  DELETE FROM customer_rewards WHERE location_id = loc_id;
  DELETE FROM customer_deals where location_id = loc_id;
  DELETE FROM referrals WHERE location_id = loc_id;
  DELETE FROM visits WHERE location_id = loc_id;
  DELETE FROM reviews WHERE location_id = loc_id;
  DELETE FROM membership_locations where location_id = loc_id;
  DELETE FROM campaigns_products WHERE campaign_id in (SELECT id FROM campaigns WHERE business_id = biz_id);
  DELETE FROM campaigns_categories WHERE campaign_id in (SELECT id FROM campaigns WHERE business_id = biz_id);
  DELETE FROM campaigns_customers WHERE campaign_id in (SELECT id FROM campaigns WHERE business_id = biz_id);
  DELETE FROM campaigns_events WHERE campaign_id in (SELECT id FROM campaigns WHERE business_id = biz_id);
  DELETE FROM campaigns_groups WHERE campaign_id in (SELECT id FROM campaigns WHERE business_id = biz_id);
  DELETE FROM campaigns WHERE business_id = biz_id;
  DELETE FROM sms_log WHERE location_id = loc_id;
  DELETE FROM deals_categories WHERE deal_id IN (SELECT id from deals WHERE business_id = biz_id);
  DELETE FROM customer_deals WHERE deal_id IN (SELECT id FROM deals WHERE business_id = biz_id);
  DELETE FROM deals WHERE business_id = biz_id;
  DELETE FROM transactions WHERE location_id = loc_id;
  DELETE FROM survey_submissions where survey_id in (select id from surveys where business_id = business_id);
  DELETE FROM surveys where business_id = biz_id;
  
  DROP TABLE IF EXISTS BIZ_CUSTOMERS;

  /* create fake deals */
  INSERT INTO deals(start_time,end_time,expiry,is_active,business_id,location_id,inserted_at,updated_at,days_of_week,name,frequency_type) 
  VALUES
  (NULL,NULL,NULL,TRUE,biz_id,loc_id,E'2018-05-07 18:10:13.137921+00',E'2018-07-09 20:26:53.423332+00',E'{"{\\"active\\": false, \\"weekday\\": \\"mon\\"}","{\\"active\\": true, \\"weekday\\": \\"tue\\"}","{\\"active\\": false, \\"weekday\\": \\"wed\\"}","{\\"active\\": false, \\"weekday\\": \\"thu\\"}","{\\"active\\": false, \\"weekday\\": \\"fri\\"}","{\\"active\\": false, \\"weekday\\": \\"sat\\"}","{\\"active\\": false, \\"weekday\\": \\"sun\\"}"}',E'Get a FREE x with every 1/8th!',E'daily'),
  (NULL,NULL,NULL,TRUE,biz_id,loc_id,E'2018-05-07 18:10:32.682895+00',E'2018-07-09 20:26:59.008309+00',E'{"{\\"active\\": false, \\"weekday\\": \\"mon\\"}","{\\"active\\": false, \\"weekday\\": \\"tue\\"}","{\\"active\\": false, \\"weekday\\": \\"wed\\"}","{\\"active\\": true, \\"weekday\\": \\"thu\\"}","{\\"active\\": false, \\"weekday\\": \\"fri\\"}","{\\"active\\": false, \\"weekday\\": \\"sat\\"}","{\\"active\\": false, \\"weekday\\": \\"sun\\"}"}',E'$5 OFF all xyz!',E'daily'),
  (NULL,NULL,NULL,TRUE,biz_id,loc_id,E'2018-05-07 18:10:51.0222+00',E'2018-07-09 20:24:04.871197+00',E'{"{\\"active\\": true, \\"weekday\\": \\"mon\\"}","{\\"active\\": false, \\"weekday\\": \\"tue\\"}","{\\"active\\": false, \\"weekday\\": \\"wed\\"}","{\\"active\\": false, \\"weekday\\": \\"thu\\"}","{\\"active\\": false, \\"weekday\\": \\"fri\\"}","{\\"active\\": false, \\"weekday\\": \\"sat\\"}","{\\"active\\": false, \\"weekday\\": \\"sun\\"}"}',E'$2 off each abc',E'daily'),
  (NULL,NULL,NULL,TRUE,biz_id,loc_id,E'2018-05-07 18:11:13.073203+00',E'2018-07-09 20:25:36.036056+00',E'{"{\\"active\\": false, \\"weekday\\": \\"mon\\"}","{\\"active\\": false, \\"weekday\\": \\"tue\\"}","{\\"active\\": true, \\"weekday\\": \\"wed\\"}","{\\"active\\": false, \\"weekday\\": \\"thu\\"}","{\\"active\\": false, \\"weekday\\": \\"fri\\"}","{\\"active\\": false, \\"weekday\\": \\"sat\\"}","{\\"active\\": false, \\"weekday\\": \\"sun\\"}"}',E'Get a FREE xyz with every 123!',E'daily'),
  (NULL,NULL,E'2018-07-29 04:00:00+00',TRUE,biz_id,loc_id,E'2018-05-07 18:12:39.333372+00',E'2018-06-27 17:15:06.626736+00',E'{"{\\"active\\": true, \\"weekday\\": \\"mon\\"}","{\\"active\\": true, \\"weekday\\": \\"tue\\"}","{\\"active\\": true, \\"weekday\\": \\"wed\\"}","{\\"active\\": true, \\"weekday\\": \\"thu\\"}","{\\"active\\": true, \\"weekday\\": \\"fri\\"}","{\\"active\\": true, \\"weekday\\": \\"sat\\"}","{\\"active\\": true, \\"weekday\\": \\"sun\\"}"}',E'4 items for xyz.',E'single-use'),
  (NULL,NULL,NULL,TRUE,biz_id,loc_id,E'2018-06-30 14:59:17.985244+00',E'2018-07-09 20:27:10.51422+00',E'{"{\\"active\\": false, \\"weekday\\": \\"mon\\"}","{\\"active\\": false, \\"weekday\\": \\"tue\\"}","{\\"active\\": false, \\"weekday\\": \\"wed\\"}","{\\"active\\": false, \\"weekday\\": \\"thu\\"}","{\\"active\\": false, \\"weekday\\": \\"fri\\"}","{\\"active\\": false, \\"weekday\\": \\"sat\\"}","{\\"active\\": true, \\"weekday\\": \\"sun\\"}"}',E'Happy Day - $5 off every abc',E'daily'),
  (NULL,NULL,NULL,TRUE,biz_id,loc_id,E'2018-07-02 18:08:03.848289+00',E'2018-07-14 17:08:10.19915+00',E'{"{\\"active\\": false, \\"weekday\\": \\"mon\\"}","{\\"active\\": false, \\"weekday\\": \\"tue\\"}","{\\"active\\": false, \\"weekday\\": \\"wed\\"}","{\\"active\\": false, \\"weekday\\": \\"thu\\"}","{\\"active\\": false, \\"weekday\\": \\"fri\\"}","{\\"active\\": true, \\"weekday\\": \\"sat\\"}","{\\"active\\": false, \\"weekday\\": \\"sun\\"}"}',E'$2 off xyz',E'single-use');

  /* product inventory */
  DELETE FROM customer_products WHERE product_id IN (SELECT id FROM products WHERE location_id = loc_id);
  DELETE FROM campaigns_products WHERE product_id IN (SELECT id FROM products WHERE location_id = loc_id);
  
  UPDATE products SET tier_id = NULL WHERE location_id = loc_id;
  UPDATE pricing_tiers SET product_id = NULL WHERE product_id in (SELECT id FROM products WHERE location_id = loc_id);

  DELETE FROM pricing_tiers WHERE location_id = loc_id;
  DELETE FROM products WHERE location_id = loc_id;
  DELETE FROM pricing_preferences WHERE location_id = loc_id;
  
  DELETE FROM product_sync_items WHERE product_integration_id = (SELECT id FROM product_integrations WHERE location_id = loc_id);
  DELETE FROM product_integrations WHERE location_id = loc_id;
  
  INSERT INTO pricing_preferences(is_basic, location_id) VALUES (TRUE, loc_id);

  INSERT INTO products(name, description, image, type, is_active, category_id, inserted_at, updated_at, tier_id, location_id, in_stock, sync_item_id)
  (
    SELECT E'A', E'Packing a punch', 2, 2, E'https://s3.amazonaws.com/acme.com/assets/products/xyz.jpg', E'hybrid', TRUE, 1, NOW(), NOW(), null::bigint, null::bigint, loc_id, TRUE, null::bigint, 2, 2
    UNION ALL
    SELECT E'B', E'A great decadent chocolate brownie.', 25, 2, E'https://s3.amazonaws.com/acme.com/assets/products/abc.png', E'hybrid', TRUE, 5, E'2018-05-07 18:10:13.137921+00', E'2018-05-07 18:10:13.137921+00', null::bigint, null::bigint, loc_id, TRUE, null::bigint, 2, 2
    UNION ALL
    SELECT E'C', E'Try out house mix, a great blend of our most popular brands.', 14, 2, E'https://s3.amazonaws.com/acme.com/assets/products/abc.jpg', E'hybrid', TRUE, 4, E'2018-05-07 18:10:13.137921+00', E'2018-05-07 18:10:13.137921+00', null::bigint, null::bigint, loc_id, TRUE, null::bigint, 2, 2
    UNION ALL
    SELECT E'D', E'It also leads to increased creativity.', 14, 0, E'https://s3.amazonaws.com/acme.com/assets/products/xyz.jpg', E'sativa', TRUE, 1, E'2018-05-07 18:10:13.137921+00', E'2018-05-07 18:10:13.137921+00', null::bigint, null::bigint, loc_id, TRUE, null::bigint, 2, 2
    UNION ALL
    SELECT E'E', E'The Green Lightning energy drink!', 10, 0, E'https://s3.amazonaws.com/acme.com/assets/products/abc.jpg', E'hybrid', TRUE, 3, E'2018-05-07 18:10:13.137921+00', E'2018-05-07 18:10:13.137921+00', null::bigint, null::bigint, loc_id, TRUE, null::bigint, 2, 2
    UNION ALL
    SELECT E'F', E'Check this out', 82.17, 0.99, E'https://s3.amazonaws.com/acme.com/assets/products/123.jpg', E'indica', TRUE, 2, E'2018-05-07 18:10:13.137921+00', E'2018-05-07 18:10:13.137921+00', null::bigint, null::bigint, loc_id, TRUE, null::bigint, 2, 2
    UNION ALL
    SELECT E'G', E'This product is the perfect item for on-the-go.', 0, 0, E'https://s3.amazonaws.com/acme.com/assets/products/abc.jpg', E'', TRUE, 6, E'2018-05-07 18:10:13.137921+00', E'2018-05-07 18:10:13.137921+00', null::bigint, null::bigint, loc_id, TRUE, null::bigint, 2, 2
  );

  /* for each product at this location, insert a pricing tier related to the product */
  INSERT INTO pricing_tiers(name, product_id, is_active, unit_price, location_id)
  (
    SELECT '', id, true, 0, loc_id FROM products WHERE location_id = loc_id AND name = 'A'
    UNION ALL
    SELECT '', id, true, 8, loc_id FROM products WHERE location_id = loc_id AND name = 'B'
    UNION ALL
    SELECT '', id, true, 7, loc_id FROM products WHERE location_id = loc_id AND name = 'C'
    UNION ALL
    SELECT '', id, true, 0, loc_id FROM products WHERE location_id = loc_id AND name = 'D'
    UNION ALL
    SELECT '', id, true, 4, loc_id FROM products WHERE location_id = loc_id AND name = 'E'
    UNION ALL
    SELECT '', id, true, 99, loc_id FROM products WHERE location_id = loc_id AND name = 'F'
    UNION ALL 
    SELECT '', id, true, 125, loc_id FROM products WHERE location_id = loc_id AND name = 'G'
  );

  /* for each product at this location, update its pricing tier_id */
  UPDATE products SET tier_id = (SELECT id FROM pricing_tiers WHERE product_id = products.id) WHERE location_id = loc_id;

  MONTH := 1;

  /* Loop through months 1-12 */
  LOOP
    MONTH_DATE := date_part('YEAR',now()) || '-' || lpad(MONTH::text, 2, '0') || '-01';
    FINISH_AT := 114 * MONTH;
    START_AT := (FINISH_AT - 114)+1;

    /* Create random limits for visits, deals and rewards */
    VISIT_LIMIT := floor(random()*(1368-350+1)+350)::int;
    DEAL_LIMIT := floor(random()*(1368-250+1)+250)::int;
    REWARD_LIMIT := floor(random()*(1368-150+1)+150)::int;
    REFERRAL_LIMIT := floor(random()*(450-150+1)+450)::int;
    SMS_LIMIT := floor(random()*(5000-350+1)+350)::int;

    DROP TABLE IF EXISTS SAMPLE_CUSTOMERS;

    /* only create customers if they don't already exist */
    CUSTOMERS_GENERATED := (SELECT EXISTS(SELECT id FROM customers WHERE phone='10005550003'));

    IF CUSTOMERS_GENERATED = TRUE THEN 
      CREATE TEMP TABLE SAMPLE_CUSTOMERS AS
      SELECT '1' || right('00' || (phone / 10000), 3) || '555' || right('000' || (phone % 10000), 4) as phone, now() as inserted_at, now() as updated_at
      FROM generate_series(START_AT, FINISH_AT) as phone;
    
      /* hack - insert any generated records that don't already exist in the database */
      INSERT INTO customers(phone, inserted_at, updated_at)
      SELECT phone, inserted_at, updated_at FROM SAMPLE_CUSTOMERS WHERE phone NOT IN (SELECT phone from customers);
    ELSE
      CREATE TEMP TABLE SAMPLE_CUSTOMERS AS
      SELECT '1' || right('00' || (phone / 10000), 3) || '555' || right('000' || (phone % 10000), 4) as phone, now() as inserted_at, now() as updated_at
      FROM generate_series(START_AT, FINISH_AT) as phone;

      INSERT INTO customers(phone, inserted_at, updated_at)
      SELECT phone, inserted_at, updated_at FROM SAMPLE_CUSTOMERS;
    END IF;

    CUSTOMERS_CATEGORIES := (SELECT EXISTS(SELECT id FROM customers INNER JOIN customers_categories ON customers_categories.customer_id = customers.id WHERE phone='10005550003'));
    IF CUSTOMERS_CATEGORIES = FALSE THEN
      INSERT INTO customers_categories(customer_id, category_id)
      (
        SELECT id, floor(random()*4+1) FROM customers WHERE phone IN (SELECT phone from SAMPLE_CUSTOMERS)
        UNION ALL
        SELECT id, floor(random()*4+5) FROM customers WHERE phone IN (SELECT phone from SAMPLE_CUSTOMERS)
      );
    END IF;

    INSERT INTO memberships(customer_id, business_id, inserted_at, updated_at)
    SELECT id, biz_id, date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM customers WHERE phone IN (SELECT phone FROM SAMPLE_CUSTOMERS)
    ON CONFLICT (customer_id, business_id) 
    DO NOTHING;

    INSERT INTO membership_locations(membership_id, location_id, inserted_at, updated_at)
    SELECT id, loc_id, date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM memberships WHERE business_id = biz_id AND customer_id in (SELECT id FROM customers WHERE phone IN (SELECT phone from SAMPLE_CUSTOMERS));

    INSERT INTO visits(customer_id, location_id, inserted_at, updated_at)
    SELECT customer_id, loc_id, date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM memberships WHERE business_id=biz_id LIMIT VISIT_LIMIT;

    INSERT INTO visits(customer_id, location_id, inserted_at, updated_at)
    SELECT customer_id, loc_id, date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM memberships WHERE business_id=biz_id LIMIT VISIT_LIMIT;

    INSERT INTO transactions(customer_id, location_id, type, meta, units, inserted_at, updated_at)
    SELECT customer_id, loc_id, 'credit', '{}', floor(random()*2+1), date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM memberships WHERE business_id=biz_id LIMIT REWARD_LIMIT;

    /* Insert deals and rewards */
    INSERT INTO customer_deals(name, expires, redeemed, deal_id, customer_id, location_id, inserted_at, updated_at)
    SELECT deals.name, deals.expiry, date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, deals.id, customer_id, loc_id, date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM memberships 
    INNER JOIN deals ON deals.id IN (SELECT id FROM deals WHERE business_id=biz_id LIMIT 1)
    WHERE memberships.business_id=biz_id LIMIT DEAL_LIMIT;

    INSERT INTO customer_rewards(name, type, expires, redeemed, reward_id, customer_id, location_id, points, inserted_at, updated_at)
    SELECT rewards.name, rewards.type, null, date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, rewards.id, customer_id, loc_id, floor(random()*10+1), date_trunc('MONTH',MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM memberships 
    INNER JOIN rewards ON rewards.business_id=biz_id and rewards.location_id=loc_id and rewards.type=(select ('[0:4]={loyalty,first_time,referral,birthday,facebook}'::text[])[trunc(random()*5)]) and rewards.is_active = true
    WHERE memberships.business_id=biz_id LIMIT REWARD_LIMIT;

    REFERRAL_ID := (SELECT id FROM customers LIMIT 1);

    INSERT INTO referrals(recipient_phone, is_completed, business_id, location_id, from_customer_id, to_customer_id, inserted_at, updated_at)
    SELECT phone, true, biz_id, loc_id, REFERRAL_ID, id, date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM customers WHERE phone IN (SELECT phone FROM SAMPLE_CUSTOMERS) LIMIT REFERRAL_LIMIT;

    /* create sms_log records to simulate sending of texts */
    INSERT INTO sms_log(phone, uuid, entity_id, customer_id, location_id, type, status, message, inserted_at, updated_at)
    SELECT '1111111', uuid_generate_v4(), 1, id, loc_id, 'campaign', 'queued', 'test message', date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM customers WHERE phone IN (SELECT phone FROM SAMPLE_CUSTOMERS) LIMIT SMS_LIMIT;

    /* create sms_log records to simulate sending surveys */
    INSERT INTO sms_log(phone, uuid, entity_id, customer_id, location_id, type, status, message, inserted_at, updated_at)
    SELECT '1111111', uuid_generate_v4(), 1, id, loc_id, 'campaign', 'queued', SURVEY_DOMAIN, date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM customers WHERE phone IN (SELECT phone FROM SAMPLE_CUSTOMERS) LIMIT SMS_LIMIT / 10;

    /* create sms_log simulating errors */
    INSERT INTO sms_log(phone, uuid, entity_id, customer_id, location_id, type, status, message, error_code, inserted_at, updated_at)
    SELECT '1111111', uuid_generate_v4(), campaigns.id, customers.id, loc_id, 'campaign', 'sent', '', ('[0:5]={30,50,90,100,200,null}'::int[])[trunc(random() * 6)], date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date FROM customers  
    INNER JOIN campaigns on campaigns.business_id = biz_id
    WHERE customers.phone IN (SELECT phone FROM SAMPLE_CUSTOMERS)
    ORDER BY customers.id
    LIMIT 32;

    UPDATE sms_log SET error_message = 'Spam detected', status = 'failed' WHERE error_code = 30;
    UPDATE sms_log SET error_message = 'Invalid phone number', status = 'failed' WHERE error_code = 50;
    UPDATE sms_log SET error_message = 'No route available', status = 'undelivered' WHERE error_code = 90;
    UPDATE sms_log SET error_message = 'Prohibited by carrier', status = 'failed' WHERE error_code = 100;
    UPDATE sms_log SET error_message = 'Phone number replied STOP', status = 'undelivered' WHERE error_code = 200;

    /* slight hack to get dates */  
    DATE1 := (SELECT date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval);
    DATE2 := (SELECT date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval);
    DATE3 := (SELECT date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval);
    DATE4 := (SELECT date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval);
    DATE5 := (SELECT date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval);

    TIMEZONE := (SELECT locations.timezone->>'id' FROM locations WHERE id = loc_id);

    /* Campaigns */
    INSERT INTO campaigns(business_id, location_id, message, send_now, scheduled, sent, send_date, send_time, is_active, survey_id, deal_id, timezone, inserted_at, updated_at)
    (
      SELECT biz_id, loc_id, E'GOOD MORNING!!!', false, true, false, DATE1, DATE1, true, null::bigint, null::bigint, TIMEZONE, DATE1, DATE1 
      UNION ALL
      SELECT biz_id, loc_id, E'HAPPY FRIDAY FAM!! HAVE A SAFE WEEKEND!!!', false, true, false, DATE2, DATE2, true, null::bigint, null::bigint, TIMEZONE, DATE2, DATE2 
      UNION ALL
      SELECT biz_id, loc_id, E'HAPPY MONDAY!! Come in and get todays deal! $2 off', true, true, true, DATE3, null, true, null::bigint, null::bigint, TIMEZONE, DATE3, DATE3 
      UNION ALL
      SELECT biz_id, loc_id, E'HAPPY SATURDAY!!!!!', true, true, true, DATE4, null, true, null::bigint, null::bigint, TIMEZONE, DATE4, DATE4 
      UNION ALL
      SELECT biz_id, loc_id, E'*Stop in today!', true, true, true, DATE5, null, true, null::bigint, null::bigint, TIMEZONE, DATE5, DATE5
    );
  
    /* Delete dupe unscheduled campaigns */
    DELETE FROM campaigns WHERE id IN (
      SELECT id FROM campaigns WHERE id > (SELECT id FROM campaigns WHERE business_id = biz_id AND scheduled = true AND sent = false LIMIT 1) 
      AND scheduled = true AND sent = false AND business_id = biz_id
    );
    
    /* Campaign member groups */
    INSERT INTO campaigns_groups(campaign_id, member_group_id)
    SELECT id, 1 FROM campaigns WHERE business_id = biz_id AND inserted_at BETWEEN DATE1 AND DATE5;

    /* Campaign customers */
    INSERT INTO campaigns_customers(campaign_id, customer_id)
    (
      SELECT campaigns.id, customer_id FROM campaigns
      INNER JOIN memberships ON memberships.business_id = campaigns.business_id
      WHERE campaigns.business_id = biz_id AND campaigns.inserted_at BETWEEN DATE1 AND DATE5
    );

    /* Campaign categories */
    INSERT INTO campaigns_categories(campaign_id, category_id)
    SELECT id, 1 FROM campaigns WHERE business_id = biz_id AND inserted_at BETWEEN DATE1 AND DATE5;

    NUM_CUSTOMERS := (SELECT COUNT(customer_id) FROM campaigns
              INNER JOIN memberships ON memberships.business_id = campaigns.business_id
              WHERE campaigns.business_id = biz_id); 
  
    /* Campaign events */
    INSERT INTO campaigns_events(campaign_id, customer_id, location_id, type, inserted_at, updated_at)
    (
      SELECT campaigns.id, customer_id, loc_id, ('[0:3]={click,click,click,bounce}'::text[])[trunc(random()*4)], campaigns.send_date, campaigns.send_date FROM campaigns
      INNER JOIN memberships ON memberships.business_id = campaigns.business_id
      WHERE campaigns.sent = true AND campaigns.business_id = biz_id AND campaigns.inserted_at BETWEEN DATE1 AND DATE5 LIMIT (random() * NUM_CUSTOMERS + 1)
    );
  
    /* remove campaigns that don't have customers */
    DELETE FROM campaigns WHERE id in (
      SELECT DISTINCT(id) FROM campaigns
      LEFT OUTER JOIN campaigns_customers ON campaigns_customers.campaign_id = campaigns.id
      WHERE customer_id IS NULL AND location_id IS NULL and business_id = biz_id
    );

    /* Surveys */
    HAS_SURVEY := (SELECT EXISTS(SELECT id FROM surveys WHERE business_id = biz_id));
    IF HAS_SURVEY = FALSE THEN
      INSERT INTO surveys(name, content, business_id, location_id, is_active, inserted_at, updated_at)
      SELECT 'Customer Feedback', '{"pages":[{"name":"page1","elements":[{"type":"text","name":"question1","title":"How was your experience with us?"},{"type":"rating","name":"question2","title":"How would you rate the cleanliness of our store?"},{"type":"rating","name":"question3","title":"How would you rate the quality of our products?"},{"type":"checkbox","name":"question4","title":"Would you recommend us to your friends?","choices":[{"value":"item1","text":"Yes"},{"value":"item2","text":"No"}]},{"type":"text","name":"question5","title":"What deals would you like to see offered?"}]}]}', biz_id, loc_id, true, date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date;
    END IF;
  
    /* Reviews */
    INSERT INTO reviews(customer_id, location_id, content, rating, completed, inserted_at, updated_at)
    (
      SELECT customer_id, loc_id, ('[0:9]={wow!,Great product and service!,Long lineups,Love your loyalty program,Budtenders rock,Very clean and professional,Dope,Best dispensary in town,OGK 4 Lyfe,Awesome}'::text[])[trunc(random()*10)], ('[0:3]={2,3,4,5}'::integer[])[trunc(random()*4)], true, MONTH_DATE::date, date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval 
      FROM surveys
      INNER JOIN memberships ON memberships.business_id = surveys.business_id
      INNER JOIN customers ON memberships.customer_id = customers.id
      WHERE surveys.business_id = biz_id AND customers.phone IN (SELECT phone FROM SAMPLE_CUSTOMERS) LIMIT (random() * 5 + 4)
    )
    ON CONFLICT (customer_id, location_id) 
    DO NOTHING;

    INSERT INTO survey_submissions(survey_id, location_id, customer_id, answers, inserted_at, updated_at)
    (
      SELECT surveys.id, loc_id, customer_id, 
      (array['{"question1":"Great!","question2":3,"question3":4,"question4":["item1"],"question5":"AK-47"}', '{"question1":"Best Dispensary in town.","question2":5,"question3":5,"question4":["item1"],"question5":"Would love to see Hindu Kush in stock."}', '{"question1":"Wonderful staff and atmosphere.","question2":4,"question3":4,"question4":["item1"],"question5":"BOGO pre-rolls"}', '{"question1":"Long lineups","question2":3,"question3":3,"question4":["item2"],"question5":"Faster service"}','{"question1":"My favorite store!","question2":5,"question3":5,"question4":["item1"],"question5":"I would like to see more edible deals"}'])[floor(random() * 5 + 1)], 
      date_trunc('MONTH', MONTH_DATE::date) + trunc(random() * DATE_PART('days', DATE_TRUNC('month', MONTH_DATE::date) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)) * '1 day'::interval + trunc(random()*23)  * '1 hour'::interval, MONTH_DATE::date 
      FROM surveys
      INNER JOIN memberships ON memberships.business_id = surveys.business_id
      INNER JOIN customers ON memberships.customer_id = customers.id
      WHERE surveys.business_id = biz_id AND customers.phone IN (SELECT phone FROM SAMPLE_CUSTOMERS) LIMIT (random() * 20 + 1)
    );

    /* Increment the month and run the loop again or exit */
    MONTH := MONTH + 1;

    IF MONTH > 12 THEN
      EXIT;  -- exit loop
    END IF;
  END LOOP;
END;
$function$;