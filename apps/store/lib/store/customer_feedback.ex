defmodule Store.CustomerFeedback do
  use Store.Model

  schema "customer_feedback" do
    field(:feedback, :string)
    belongs_to(:customer, Store.Customer)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  defp insert(struct) do
    struct = sanitize(struct)

    %CustomerFeedback{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp sanitize(struct) do
    feedback = HtmlSanitizeEx.strip_tags(struct.feedback)
    Map.put(struct, :feedback, feedback)
  end

  defp update(struct) do
    CustomerFeedback
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(customer_id feedback)a)
    |> validate_required(~w(customer_id feedback)a)
  end
end
