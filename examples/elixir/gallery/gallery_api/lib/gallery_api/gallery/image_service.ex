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
    upload_path = Path.join([:code.priv_dir(:gallery_api), "static", "uploads", upload.filename])
    File.cp!(upload.path, upload_path)

    image_params = %{
      title: title,
      description: description,
      image_path: upload_path
    }

    Gallery.create_image(image_params)
  end
end
