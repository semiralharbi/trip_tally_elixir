defmodule TripTallyWeb.ErrorJSON do
  # Handle changeset errors
  def render("changeset.json", %{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  # Handle simple error messages
  def render("error_message.json", %{message: message}) do
    %{errors: message}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{errors: Phoenix.Controller.status_message_from_template(template)}
  end

  defp translate_error({msg, opts}) do
    # You can make use of gettext to translate error messages by
    # uncommenting and adjusting the following code:

    # if count = opts[:count] do
    #   Gettext.dngettext(TripTallyWeb.Gettext, "errors", msg, msg, count, opts)
    # else
    #   Gettext.dgettext(TripTallyWeb.Gettext, "errors", msg, opts)
    # end

    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
