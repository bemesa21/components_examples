defmodule ComponentsExamples.SortableList do
  @moduledoc """
  The SortableList context.
  """

  import Ecto.Query, warn: false
  alias ComponentsExamples.Repo

  alias ComponentsExamples.SortableList.Item
  alias ComponentsExamples.SortableList.List

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists do
    List
    |> Repo.all()
    |> Repo.preload(
      items:
        from(i in Item,
          order_by: [asc: i.position]
        )
    )
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id), do: Repo.get!(List, id)

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(%{field: value})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(attrs \\ %{}) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a list.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %List{}}

  """
  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:position, fn repo, _changes ->
      position =
        repo.one(from i in Item, where: i.list_id == ^attrs["list_id"], select: count(i.id))

      {:ok, position}
    end)
    |> Ecto.Multi.insert(:item, fn %{position: position} ->
      Item.changeset(%Item{position: position}, attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{item: item}} ->
        {:ok, item}

      {:error, :item, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Ecto.Multi.new()
    |> multi_decrement_positions(:dec_rest_in_list, item, list_id: item.list_id)
    |> Ecto.Multi.delete(:item, item)
    |> Repo.transaction()
    |> case do
      {:ok, %{item: item}} ->
        {:ok, item}

      {:error, _failed_op, failed_val, _changes_so_far} ->
        {:error, failed_val}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  defp multi_decrement_positions(
         %Ecto.Multi{} = multi,
         name,
         %type{} = struct,
         where_query,
         opts \\ []
       ) do
    Ecto.Multi.update_all(
      multi,
      name,
      fn _ ->
        from(t in type,
          where: ^where_query,
          where:
            t.position >
              subquery(from og in type, where: og.id == ^struct.id, select: og.position),
          update: [inc: [position: -1]]
        )
      end,
      opts
    )
  end
end
