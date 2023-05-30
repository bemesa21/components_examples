defmodule ComponentsExamples.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :position, :integer
      add :status, :string
      add :list_id, references(:lists, on_delete: :delete_all)

      timestamps()
    end

    create index(:items, [:list_id])
  end
end
