defmodule Store.Repo.Migrations.ChangeTableCampaignsAddFieldTimezone do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add(:timezone, :string)
    end

    flush()

    execute(
      "UPDATE campaigns SET timezone = (select timezone->>'id' from locations where business_id=campaigns.business_id LIMIT 1);"
    )
  end
end
