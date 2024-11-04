defmodule GalleryApiWeb.ImageJSON do
  alias GalleryApi.Gallery.Image

  @doc """
  Renders a list of images.
  """
  def index(%{images: images}) do
    %{data: for(image <- images, do: data(image))}
  end

  @doc """
  Renders a single image.
  """
  def show(%{image: image}) do
    %{data: data(image)}
  end

  defp data(%Image{} = image) do
    %{
      id: image.id,
      title: image.title,
      description: image.description,
      image_path: image.image_path
    }
  end
end
