defmodule Store.Repo.Migrations.CreateTableSurveySubmission do
  use Ecto.Migration

  def change do
    create table(:survey_submissions) do
      add(:customer_id, references(:customers), null: false)
      add(:answers, :text, null: false)
      add(:survey_id, references(:surveys), null: false)
      add(:location_id, references(:locations), null: false)
      timestamps(type: :timestamptz)
    end
  end
end
