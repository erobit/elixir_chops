defmodule Store.Repo.Migrations.DeleteTableReviewSettingsAddReviewRewards do
  use Ecto.Migration
  use Store.Model
  alias Store

  defp get_locations() do
    from(l in Location,
      select: [:id, :business_id]
    )
    |> Repo.all()
  end

  defp get_category_ids() do
    from(c in Category,
      select: [:id]
    )
    |> Repo.all()
    |> Enum.map(fn c -> c.id end)
  end

  defp delete_review_settings() do
    drop_if_exists(table("review_settings"))
  end

  defp create_review_reward(location, category_ids, now) do
    %{
      name: "1 Free Gram",
      type: "review",
      points: 0,
      categories: category_ids,
      business_id: location.business_id,
      location_id: location.id,
      is_active: false,
      inserted_at: now,
      updated_at: now
    }
    |> Reward.create()
  end

  def change do
    category_ids = get_category_ids()
    now = DateTime.utc_now()

    Enum.each(get_locations(), fn location ->
      create_review_reward(location, category_ids, now)
    end)

    delete_review_settings()
  end
end
