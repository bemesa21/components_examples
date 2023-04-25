defmodule ComponentsExamples.SortableList.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :position, :integer
    field :status, Ecto.Enum, values: [:started, :completed], default: :started
    belongs_to :list, ComponentsExamples.SortableList.List

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:id, :name, :status])
    |> validate_required([:name, :status])
  end
end
