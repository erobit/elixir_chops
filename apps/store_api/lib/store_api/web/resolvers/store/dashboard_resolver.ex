defmodule StoreAPI.Resolvers.Dashboard do
  alias StoreMetrics

  def metric_counts(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    with {:ok, signups} <- StoreMetrics.signup_count(employee.business_id, locations, period),
         {:ok, visits} <- StoreMetrics.visit_count(employee.business_id, locations, period),
         {:ok, stamps} <- StoreMetrics.stamp_count(employee.business_id, locations, period),
         {:ok, deals} <- StoreMetrics.deal_count(employee.business_id, locations, period),
         {:ok, rewards} <- StoreMetrics.reward_count(employee.business_id, locations, period),
         {:ok, referrals} <- StoreMetrics.referral_count(employee.business_id, locations, period),
         {:ok, sms} <- StoreMetrics.sms_count(employee.business_id, locations, period),
         {:ok, surveys_sent} <-
           StoreMetrics.surveys_sent_count(employee.business_id, locations, period),
         {:ok, surveys_submitted} <-
           StoreMetrics.surveys_submitted_count(employee.business_id, locations, period),
         {:ok, reviews_submitted} <-
           StoreMetrics.reviews_submitted_count(employee.business_id, locations, period),
         {:ok, reviews_average} <-
           StoreMetrics.reviews_average_count(employee.business_id, locations, period) do
      dashboard_metrics = %{
        signups: signups,
        visits: visits,
        stamps: stamps,
        deals: deals,
        rewards: rewards,
        referrals: referrals,
        surveys_sent: surveys_sent,
        surveys_submitted: surveys_submitted,
        reviews_submitted: reviews_submitted,
        reviews_average: reviews_average,
        total: deals + rewards,
        sms: sms
      }

      {:ok, dashboard_metrics}
    else
      err -> err
    end
  end

  def signup_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.signups(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def visit_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.visits(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def stamp_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.stamps(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def deal_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.deals(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def reward_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.rewards(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def referral_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.referrals(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def total_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.totals(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def sms_metrics(%{period: period, locations: locations}, %{context: %{employee: employee}}) do
    period = String.to_atom(period)

    case StoreMetrics.sms(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def surveys_sent_metrics(%{period: period, locations: locations}, %{
        context: %{employee: employee}
      }) do
    period = String.to_atom(period)

    case StoreMetrics.surveys_sent(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def surveys_submitted_metrics(%{period: period, locations: locations}, %{
        context: %{employee: employee}
      }) do
    period = String.to_atom(period)

    case StoreMetrics.surveys_submitted(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def reviews_submitted_metrics(%{period: period, locations: locations}, %{
        context: %{employee: employee}
      }) do
    period = String.to_atom(period)

    case StoreMetrics.reviews_submitted(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end

  def reviews_average_metrics(%{period: period, locations: locations}, %{
        context: %{employee: employee}
      }) do
    period = String.to_atom(period)

    case StoreMetrics.reviews_average(employee.business_id, locations, period) do
      {:ok, metrics} -> {:ok, metrics}
      {:error, error} -> {:error, error}
    end
  end
end
