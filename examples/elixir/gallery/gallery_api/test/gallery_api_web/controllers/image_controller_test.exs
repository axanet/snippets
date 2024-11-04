defmodule GalleryApiWeb.ImageControllerTest do
  use GalleryApiWeb.ConnCase

  import GalleryApi.GalleryFixtures

  alias GalleryApi.Gallery.Image

  @create_attrs %{
    description: "some description",
    title: "some title",
    image_path: "some image_path"
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    image_path: "some updated image_path"
  }
  @invalid_attrs %{description: nil, title: nil, image_path: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all images", %{conn: conn} do
      conn = get(conn, ~p"/api/images")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create image" do
    test "renders image when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/images", image: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/images/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "image_path" => "some image_path",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/images", image: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update image" do
    setup [:create_image]

    test "renders image when data is valid", %{conn: conn, image: %Image{id: id} = image} do
      conn = put(conn, ~p"/api/images/#{image}", image: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/images/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "image_path" => "some updated image_path",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, image: image} do
      conn = put(conn, ~p"/api/images/#{image}", image: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete image" do
    setup [:create_image]

    test "deletes chosen image", %{conn: conn, image: image} do
      conn = delete(conn, ~p"/api/images/#{image}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/images/#{image}")
      end
    end
  end

  defp create_image(_) do
    image = image_fixture()
    %{image: image}
  end
end
