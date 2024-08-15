defmodule TripTallyWeb.AuthController do
  use Phoenix.Controller

  defmacro __using__(_opts) do
    quote do
      use TripTallyWeb, :controller
      action_fallback TripTallyWeb.FallbackController

      def action(conn, opts) do
        user = conn.assigns.current_user
        apply(__MODULE__, action_name(conn), [conn, conn.params, user])
      end
    end
  end
end
