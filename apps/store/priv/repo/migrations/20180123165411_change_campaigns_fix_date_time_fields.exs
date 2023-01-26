defmodule Store.Repo.Migrations.ChangeCampaignsFixDateTimeFields do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      modify(:send_date, :date)
      add(:send_time, :time)
    end
  end
end
