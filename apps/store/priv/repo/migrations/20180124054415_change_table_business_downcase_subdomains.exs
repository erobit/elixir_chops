defmodule Store.Repo.Migrations.ChangeTableBusinessDowncaseSubdomains do
  use Ecto.Migration

  def change do
    execute("UPDATE businesses SET subdomain = lower(subdomain)")
  end
end
