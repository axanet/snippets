defmodule GalleryApiWeb.Helpers do
  @spec build_file_url(Plug.Conn.t(), String.t()) :: String.t()
  def build_file_url(conn, image_name) do
    Phoenix.VerifiedRoutes.static_url(conn, "/uploads/#{image_name}")
  end
end
