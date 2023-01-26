defmodule StoreMetrics do
  @moduledoc """
  Contains metrics queries used for reporting.
  `StoreMetrics` is used by the `Store.API` phoenix app.
  """

  use Store.Model

  # dashboard metrics - not aggregated counts

  def signups(business_id, location_ids, period) do
    MembershipLocation.metrics(business_id, location_ids, period)
  end

  def visits(business_id, location_ids, period) do
    Visit.metrics(business_id, location_ids, period)
  end

  def stamps(business_id, location_ids, period) do
    Transaction.metrics("credit", business_id, location_ids, period)
  end

  ## Deal Counts

  def deals(business_id, location_ids, period) do
    CustomerDeal.metrics(business_id, location_ids, period)
  end

  ## Reward Counts

  def rewards(business_id, location_ids, period) do
    CustomerReward.metrics(business_id, location_ids, period)
  end

  ## Survey metrics
  def surveys_sent(_business_id, location_ids, period) do
    domain = System.get_env("DOMAIN")
    SMSLog.metrics(location_ids, period, ["campaign"], "#{domain}/s/")
  end

  def surveys_submitted(business_id, location_ids, period) do
    SurveySubmission.metrics(business_id, location_ids, period)
  end

  def reviews_submitted(business_id, location_ids, period) do
    Review.metrics(business_id, location_ids, period, :count)
  end

  def reviews_average(business_id, location_ids, period) do
    Review.metrics(business_id, location_ids, period, :avg)
  end

  ## Referrals

  def referrals(business_id, location_ids, period) do
    Referral.metrics(business_id, location_ids, period)
  end

  def totals(business_id, location_ids, period) do
    {:ok, reward_metrics} = rewards(business_id, location_ids, period)
    {:ok, deal_metrics} = deals(business_id, location_ids, period)

    result =
      Enum.concat(reward_metrics, deal_metrics)
      |> Enum.group_by(fn v -> v.created end)
      |> Enum.map(fn {k, v} ->
        %{
          id: k,
          created: k,
          value: Enum.reduce(v, 0, fn r, acc -> r.value + acc end)
        }
      end)

    {:ok, result}
  end

  def sms(_business_id, location_ids, period) do
    SMSLog.metrics(location_ids, period, ["campaign"], nil)
  end

  ### Count related metrics

  def signup_count(business_id, location_ids, period) do
    MembershipLocation.metrics_count(business_id, location_ids, period)
  end

  def visit_count(business_id, location_ids, period) do
    Visit.metrics_count(business_id, location_ids, period)
  end

  def stamp_count(business_id, location_ids, period) do
    Transaction.metrics_count("credit", business_id, location_ids, period)
  end

  def deal_count(business_id, location_ids, period) do
    CustomerDeal.metrics_count(business_id, location_ids, period)
  end

  def reward_count(business_id, location_ids, period) do
    CustomerReward.metrics_count(business_id, location_ids, period)
  end

  def referral_count(business_id, location_ids, period) do
    Referral.metrics_count(business_id, location_ids, period)
  end

  def sms_count(_business_id, location_ids, period) do
    SMSLog.metrics_count(location_ids, period, ["campaign"], nil)
  end

  def surveys_sent_count(_business_id, location_ids, period) do
    domain = System.get_env("DOMAIN")
    SMSLog.metrics_count(location_ids, period, ["campaign"], "#{domain}/s/")
  end

  def surveys_submitted_count(business_id, location_ids, period) do
    SurveySubmission.metrics_count(business_id, location_ids, period)
  end

  def reviews_submitted_count(business_id, location_ids, period) do
    Review.metrics_count(business_id, location_ids, period, :count)
  end

  def reviews_average_count(business_id, location_ids, period) do
    Review.metrics_count(business_id, location_ids, period, :avg)
  end

  # Customer counts
  def customers_all_count(location_ids, customer_id) do
    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Membership.customers_all_count()
  end

  def customers_loyal_count(location_ids, customer_id) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Visit.customers_loyal_count(location_id)
  end

  def customers_casual_count(location_ids, customer_id) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Visit.customers_casual_count(location_id)
  end

  def customers_lapsed_count(location_ids, customer_id) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Customer.lapsed_count(location_id)
  end

  def customers_last_mile_count(location_ids, customer_id) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Transaction.customers_last_mile_count(location_id)
  end

  def customers_hoarder_count(location_ids, customer_id) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> CustomerReward.customers_hoarder_count(location_id)
  end

  def customers_spender_count(location_ids, customer_id) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> CustomerReward.customers_spender_count(location_id)
  end

  def customers_referral_count(location_ids, customer_id) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Referral.customers_referral_count(location_id)
  end

  def customers_birthday_count(location_ids, customer_id) do
    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Membership.customers_birthday_count()
  end

  def customers_no_show_count(location_ids, customer_id) do
    MembershipLocation.active_customer_ids(location_ids)
    |> by_customer(customer_id)
    |> Customer.no_show_count(location_ids)
  end

  defp by_customer(customer_ids, nil), do: customer_ids

  defp by_customer(customer_ids, customer_id) do
    Enum.filter(customer_ids, fn c -> c == customer_id end)
  end

  # Customer Frequency segments

  def customer_segments(business_id, location_ids, options, :all) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customers_query(location_ids)
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :loyal) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Visit.customers_loyal_query(location_id)
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :casual) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Visit.customers_casual_query(location_id)
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :lapsed) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Customer.lapsed_query(location_id)
    |> Customer.segment(options, business_id, location_id)
  end

  # Customer Loyalty segments
  def customer_segments(business_id, location_ids, options, :last_mile) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Transaction.customers_last_mile_query(location_id)
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :hoarders) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> CustomerReward.customers_hoarder_query(location_id)
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :spenders) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> CustomerReward.customers_spender_query(location_id)
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :top_referrals) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Referral.customers_referral_query(location_id)
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :birthdays) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Membership.customers_birthday_query()
    |> Customer.segment(options, business_id, location_id)
  end

  def customer_segments(business_id, location_ids, options, :no_shows) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Customer.no_show_query(location_ids)
    |> Customer.segment(options, business_id, location_id)
  end

  # campaign customer segments

  def campaign_customer_segments(location_ids, options, :all) do
    MembershipLocation.active_customers_query(location_ids)
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :loyal) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Visit.customers_loyal_query(location_id)
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :casual) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Visit.customers_casual_query(location_id)
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :lapsed) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Customer.lapsed_query(location_id)
    |> Customer.campaign_segment(options)
  end

  # Customer Loyalty segments
  def campaign_customer_segments(location_ids, options, :last_mile) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Transaction.customers_last_mile_query(location_id)
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :hoarders) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> CustomerReward.customers_hoarder_query(location_id)
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :spenders) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> CustomerReward.customers_spender_query(location_id)
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :top_referrals) do
    location_id = Enum.at(location_ids, 0)

    MembershipLocation.active_customer_ids(location_ids)
    |> Referral.customers_referral_query(location_id)
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :birthdays) do
    MembershipLocation.active_customer_ids(location_ids)
    |> Membership.customers_birthday_query()
    |> Customer.campaign_segment(options)
  end

  def campaign_customer_segments(location_ids, options, :no_shows) do
    MembershipLocation.active_customer_ids(location_ids)
    |> Customer.no_show_query(location_ids)
    |> Customer.campaign_segment(options)
  end
end
