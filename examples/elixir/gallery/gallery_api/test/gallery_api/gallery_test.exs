defmodule GalleryApi.GalleryTest do
  use GalleryApi.DataCase

  alias GalleryApi.Gallery

  describe "images" do
    alias GalleryApi.Gallery.Image

    import GalleryApi.GalleryFixtures

    @invalid_attrs %{description: nil, title: nil, image_path: nil}

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Gallery.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Gallery.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        image_path: "some image_path"
      }

      assert {:ok, %Image{} = image} = Gallery.create_image(valid_attrs)
      assert image.description == "some description"
      assert image.title == "some title"
      assert image.image_path == "some image_path"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        image_path: "some updated image_path"
      }

      assert {:ok, %Image{} = image} = Gallery.update_image(image, update_attrs)
      assert image.description == "some updated description"
      assert image.title == "some updated title"
      assert image.image_path == "some updated image_path"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Gallery.update_image(image, @invalid_attrs)
      assert image == Gallery.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Gallery.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Gallery.change_image(image)
    end
  end
end
