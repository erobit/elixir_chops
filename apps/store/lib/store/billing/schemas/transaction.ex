defmodule Billing.Schemas.Transaction do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Store.Repo
  alias Billing.Schemas.{Profile, Card, Transaction}

  schema "billing_transactions" do
    belongs_to(:profile, Profile)
    belongs_to(:card, Card)
    field(:uuid, :binary_id)
    field(:payment_id, :string)
    field(:type, :string)
    field(:status, :string)
    field(:code, :string)
    field(:message, :string)
    field(:amount, :integer)
    timestamps(type: :utc_datetime)
  end

  def in_good_standing?(profile_id) do
    query =
      from(t in Transaction,
        join: p in assoc(t, :profile),
        where:
          p.id == ^profile_id and p.payment_type == "credit_card" and t.type == "payment" and
            (is_nil(p.billing_start) or fragment("? <= now()", p.billing_start)),
        order_by: [desc: t.inserted_at],
        limit: 1
      )

    case Repo.one(query) do
      nil -> true
      transaction -> transaction.status == "SUCCESS"
    end
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def is_first_payment?(profile_id) do
    query =
      from(t in Transaction,
        where: t.profile_id == ^profile_id and t.type == "payment"
      )

    case Repo.aggregate(query, :count, :id) do
      0 -> true
      _ -> false
    end
  end

  def has_been_paid?(profile_id) do
    query =
      from(t in Transaction,
        join: p in assoc(t, :profile),
        join: l in assoc(p, :location),
        where:
          t.profile_id == ^profile_id and t.type == "payment" and t.status == "SUCCESS" and
            fragment("to_char(now() AT TIME ZONE (?->>'id' || ''), 'YYYY-MM')", l.timezone) ==
              fragment(
                "to_char(? AT TIME ZONE (?->>'id' || ''), 'YYYY-MM')",
                t.inserted_at,
                l.timezone
              )
      )

    case Repo.aggregate(query, :count, :id) do
      0 -> false
      _ -> true
    end
  end

  defp insert(struct) do
    %Transaction{}
    |> changeset(struct)
    |> Repo.insert(returning: true)
  end

  defp update(struct) do
    Transaction
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(profile_id card_id payment_id type status code message amount)a
    )
    |> validate_required(~w(type profile_id)a)
  end
end
