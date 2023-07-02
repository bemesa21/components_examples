defmodule ComponentsExamples.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ComponentsExamples.Library` context.
  """

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        bio: "some bio",
        birth_date: "some birth_date",
        gender: 42,
        name: "some name"
      })
      |> ComponentsExamples.Library.create_author()

    author
  end
end
