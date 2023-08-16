defmodule ComponentsExamples.Library do
  @moduledoc """
  The Library context.
  """

  import Ecto.Query, warn: false
  alias ComponentsExamples.Repo

  alias ComponentsExamples.Library.Author
  alias ComponentsExamples.Library.Book

  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id), do: Repo.get!(Author, id)

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{data: %Author{}}

  """
  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single book.

  ## Examples

      iex> get_book(123)
      %Book{}

      iex> get_book!(456)
      nil

  """
  def get_book(id), do: Repo.get(Book, id) |> Repo.preload([:book_authors])

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Author{}, ...]

  """

  def list_books(opts) do
    books =
      Book
      |> generate_query(opts)
      |> preload(:authors)
      |> Repo.all()

    {books, encode(List.last(books).id)}
  end

  def list_books(%{"after" => cursor}, opts) do
    books = list_books(cursor, opts, :after)

    case {length(books) > 0, has_next_page?(books, opts)} do
      {true, true} ->
        {_last, books} = List.pop_at(books, -1)
        {books, {encode(hd(books).id), encode(List.last(books).id)}}

      {true, false} ->
        {books, {encode(hd(books).id), nil}}

      {_, _} ->
        {books, {nil, nil}}
    end
  end

  def list_books(%{"before" => cursor}, opts) do
    books = list_books(cursor, opts, :before)

    case {length(books) > 0, has_prev_page?(books, opts)} do
      {true, true} ->
        {_last, books} = List.pop_at(books, -1)
        books = Enum.reverse(books)
        {books, {encode(hd(books).id), encode(List.last(books).id)}}

      {true, false} ->
        books = Enum.reverse(books)
        {books, {nil, encode(List.last(books).id)}}

      {_, _} ->
        {books, {nil, nil}}
    end
  end

  defp list_books(cursor, opts, direction) do
    case decode(cursor) do
      {:ok, book} ->
        limit = Map.get(opts, :limit, 10)

        book =
          book
          |> get_book()
          |> Map.from_struct()

        opts =
          if direction == :after do
            opts
          else
            invert_direction(opts)
          end

        Book
        |> generate_query(opts, book)
        |> preload(:authors)
        |> Repo.all()

      {:error, _} ->
        {[], nil}
    end
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book_id)
      {:ok, %Book{}}

      iex> delete_book(book_id)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(book_id) do
    Book
    |> Repo.get!(book_id)
    |> Repo.delete()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  def encode(term) do
    salt =
      Application.get_env(:components_examples, ComponentsExamplesWeb.Endpoint)[:live_view][
        :signing_salt
      ]

    Phoenix.Token.encrypt(ComponentsExamplesWeb.Endpoint, salt, term)
  end

  def decode(cursor) do
    salt =
      Application.get_env(:components_examples, ComponentsExamplesWeb.Endpoint)[:live_view][
        :signing_salt
      ]

    case Phoenix.Token.decrypt(ComponentsExamplesWeb.Endpoint, salt, cursor, max_age: :infinity) do
      {:ok, data} ->
        {:ok, data}

      {:error, reason} ->
        inspect("Invalid cursor: #{reason}")
        {:error, nil}
    end
  end

  defp generate_query(base_query, opts, cursor) do
    limit = Map.get(opts, :limit, 10)

    base_query
    |> order_by(^filter_order_by(opts))
    |> where(^filter_where(opts, cursor))
    |> limit(^limit + 1)
  end

  defp generate_query(base_query, opts) do
    limit = Map.get(opts, :limit, 10)

    base_query
    |> order_by(^filter_order_by(opts))
    |> limit(^limit)
  end

  # uuid
  defp filter_where(opts, cursor) do
    opts
    |> Map.get(:order_by, id: :asc)
    |> Enum.reduce({dynamic(true), nil}, fn
      {key, :asc}, {dynamic, nil} ->
        {dynamic([b], ^dynamic and field(b, ^key) > ^cursor[key]), key}

      {key, :asc}, {dynamic, last_key} ->
        {dynamic(
           [b],
           ^dynamic or
             (field(b, ^last_key) == ^cursor[last_key] and field(b, ^key) > ^cursor[key])
         ), key}

      {key, :desc}, {dynamic, nil} ->
        {dynamic([b], ^dynamic and field(b, ^key) < ^cursor[key]), key}

      {key, :desc}, {dynamic, last_key} ->
        {dynamic(
           [b],
           ^dynamic or
             (field(b, ^last_key) == ^cursor[last_key] and field(b, ^key) < ^cursor[key])
         ), key}
    end)
    |> then(fn {query, _} -> query end)
  end

  defp filter_order_by(opts) do
    opts
    |> Map.get(:order_by, id: :asc)
    |> Enum.map(fn {key, dir} ->
      {dir, key}
    end)
  end

  defp invert_direction(opts) do
    new_opts =
      opts
      |> Map.get(:order_by, id: :asc)
      |> Enum.map(fn
        {key, :asc} -> {key, :desc}
        {key, :desc} -> {key, :asc}
      end)

    %{opts | order_by: new_opts}
  end

  def has_next_page?(results, opts) do
    length(results) > Map.get(opts, :limit, 10)
  end

  def has_prev_page?(results, opts) do
    length(results) > Map.get(opts, :limit, 10)
  end
end
