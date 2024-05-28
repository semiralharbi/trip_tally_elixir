defmodule TripTallyWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TripTallyWeb.ErrorJSON)
    |> render("changeset.json", changeset: changeset)
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(422)
    |> put_view(TripTallyWeb.ErrorJSON)
    |> render("error_message.json", message: message)
  end

  def call(conn, {:error, :unauthorized}) do
    conn |> send_resp(401, "Unauthorized")
  end

  def call(conn, {:error, :forbidden}) do
    conn |> send_resp(403, "Forbidden")
  end

  def call(conn, {:error, :not_found}) do
    conn |> send_resp(404, "Not found")
  end

  def call(conn, {:error, :invalid_email_or_pass}) do
    conn
    |> put_status(401)
    |> put_resp_content_type("application/json")
    |> json(%{error: "Invalid email or password"})
  end
end
