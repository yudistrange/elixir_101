defmodule Elixir101Web.PageController do
  use Elixir101Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
