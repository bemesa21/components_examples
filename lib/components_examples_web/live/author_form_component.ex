defmodule ComponentsExamplesWeb.AuthorFormComponent do
  use ComponentsExamplesWeb, :live_component

  alias ComponentsExamples.Library.Author
  alias ComponentsExamples.Library

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-change="validate" phx-submit="save" phx-target={@myself} class="">
        <h1 class="text-md font-semibold leading-8 text-zinc-800">
          New Author
        </h1>
        <div class="flex space-x-2 drag-item">
          <.input type="text" field={@form[:name]} placeholder="Name" />
          <.input
            type="select"
            field={@form[:gender]}
            placeholder="Gender"
            options={[:female, :male]}
          />
          <.input type="datetime-local" field={@form[:birth_date]} placeholder="Birth Date" />
        </div>
        <.input type="textarea" field={@form[:bio]} placeholder="Biography" />
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

  def update(%{author: author} = _assigns, socket) do
    author_changeset = Library.change_author(author)

    socket =
      socket
      |> assign(:new_author, false)
      |> assign(:form, to_form(author_changeset))

    {:ok, socket}
  end

  def handle_event("save", %{"author" => author_params} = _param, socket) do
    case Library.create_author(author_params) do
      {:ok, _author} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/library/")
         |> put_flash(:info, "Book created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :insert)

        {:noreply, assign(socket, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"author" => author_params} = _params, socket) do
    # use assigns author..
    author_form =
      %Author{}
      |> Library.change_author(author_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, author_form)}
  end
end
