defmodule ComponentsExamples.LibraryTest do
  use ComponentsExamples.DataCase

  alias ComponentsExamples.Library

  describe "authors" do
    alias ComponentsExamples.Library.Author

    import ComponentsExamples.LibraryFixtures

    @invalid_attrs %{bio: nil, birth_date: nil, gender: nil, name: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Library.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Library.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{
        bio: "some bio",
        birth_date: "some birth_date",
        gender: 42,
        name: "some name"
      }

      assert {:ok, %Author{} = author} = Library.create_author(valid_attrs)
      assert author.bio == "some bio"
      assert author.birth_date == "some birth_date"
      assert author.gender == 42
      assert author.name == "some name"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()

      update_attrs = %{
        bio: "some updated bio",
        birth_date: "some updated birth_date",
        gender: 43,
        name: "some updated name"
      }

      assert {:ok, %Author{} = author} = Library.update_author(author, update_attrs)
      assert author.bio == "some updated bio"
      assert author.birth_date == "some updated birth_date"
      assert author.gender == 43
      assert author.name == "some updated name"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_author(author, @invalid_attrs)
      assert author == Library.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Library.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Library.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Library.change_author(author)
    end
  end
end
