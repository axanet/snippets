defmodule GalleryApi.Gallery.ImageService do
  alias GalleryApi.Gallery

  @spec create(%{
          required(:image) => Plug.Upload.t(),
          required(:title) => String.t(),
          optional(:description) => String.t()
        }) :: {:ok, map()} | {:error, term()}
  def create(%{
        "image" => %Plug.Upload{} = upload,
        "title" => title,
        "description" => description
      }) do
    with {:ok, file_path} <- GalleryApi.Image.store({upload, title}) do
      image_params = %{
        title: title,
        description: description,
        image_path: file_path
      }

      Gallery.create_image(image_params)
    end
  end
end
