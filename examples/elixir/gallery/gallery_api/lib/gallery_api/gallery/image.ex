defmodule GalleryApi.Gallery.Image do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "images" do
    field :description, :string
    field :title, :string
    field :image_path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:title, :description, :image_path])
    |> validate_required([:title, :description, :image_path])
  end
end
