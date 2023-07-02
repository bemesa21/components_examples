defmodule ComponentsExamples.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :author, :string
      add :publication_date, :utc_datetime
      add :price, :decimal

      timestamps()
    end
  end
end
