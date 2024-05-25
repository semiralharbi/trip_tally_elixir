defmodule TripTallyWeb.ErrorJSON do
  # Handle changeset errors
  def render("changeset.json", %{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, val}, acc ->
          String.replace(acc, "%{#{key}}", to_string(val))
        end)
      end)

    %{errors: errors}
  end

  # Handle simple error messages
  def render("error_message.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
