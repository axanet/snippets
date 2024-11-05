defmodule GalleryApiWeb.Helpers do
  @spec build_file_url(Plug.Conn.t(), String.t()) :: String.t()
  def build_file_url(conn, image_path) do
    URI.merge(Phoenix.Controller.endpoint_url(conn), "/uploads/#{image_path}")
  end
end
