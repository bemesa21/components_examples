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
        module={ComponentsExamplesWeb.ListComponent}
        id={list.id}
        list={list}
        group="grocery_list"
      />
    </div>
    """
  end

  def handle_info({:item_added, _item, _list_id}, socket) do
    {:noreply, assign(socket, lists: SortableList.list_lists())}
  end

  def handle_info({:item_deleted, _item, _list_id}, socket) do
    {:noreply, assign(socket, lists: SortableList.list_lists())}
  end
end
