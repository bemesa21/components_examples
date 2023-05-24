defmodule ComponentsExamplesWeb.ShoppingListLive do
  use ComponentsExamplesWeb, :live_view

  def mount(_params, _session, socket) do
    list = [
      %{name: "Bread", id: 1, position: 1, status: :in_progress},
      %{name: "Butter", id: 2, position: 2, status: :in_progress},
      %{name: "Milk", id: 3, position: 3, status: :in_progress},
      %{name: "Bananas", id: 4, position: 4, status: :in_progress},
      %{name: "Eggs", id: 5, position: 5, status: :in_progress}
    ]

    {:ok, assign(socket, shopping_list: list)}
  end

  def render(assigns) do
    ~H"""
    <div id="lists" class="grid sm:grid-cols-1 md:grid-cols-3 gap-2">
      <.live_component
        id="1"
        module={ComponentsExamplesWeb.ListComponent}
        list={@shopping_list}
        list_name="Shopping list 1"
        group="grocery_list"
      />
      <.live_component
        id="2"
        module={ComponentsExamplesWeb.ListComponent}
        list={@shopping_list}
        list_name="Shopping list 2"
        group="grocery_list"
      />
      <.live_component
        id="3"
        module={ComponentsExamplesWeb.ListComponent}
        list={@shopping_list}
        list_name="Shopping list 3"
        group="grocery_list"
      />
    </div>
    """
  end
end
