defmodule ComponentsExamplesWeb.LibraryLive do
  use ComponentsExamplesWeb, :live_view

  alias ComponentsExamplesWeb.MulfiFormComponent
  alias ComponentsExamplesWeb.AuthorFormComponent

  alias ComponentsExamples.Library
  alias ComponentsExamples.Library.Author
  alias ComponentsExamples.Library.Book

  @pagination %{
    next_page: nil,
    prev_page: nil,
    limit: 10,
    order_by: [title: :asc, publication_date: :desc]
  }

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :books, [])}
  end

  def render(assigns) do
    ~H"""
    <.link patch={~p"/library/book/new"}>
      <.button class="ml-2">New book</.button>
    </.link>

    <.link patch={~p"/library/author/new"}>
      <.button class="ml-2">New author</.button>
    </.link>

    <.modal
      :if={@live_action in [:new_book, :edit_book]}
      id="book-modal"
      show
      on_cancel={JS.patch(~p"/library/")}
    >
      <.live_component module={MulfiFormComponent} id="book_form" book={@book} action={@live_action} />
    </.modal>

    <.modal
      :if={@live_action in [:new_author, :edit_author]}
      id="author-modal"
      show
      on_cancel={JS.patch(~p"/library/")}
    >
      <.live_component
        module={AuthorFormComponent}
        id="author_form"
        author={@author}
        action={@live_action}
      />
    </.modal>

    <.table id="books" rows={@streams.books}>
      <:col :let={{_id, book}} label="id"><%= book.id %></:col>
      <:col :let={{_id, book}} label="title"><%= book.title %></:col>
      <:col :let={{_id, book}} label="authors">
        <div :for={author <- book.authors}>
          <span><%= author.name %></span>
        </div>
      </:col>
      <:col :let={{_id, book}} label="publication_date"><%= book.publication_date %></:col>
      <:col :let={{_id, book}}>
        <.link patch={~p"/library/book/#{book.id}/edit"} alt="Edit Book">
          <.icon name="hero-pencil-square" class="w-4 h-4 relative" />
        </.link>

        <.link
          phx-click="delete-book"
          phx-value-id={book.id}
          alt="delete book"
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash" class="w-4 h-4 relative" />
        </.link>
      </:col>
    </.table>

    <.paginator pagination_details={@pagination} name="library_paginator" />
    """
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event("delete-book", %{"id" => id}, socket) do
    {:ok, book} = Library.delete_book(id)
    {:noreply, stream_delete(socket, :books, book)}
  end

  defp apply_action(socket, :new_book, _params) do
    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, %Book{})
  end

  defp apply_action(socket, :edit_book, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Library.get_book(id))
  end

  defp apply_action(socket, :book_list, params) do
    socket
    |> assign(:page_title, "Books List")
    |> assign(:book, nil)
    |> list_books(params)
  end

  defp apply_action(socket, :new_author, _params) do
    socket
    |> assign(:page_title, "New author")
    |> assign(:author, %Author{})
  end

  defp list_books(socket, params) when params == %{} do
    {books, cursor} = Library.list_books(@pagination)

    pagination = %{@pagination | next_page: ~p"/library?after=#{cursor}"}

    socket
    |> assign(:pagination, pagination)
    |> stream(:books, books, reset: true)
  end

  defp list_books(socket, params) do
    {books, cursors} = Library.list_books(params, @pagination)

    pagination =
      case cursors do
        {nil, nil} ->
          @pagination

        {nil, next_cursor} ->
          %{@pagination | next_page: ~p"/library?limit=#{@pagination.limit}&after=#{next_cursor}"}

        {prev_cursor, nil} ->
          %{
            @pagination
            | prev_page: ~p"/library?limit=#{@pagination.limit}&before=#{prev_cursor}"
          }

        {prev_cursor, next_cursor} ->
          %{
            @pagination
            | prev_page: ~p"/library?limit=#{@pagination.limit}&before=#{prev_cursor}",
              next_page: ~p"/library?limit=#{@pagination.limit}&after=#{next_cursor}"
          }
      end

    socket
    |> assign(:pagination, pagination)
    |> stream(:books, books, reset: true)
  end
end
