defmodule Store.Repo.Migrations.DataMigrationAddNoShowsGroup do
  use Ecto.Migration
  use Store.Model

  def change do
    {:ok, no_shows} = %{id: 10, name: "No shows"} |> MemberGroup.create()
    change_entity(Campaign)
  end

  def change_entity(entity) do
    from(e in entity,
      join: groups in assoc(e, :groups),
      preload: [groups: groups],
      select: [:id, groups: [:id]]
    )
    |> Repo.all()
    |> Enum.map(fn obj ->
      if length(obj.groups) == 8 do
        obj
        |> Ecto.Changeset.change(%{groups: [1]})
        |> Repo.update()
      end
    end)
  end
end
