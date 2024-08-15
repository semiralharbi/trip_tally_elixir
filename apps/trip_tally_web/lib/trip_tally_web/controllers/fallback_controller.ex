defmodule TripTallyWeb.FallbackController do
  alias TripTallyWeb.ErrorJSON
  use Phoenix.Controller

  def call(conn, {:ok, :accepted}) do
    conn
    |> put_status(:accepted)
    |> json(%{status: "success"})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorJSON)
    |> render("changeset.json", changeset: changeset)
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(422)
    |> put_view(ErrorJSON)
    |> render("error_message.json", message: message)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(401)
    |> put_view(ErrorJSON)
    |> render("401.json", %{})
  end

  def call(conn, {:error, :unprocessable_entity}) do
    conn
    |> put_status(422)
    |> put_view(ErrorJSON)
    |> render("422.json", %{})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(403)
    |> put_view(ErrorJSON)
    |> render("403.json", %{})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(ErrorJSON)
    |> render("404.json", %{})
  end

  def call(conn, {:error, :invalid_email_or_pass}) do
    conn
    |> put_status(401)
    |> put_view(ErrorJSON)
    |> render("error_message.json", message: "Invalid email or password")
  end
end
