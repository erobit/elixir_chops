defmodule Store.Repo.Migrations.ChangeTableLocationAddTabletCustomizationFields do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:tablet_background_color, :string)
      add(:tablet_foreground_color, :string)
      add(:tablet_background_image, :string)
    end
  end
end
