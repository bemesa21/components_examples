defmodule ComponentsExamples.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string
      add :bio, :text
      add :gender, :string
      add :birth_date, :string

      timestamps()
    end
  end
end
