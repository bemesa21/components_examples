defmodule ComponentsExamples.Library.Book do
  use Ecto.Schema
  import Ecto.Changeset

  alias ComponentsExamples.Library.AuthorBook

  schema "books" do
    field :price, :decimal
    field :publication_date, :utc_datetime
    field :title, :string

    has_many :book_authors, AuthorBook, preload_order: [asc: :position], on_replace: :delete
    has_many :authors, through: [:book_authors, :author], on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :publication_date, :price])
    |> validate_required([:title, :publication_date, :price])
    |> cast_assoc(:book_authors,
      with: &AuthorBook.changeset/3,
      sort_param: :authors_order,
      drop_param: :authors_drop
    )
  end
end
