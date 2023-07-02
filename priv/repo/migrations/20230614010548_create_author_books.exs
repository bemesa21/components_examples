defmodule ComponentsExamples.Repo.Migrations.CreateAuthorBooks do
  use Ecto.Migration

  def change do
    create table(:author_books) do
      add :author_id, references(:authors, on_delete: :delete_all)
      add :book_id, references(:books, on_delete: :delete_all)
      add :position, :integer, null: false

      timestamps()
    end

    create unique_index(:author_books, [:author_id, :book_id])
  end
end
