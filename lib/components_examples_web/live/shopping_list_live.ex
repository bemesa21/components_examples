defmodule ComponentsExamplesWeb.ShoppingListLive do
  alias ComponentsExamples.SortableList
  use ComponentsExamplesWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, lists: SortableList.list_lists())}
  end

  def render(assigns) do
    ~H"""
    <div id="lists" class="grid sm:grid-cols-1 md:grid-cols-3 gap-2">
      <.live_component
        :for={list <- @lists}
        id={list.id}
        module={ComponentsExamplesWeb.ListComponent}
        list={list.items}
        list_name={list.title}
        group="grocery_list"
      />
    </div>
    """
  end
end
