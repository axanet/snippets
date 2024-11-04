defmodule GalleryApiWeb.ImageController do
  use GalleryApiWeb, :controller

  alias GalleryApi.Gallery
  alias GalleryApi.Gallery.Image

  action_fallback GalleryApiWeb.FallbackController

  def index(conn, _params) do
    images = Gallery.list_images()
    render(conn, :index, images: images)
  end

  def create(conn, %{"image" => image_params}) do
    with {:ok, %Image{} = image} <- Gallery.create_image(image_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/images/#{image}")
      |> render(:show, image: image)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Gallery.get_image!(id)
    render(conn, :show, image: image)
  end

  def update(conn, %{"id" => id, "image" => image_params}) do
    image = Gallery.get_image!(id)

    with {:ok, %Image{} = image} <- Gallery.update_image(image, image_params) do
      render(conn, :show, image: image)
    end
  end

  def delete(conn, %{"id" => id}) do
    image = Gallery.get_image!(id)

    with {:ok, %Image{}} <- Gallery.delete_image(image) do
      send_resp(conn, :no_content, "")
    end
  end
end
