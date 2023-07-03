defmodule ComponentsExamples.Library.AuthorBook do
  use Ecto.Schema
  import Ecto.Changeset

  alias ComponentsExamples.Library.Book
  alias ComponentsExamples.Library.Author

  schema "author_books" do
    field :position, :integer
    belongs_to(:author, Author, primary_key: true)
    belongs_to(:book, Book, primary_key: true)
    timestamps()
  end

  @doc false
  def changeset(author_book, attrs, position) do
    author_book
    |> cast(attrs, [:author_id, :book_id])
    |> change(position: position)
    |> unique_constraint([:author, :book], name: "author_books_author_id_book_id_index")
  end
end
