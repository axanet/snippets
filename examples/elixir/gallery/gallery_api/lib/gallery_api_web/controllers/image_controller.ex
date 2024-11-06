defmodule GalleryApiWeb.ImageController do
  use GalleryApiWeb, :controller

  alias GalleryApi.Gallery
  alias GalleryApi.Gallery.Image

  action_fallback GalleryApiWeb.FallbackController

  def index(conn, _params) do
    images = Gallery.list_images()
    render(conn, :index, images: images)
  end

  def create(conn, %{
        "image" => %Plug.Upload{} = upload,
        "title" => title,
        "description" => description
      }) do
    upload_path = Path.join([:code.priv_dir(:gallery_api), "static", "uploads", upload.filename])
    File.cp!(upload.path, upload_path)

    image_params = %{
      title: title,
      description: description,
      image_path: upload_path
    }

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
