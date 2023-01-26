defmodule Store.Repo.Migrations.AlterBusinessAddLanguageSetting do
  use Ecto.Migration
  use Store.Model

  def change do
    alter table(:businesses) do
      add(:language, :string, default: "en-us")
    end

    flush()

    from(b in Business)
    |> Repo.update_all(set: [language: "en-us"])
  end
end
