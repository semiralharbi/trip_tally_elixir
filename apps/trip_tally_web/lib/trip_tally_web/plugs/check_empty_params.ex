defmodule TripTallyWeb.Plugs.CheckEmptyParams do
  import Plug.Conn
  import Phoenix.Controller

  @actions_to_check [:create, :update]

  def init(default), do: default

  def call(%Plug.Conn{params: %{} = params, private: %{phoenix_action: action}} = conn, _opts)
      when map_size(params) == 0 and action in @actions_to_check do
    conn
    |> put_status(:bad_request)
    |> put_view(TripTallyWeb.ErrorJSON)
    |> render("400.json", %{})
    |> halt()
  end

  def call(conn, _opts), do: conn
end
