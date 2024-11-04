defmodule GalleryApi.GalleryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GalleryApi.Gallery` context.
  """

  @doc """
  Generate a image.
  """
  def image_fixture(attrs \\ %{}) do
    {:ok, image} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image_path: "some image_path",
        title: "some title"
      })
      |> GalleryApi.Gallery.create_image()

    image
  end
end
