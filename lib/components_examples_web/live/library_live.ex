defmodule ComponentsExamplesWeb.LibraryLive do
  use ComponentsExamplesWeb, :live_view

  alias ComponentsExamplesWeb.MulfiFormComponent
  alias ComponentsExamplesWeb.AuthorFormComponent

  alias ComponentsExamples.Library
  alias ComponentsExamples.Library.Author
  alias ComponentsExamples.Library.Book

  def mount(_params, _session, socket) do
    {:ok, socket}
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
      <.live_component module={MulfiFormComponent} id="book_form" book={@book} />
    </.modal>

    <.modal
      :if={@live_action in [:new_author, :edit_author]}
      id="author-modal"
      show
      on_cancel={JS.patch(~p"/library/")}
    >
      <.live_component module={AuthorFormComponent} id="author_form" author={@author} />
    </.modal>
    """
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_book, _params) do
    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, %Book{})
  end

  defp apply_action(socket, :edit_book, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Library.get_book!(id))
  end

  defp apply_action(socket, :book_list, _params) do
    socket
    |> assign(:page_title, "Books List")
    |> assign(:book, nil)
  end

  defp apply_action(socket, :new_author, _params) do
    socket
    |> assign(:page_title, "New author")
    |> assign(:author, %Author{})
  end
end
