defmodule GoFishWeb.PageController do
  use GoFishWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
