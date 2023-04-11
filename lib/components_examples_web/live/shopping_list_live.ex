defmodule ComponentsExamplesWeb.ShoppingListLive do
  use ComponentsExamplesWeb, :live_view

  @item %{"name" => "", "id" => nil, "position" => nil}

  def mount(_params, _session, socket) do
    list = [
      %{name: "Bread", id: 1, position: 1, status: :in_progress},
      %{name: "Butter", id: 2, position: 2, status: :in_progress},
      %{name: "Milk", id: 3, position: 3, status: :in_progress},
      %{name: "Bananas", id: 4, position: 4, status: :in_progress},
      %{name: "Eggs", id: 5, position: 5, status: :in_progress}
    ]

    {:ok, assign(socket, shopping_list: list, form: to_form(@item))}
  end

  def render(assigns) do
    ~H"""
    <div id="lists" class="grid sm:grid-cols-1 md:grid-cols-3 gap-2">
      <div class="bg-gray-100 py-4 rounded-lg">
        <.live_component
          id="shopping_list"
          module={ComponentsExamplesWeb.ListComponent}
          list={@shopping_list}
          form={@form}
          list_name="Shopping list"
        />
      </div>
    </div>
    """
  end
end
