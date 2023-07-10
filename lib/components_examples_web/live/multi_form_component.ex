defmodule ComponentsExamplesWeb.MulfiFormComponent do
  use ComponentsExamplesWeb, :live_component

  alias ComponentsExamples.Library.AuthorBook
  alias ComponentsExamples.Library

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-change="validate" phx-submit="save" phx-target={@myself} class="" as="prieba">
        <h1 class="text-md font-semibold leading-8 text-zinc-800">
          New Book
        </h1>
        <.input type="text" field={@form[:title]} placeholder="Title" />
        <.input type="datetime-local" field={@form[:publication_date]} placeholder="Publication Date" />
        <.input type="number" field={@form[:price]} placeholder="Price" />
        <h1 class="text-md font-semibold leading-8 text-zinc-800">
          Authors
        </h1>

        <div id="authors" phx-hook="SortableInputsFor" class="space-y-2">
          <.inputs_for :let={b_author} field={@form[:book_authors]}>
            <div class="flex space-x-2 drag-item">
              <.icon name="hero-bars-3" class="w-6 h-6 relative top-2" data-handle />
              <input type="hidden" name="book[authors_order][]" value={b_author.index} />
              <.input
                type="select"
                field={b_author[:author_id]}
                placeholder="Author"
                options={@authors}
              />
              <label>
                <input
                  type="checkbox"
                  name="book[authors_delete][]"
                  value={b_author.index}
                  class="hidden"
                />
                <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
              </label>
            </div>
          </.inputs_for>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">
            Save
          </.button>

          <label class="block cursor-pointer">
            <input type="checkbox" name="book[authors_order][]" class="hidden" />
            <.icon name="hero-plus-circle" /> add more
          </label>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{book: book} = assigns, socket) do
    book_changeset = Library.change_book(book)

    socket =
      socket
      |> assign(assigns)
      |> assign_form(book_changeset)
      |> assign_authors()

    {:ok, socket}
  end

  def handle_event("save", %{"book" => book_params} = _param, socket) do
    save_book(socket, socket.assigns.action, book_params)
  end

  def handle_event("validate", %{"book" => book_params} = _params, socket) do
    book_form =
      socket.assigns.book
      |> Library.change_book(book_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, book_form)}
  end

  defp save_book(socket, :edit_book, book_params) do
    case Library.update_book(socket.assigns.book, book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/library/")
         |> put_flash(:info, "Book updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :edit)

        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_book(socket, :new_book, book_params) do
    case Library.create_book(book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/library/")
         |> put_flash(:info, "Book created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :insert)

        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    if Ecto.Changeset.get_field(changeset, :book_authors) == [] do
      book_author = %AuthorBook{}
      changeset = Ecto.Changeset.put_change(changeset, :book_authors, [book_author])
      assign(socket, :form, to_form(changeset))
    else
      assign(socket, :form, to_form(changeset))
    end
  end

    defp assign_authors(socket) do
      authors =
        Library.list_authors()
        |> Enum.map(&{&1.name, &1.id})

      assign(socket, :authors, authors)
    end
end
