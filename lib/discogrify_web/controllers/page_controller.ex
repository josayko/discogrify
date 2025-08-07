defmodule DiscogrifyWeb.PageController do
  use DiscogrifyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
