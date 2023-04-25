defmodule ComponentsExamples.SortableListTest do
  use ComponentsExamples.DataCase

  alias ComponentsExamples.SortableList

  describe "lists" do
    alias ComponentsExamples.SortableList.List

    import ComponentsExamples.SortableListFixtures

    @invalid_attrs %{title: nil}

    test "list_lists/0 returns all lists" do
      list = list_fixture()
      assert SortableList.list_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert SortableList.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %List{} = list} = SortableList.create_list(valid_attrs)
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SortableList.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %List{} = list} = SortableList.update_list(list, update_attrs)
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = SortableList.update_list(list, @invalid_attrs)
      assert list == SortableList.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = SortableList.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> SortableList.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = SortableList.change_list(list)
    end
  end

  describe "items" do
    alias ComponentsExamples.SortableList.Item

    import ComponentsExamples.SortableListFixtures

    @invalid_attrs %{list_id: nil, name: nil, position: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert SortableList.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert SortableList.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{list_id: 42, name: "some name", position: 42}

      assert {:ok, %Item{} = item} = SortableList.create_item(valid_attrs)
      assert item.list_id == 42
      assert item.name == "some name"
      assert item.position == 42
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SortableList.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{list_id: 43, name: "some updated name", position: 43}

      assert {:ok, %Item{} = item} = SortableList.update_item(item, update_attrs)
      assert item.list_id == 43
      assert item.name == "some updated name"
      assert item.position == 43
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = SortableList.update_item(item, @invalid_attrs)
      assert item == SortableList.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = SortableList.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> SortableList.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = SortableList.change_item(item)
    end
  end
end
