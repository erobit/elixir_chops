defmodule Store.Repo.Migrations.DataMigrationAddTopicalsCategory do
  use Ecto.Migration
  use Store.Model

  def change do
    {:ok, topicals} = %{id: 9, name: "topicals"} |> Category.create()
    change_entity(Deal, topicals)
    change_entity(Reward, topicals)
    change_entity(Campaign, topicals)
  end

  def change_entity(entity, new_category) do
    from(e in entity,
      join: c in assoc(e, :categories),
      preload: [categories: c],
      select: [:id, categories: [:id]]
    )
    |> Repo.all()
    |> Enum.map(fn obj ->
      if length(obj.categories) == 8 do
        categories = obj.categories ++ [new_category]

        obj
        |> Ecto.Changeset.change(%{categories: categories})
        |> Repo.update()
      end
    end)
  end
end
