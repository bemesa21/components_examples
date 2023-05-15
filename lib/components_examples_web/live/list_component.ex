defmodule ComponentsExamplesWeb.ListComponent do
  use ComponentsExamplesWeb, :live_component

  alias ComponentsExamples.SortableList
  alias ComponentsExamples.SortableList.Item

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div class="space-y-5 mx-auto max-w-7xl px-4 space-y-4">
        <.header>
          <%= @list_name %>
        </.header>
        <div>
          <div
            id={"#{@id}-items"}
            class="grid grid-cols-1 gap-2"
            phx-hook="Sortable"
            data-list_id={@id}
            data-group={@group}
            phx-update="stream"
          >
            <div
              :for={{id, form} <- @streams.items}
              id={id}
              data-id={form.data.id}
              class="
          relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-2 shadow-sm
          focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400
          drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0
          drag-ghost:bg-zinc-300 drag-ghost:border-0 drag-ghost:ring-0
          "
            >
              <.simple_form
                for={form}
                phx-change="validate"
                phx-submit="save"
                phx-target={@myself}
                class="min-w-0 flex-1 drag-ghost:opacity-0"
                phx-value-id={form.data.id}
              >
                <div class="flex">
                  <button type="button" class="w-10">
                    <.icon
                      name="hero-check-circle"
                      class={[
                        "w-7 h-7",
                        if(form[:status].value == :completed, do: "bg-green-600", else: "bg-gray-300")
                      ]}
                    />
                  </button>
                  <div class="flex-auto block text-sm leading-6 text-zinc-900">
                    <input type="hidden" name={form[:list_id].name} value={form[:list_id].value} />
                    <.input
                      field={form[:name]}
                      type="text"
                      border={false}
                      strike_through={form[:status].value == :completed}
                      phx-target={@myself}
                      phx-keydown={
                        !form.data.id && JS.push("discard", target: @myself, value: %{list_id: @id})
                      }
                      phx-key="escape"
                      phx-blur={form.data.id && JS.dispatch("submit", to: "##{form.id}")}
                    />
                  </div>
                  <button
                    type="button"
                    class="w-10 -mt-1 flex-none"
                    phx-click={
                      JS.push("delete", target: @myself, value: %{id: form.data.id})
                      |> hide("#list#{@id}-item#{form.data.id}")
                    }
                  >
                    <.icon name="hero-x-mark" />
                  </button>
                </div>
              </.simple_form>
            </div>
          </div>
        </div>
        <.button phx-click={JS.push("new", target: @myself, value: %{list_id: @id})} class="mt-4">
          Add item
        </.button>
        <.button phx-click={JS.push("reset", target: @myself, value: %{list_id: @id})} class="mt-4">
          Reset
        </.button>
      </div>
    </div>
    """
  end

  def update(%{list: list} = assigns, socket) do
    item_forms = Enum.map(list, &build_item_form(&1, %{list_id: assigns.id}))

    socket =
      socket
      |> assign(assigns)
      # |> stream(:items, item_forms, reset: true)
      # pa que es el reset true????
      |> stream(:items, item_forms)

    {:ok, socket}
  end

  def handle_event("reposition", %{"id" => _id, "new" => _new_idx, "old" => _} = _params, socket) do
    {:noreply, socket}
  end

  def handle_event("new", %{"list_id" => list_id}, socket) do
    {:noreply, stream_insert(socket, :items, build_item_form(list_id), at: -1)}
  end

  def handle_event("save", %{"id" => id, "item" => params}, socket) do
    todo = SortableList.get_item!(id)

    case SortableList.update_item(todo, params) do
      {:ok, updated_item} ->
        {:noreply, stream_insert(socket, :items, build_item_form(updated_item, %{}))}

      {:error, changeset} ->
        {:noreply, stream_insert(socket, :items, build_item_form(changeset, %{}, :insert))}
    end
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    case SortableList.create_item(item_params) do
      {:ok, new_item} ->
        empty_form = build_item_form(item_params["list_id"])

        {:noreply,
         socket
         |> stream_insert(:items, build_item_form(new_item, %{}))
         |> stream_delete(:items, empty_form)
         |> stream_insert(:items, empty_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"item" => item_params} = params, socket) do
    # asegurarse de tener los datos en data
    item = %Item{id: params["id"] || nil, list_id: item_params["list_id"]}
    {:noreply, stream_insert(socket, :items, build_item_form(item, item_params, :validate))}
  end

  def handle_event("delete", %{"id" => item_id}, socket) do
    item = SortableList.get_item!(item_id)
    {:ok, _} = SortableList.delete_item(item)
    {:noreply, stream_delete(socket, :items, build_item_form(item, %{}))}
  end

  def handle_event("reset", params, socket) do
    empty_item_form = build_item_form(params["list_id"])
    {:noreply, stream(socket, :items, [empty_item_form], reset: true)}
  end

  def handle_event("discard", params, socket) do
    empty_item_form = build_item_form(params["list_id"])
    {:noreply, stream_delete(socket, :items, empty_item_form)}
  end

  defp build_item_form(list_id) do
    %Item{list_id: list_id}
    |> SortableList.change_item(%{})
    # id consistente entre forms nuevos
    |> to_form(id: "form-#{list_id}-")
  end

  defp build_item_form(item_or_changeset, params, action \\ nil) do
    changeset =
      item_or_changeset
      |> SortableList.change_item(params)
      # show errors or not
      |> Map.put(:action, action)

    to_form(changeset, as: "item", id: "form-#{changeset.data.list_id}-#{changeset.data.id}")
  end
end
