defmodule ComponentsExamples.Library.Author do
  use Ecto.Schema
  import Ecto.Changeset

  alias ComponentsExamples.Library.AuthorBook

  schema "authors" do
    field :bio, :string
    field :birth_date, :string
    field :gender, :string
    field :name, :string

    many_to_many :books, AuthorBook, join_through: "author_books"

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :bio, :gender, :birth_date])
    |> validate_required([:name, :bio, :gender, :birth_date])
  end
end
