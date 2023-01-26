defmodule Store.Repo.Migrations.UpdateTableCampaignsAddSurveyId do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add(:survey_id, references(:surveys))
    end
  end
end
