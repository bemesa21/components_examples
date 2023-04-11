defmodule ComponentsExamplesWeb.ListComponent do
  use ComponentsExamplesWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 space-y-4">
      <.header>
        <%= @list_name %>
        <.simple_form
          for={@form}
          phx-change="validate"
          phx-submit="save"
          phx-target={@myself}
          class="min-w-0 flex-auto drag-ghost:opacity-0"
          inputs_container_class="flex"
        >
          <.input field={@form[:name]} type="text" />
          <:actions>
            <.button class="align-middle ml-2">
              <.icon name="hero-plus" />
            </.button>
          </:actions>
        </.simple_form>
      </.header>
      <div id={"#{@id}-items"} class="grid grid-cols-1 gap-2" phx-hook="Sortable" data-list_id={@id}>
        <div
          :for={item <- @list}
          id={"#{@id}-#{item.id}"}
          data-id={item.id}
          class="
          relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-2 shadow-sm
          focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400
          drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0
          drag-ghost:bg-zinc-300 drag-ghost:border-0 drag-ghost:ring-0
          "
        >
          <div class="flex-1">
            <div class="flex drag-ghost:opacity-0">
              <button type="button" class="w-10">
                <.icon
                  name="hero-check-circle"
                  class={[
                    "w-7 h-7",
                    if(item.status == :completed, do: "bg-green-600", else: "bg-gray-300")
                  ]}
                />
              </button>
              <div class="flex-auto block text-sm leading-6 text-zinc-900">
                <%= item.name %>
              </div>
              <button type="button" class="w-10 -mt-1 flex-none">
                <.icon name="hero-x-mark" />
              </button>
            </div>
          </div>
        </div>
      </div>
      <.button class="w-full mt-4">reset</.button>
    </div>
    """
  end

  def handle_event("reposition", %{"id" => id, "new" => new_idx, "old" => _} = params, socket) do
    {:noreply, socket}
  end

  def handle_event("new", %{"at" => _at}, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
