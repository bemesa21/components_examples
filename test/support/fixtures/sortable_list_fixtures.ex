defmodule ComponentsExamples.SortableListFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ComponentsExamples.SortableList` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}) do
    {:ok, list} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> ComponentsExamples.SortableList.create_list()

    list
  end

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        list_id: 42,
        name: "some name",
        position: 42
      })
      |> ComponentsExamples.SortableList.create_item()

    item
  end
end
