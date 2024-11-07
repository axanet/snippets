defmodule GalleryApi.Image do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(@extension_whitelist, file_extension) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end

  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  def filename(version, _) do
    version
  end

  def storage_dir(_, {_, title}) do
    blabla = GalleryApiWeb.Helpers.kebabify(title)
    "priv/static/uploads/#{blabla}"
  end
end
