defmodule Store.Repo.Migrations.DataMigrationAddMoreConditions do
  use Ecto.Migration

  def change do
    execute("
      INSERT INTO conditions(id, name, inserted_at, updated_at)
      SELECT 70, 'Depression', now(), now() UNION
      SELECT 71, 'Insomnia', now(), now() UNION
      SELECT 72, 'ADD/ADHD', now(), now() UNION
      SELECT 73, 'Eating Disorders', now(), now() UNION
      SELECT 74, 'Post-traumatic Pain', now(), now() UNION
      SELECT 75, 'Sleep Apnea', now(), now() UNION
      SELECT 76, 'Anything else the practitioner deems would be helped by the use of medication and increased quality of life', now(), now()
    ")
  end
end
