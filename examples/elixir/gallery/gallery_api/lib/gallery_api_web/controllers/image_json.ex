defmodule GalleryApiWeb.ImageJSON do
  alias GalleryApi.Gallery.Image

  @doc """
  Renders a list of images.
  """
  def index(%{images: images, conn: conn}) do
    %{data: for(image <- images, do: data(image, conn))}
  end

  @doc """
  Renders a single image.
  """
  def show(%{image: image, conn: conn}) do
    %{data: data(image, conn)}
  end

  defp data(%Image{} = image, conn) do
    %{
      id: image.id,
      title: image.title,
      description: image.description,
      image_name: image.image_path.file_name,
      image_url: GalleryApiWeb.Helpers.build_file_url(conn, image.image_path.file_name)
    }
  end
end
