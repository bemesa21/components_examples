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
          >
            <div
              :for={form <- @list}
              id={"list#{@id}-item#{form.data.id}"}
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
                phx-value-id={form.data.id}
                phx-target={@myself}
                class="min-w-0 flex-1 drag-ghost:opacity-0"
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
                    <.input field={form[:name]} type="text" border={false} />
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
        <.button class="w-full mt-4">reset</.button>
      </div>
    </div>
    """
  end

  def update(%{list: list} = assigns, socket) do
    item_forms = Enum.map(list, &to_change_form(&1, %{list_id: assigns.id}))

    socket =
      socket
      |> assign(assigns)
      |> assign(:list, item_forms)

    {:ok, socket}
  end

  def handle_event("reposition", %{"id" => _id, "new" => _new_idx, "old" => _} = _params, socket) do
    {:noreply, socket}
  end

  def handle_event("new", %{"at" => _at}, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    case SortableList.create_item(item_params) do
      {:ok, new_item} ->
        send(self(), {:item_added, new_item, socket.assigns.id})

        {:noreply,
         socket
         |> assign(:form, build_item_form(socket.assigns.id))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => item_id}, socket) do
    item = SortableList.get_item!(item_id)
    {:ok, _} = SortableList.delete_item(item)
    {:noreply, socket}
  end

  defp build_item_form(list_id) do
    %Item{list_id: list_id}
    |> SortableList.change_item(%{})
    |> to_form()
  end

  defp to_change_form(todo_or_changeset, params, action \\ nil) do
    changeset =
      todo_or_changeset
      |> SortableList.change_item(params)
      |> Map.put(:action, action)

    to_form(changeset, as: "item", id: "form-#{changeset.data.list_id}-#{changeset.data.id}")
  end
end
