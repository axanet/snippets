defmodule GalleryApi.Repo do
  use Ecto.Repo,
    otp_app: :gallery_api,
    adapter: Ecto.Adapters.Postgres
end
