defmodule GalleryApi.Uploaders.ImageUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @extension_whitelist ~w(.jpg jpeg .png .gif)
end
