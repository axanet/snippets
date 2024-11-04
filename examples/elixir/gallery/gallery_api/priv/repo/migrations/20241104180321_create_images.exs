defmodule GalleryApi.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :description, :text
      add :image_path, :string

      timestamps(type: :utc_datetime)
    end
  end
end
