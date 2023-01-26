defmodule Store.Loyalty do
  @moduledoc """
  Loyalty context
  """
  alias Store.Loyalty.{
    Deal,
    Reward,
    CustomerDeal,
    CustomerReward,
    ReferralLink,
    Transaction
  }

  alias Store.Inventory.{Category}

  alias Store.CustomerNote
  ##################################
  # Reward related functions
  ##################################

  def get_signup_reward(location_id) do
    Reward.get_by_location_and_type(location_id, "first_time")
  end

  def get_rewards(business_id, location_ids) do
    Reward.get_all(business_id, location_ids)
  end

  def create_reward(reward) do
    Reward.create(reward)
  end

  def generate_rewards(%{location: location}) do
    category_ids = Category.get_all() |> Enum.map(fn c -> c.id end)

    rewards =
      Enum.map(Reward.reward_types(), fn type ->
        now = DateTime.utc_now()

        %{
          name: "1 Free Gram",
          type: type,
          points: map_points(type),
          categories: category_ids,
          business_id: location.business_id,
          location_id: location.id,
          is_active: false,
          inserted_at: now,
          updated_at: now
        }
        |> Reward.create()
      end)

    {:ok, length(rewards)}
  end

  # this should only be used for rewards that have not yet been earned - no
  # instance of a customer_reward, but need to be created during queing
  # A good example is a birthday reward!!!!
  def queue_reward(customer_id, reward_id) do
    expiry_date = Timex.shift(DateTime.utc_now(), minutes: 15)

    # @TODO - if it's a birthday reward, potentially expire at end of day today

    with {:ok, reward} <- Reward.get_active_reward(reward_id),
         {:ok, reward_obj} <-
           {:ok,
            %{
              name: reward.name,
              type: reward.type,
              points: reward.points,
              expires: expiry_date,
              reward_id: reward.id,
              customer_id: customer_id,
              location_id: reward.location_id
            }},
         {:ok, _} <- CustomerReward.can_queue(customer_id, reward_id),
         {:ok, customer_reward} <- CustomerReward.create(reward_obj) do
      {:ok, customer_reward}
    else
      err -> err
    end
  end

  # The customer reward already exists and we are simply adding an expiry
  # datetime to it!!!!
  def queue_customer_reward(customer_id, customer_reward_id) do
    expiry_date = Timex.shift(DateTime.utc_now(), minutes: 15)

    case CustomerReward.set_expiry(customer_id, customer_reward_id, expiry_date) do
      {:ok, customer_reward} -> {:ok, customer_reward}
      {:error, _} -> {:error, "Cannot find customer reward"}
    end
  end

  def get_customer_reward(customer_id, customer_reward_id) do
    CustomerReward.get(customer_id, customer_reward_id)
  end

  def create_customer_reward(customer_id, reward_id) do
    with {:ok, reward} <- Reward.get_active_reward(reward_id),
         {:ok, reward_obj} <-
           {:ok,
            %{
              reward_id: reward.id,
              customer_id: customer_id,
              location_id: reward.location_id,
              name: reward.name,
              type: reward.type,
              points: reward.points
            }},
         {:ok, customer_reward} <- CustomerReward.create(reward_obj) do
      {:ok, customer_reward}
    else
      err -> err
    end
  end

  ##################################
  # Deal related functions
  ##################################

  def get_deal(id) do
    Deal.get(id)
  end

  def create_deal(deal) do
    Deal.create(deal)
  end

  def get_deals(business_id, location_id, options) do
    with {:ok, page} <- Deal.get_all(business_id, location_id, options),
         {:ok, deal_ids} <- {:ok, Enum.map(page.entries, fn deal -> deal.id end)},
         {:ok, claims} <- CustomerDeal.get_claims(deal_ids),
         {:ok, deals} <- map_claims_to_deals(page, claims) do
      {:ok, deals}
    else
      err -> err
    end
  end

  def get_customer_deal(customer_id, customer_deal_id) do
    CustomerDeal.get(customer_id, customer_deal_id)
  end

  # we can only queue this customer reward once - per customer
  # cannot have more than 1 of the same customer_reward active at a time!!!
  def queue_deal(customer_id, deal_id, location_id) do
    expiry_date = Timex.shift(DateTime.utc_now(), minutes: 15)

    with {:ok, deal} <- Deal.get_active_deal(deal_id),
         {:ok, deal_obj} <-
           {:ok,
            %{
              deal_id: deal.id,
              customer_id: customer_id,
              location_id: location_id,
              name: deal.name,
              expires: expiry_date
            }},
         # Ensure we don't already have this deal queued / non expired for this
         # customer and location before we create it!!!!
         {:ok, customer_deal} <- CustomerDeal.create(deal_obj) do
      {:ok, customer_deal}
    else
      err -> err
    end
  end

  ##################################
  # Customer Loyalty functions
  ##################################

  def coupon_history(customer_id, options) do
    with {:ok, deals} <- CustomerDeal.redemptions(customer_id, options),
         {:ok, rewards} <- CustomerReward.redemptions(customer_id, options) do
      {:ok, %{deals: deals, rewards: rewards}}
    else
      err -> err
    end
  end

  def loyalty_card(customer_id, location_id) do
    with {:ok, card} <- Reward.get_by_location(location_id, "loyalty"),
         {:ok, balance} <- Transaction.get_balance(customer_id, location_id) do
      {:ok, %{id: location_id, total: card.points, balance: balance, reward_id: card.id}}
    else
      err -> err
    end
  end

  def redeem_coupon(entity, customer_id, coupon_id) do
    case entity.redeem(customer_id, coupon_id) do
      {:ok, result} ->
        type =
          case entity do
            CustomerDeal -> "deal"
            CustomerReward -> "reward"
          end

        employee = Store.Employee.get_business_admin_by_location_id(result.location_id)

        CustomerNote.log_reward_redeemed(
          customer_id,
          result.location_id,
          employee.id,
          result,
          type
        )

        {:ok, result}

      e ->
        e
    end
  end

  def get_transaction_after_time_for_customer(start_time, customer_id) do
    case Transaction.get_for_customer_after_time(start_time, customer_id) do
      nil ->
        {:ok, nil}

      t ->
        {:ok, loyalty_card} = loyalty_card(customer_id, t.location_id)
        {:ok, memberships} = Store.memberships(customer_id)

        earned_reward =
          CustomerReward.get_loyalty_reward_after_time_for_customer(
            start_time,
            customer_id,
            t.location_id
          )

        t =
          t
          |> Map.put(:loyalty_card, loyalty_card)
          |> Map.put(:memberships, memberships)
          |> Map.put(:earned_reward, earned_reward)

        {:ok, t}
    end
  end

  ##################################
  # Referral related functions
  ##################################

  def create_referral_link(customer_id, location_id) do
    Store.Notify.customer_generated_referral_link(customer_id, location_id)
    ReferralLink.create(%{customer_id: customer_id, location_id: location_id})
  end

  def create_referral_reward(customer_id, reward_id) do
    with {:ok, reward} <- Reward.get_active_reward(reward_id),
         {:ok, reward_obj} <-
           {:ok,
            %{
              reward_id: reward.id,
              customer_id: customer_id,
              location_id: reward.location_id,
              name: reward.name,
              type: reward.type,
              points: reward.points
            }},
         {:ok, customer_reward} <- CustomerReward.create(reward_obj) do
      {:ok, customer_reward}
    else
      err -> err
    end
  end

  def get_shop(cipher) do
    with {:ok, link} <- ReferralLink.get_link(cipher),
         {:ok, reward} <- Reward.get_by_location(link.location_id, "referral") do
      {:ok, %{name: link.location.name, logo: link.location.logo, reward: reward.name}}
    else
      err -> err
    end
  end

  def get_shop_from_intent(cipher) do
    ReferralLink.decode(cipher)
  end

  ##################################
  # Private Helper functions
  ##################################

  defp map_points(type) do
    case type do
      "loyalty" -> 10
      _ -> 0
    end
  end

  defp map_claims_to_deals(page, claims) do
    deals =
      Enum.map(page.entries, fn deal ->
        claim =
          Enum.find(claims, %{count: 0}, fn claim ->
            claim.deal_id == deal.id
          end)

        Map.put(deal, :claims, claim.count)
      end)

    {:ok, Map.put(page, :entries, deals)}
  end
end
