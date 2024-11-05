defmodule GalleryApi.Uploaders.ImageUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png .gif)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(@extension_whitelist, file_extension) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end
end
