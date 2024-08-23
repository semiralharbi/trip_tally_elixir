defmodule TripTallyWeb.ErrorJSON do
  # Handle changeset errors
  def render("changeset.json", %{changeset: changeset}) do
    %{
      errors: format_changeset_errors(changeset)
    }
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

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    |> Enum.map(fn {field, messages} ->
      Enum.map(messages, fn message ->
        %{
          field: field,
          message: humanize_error_message(field, message)
        }
      end)
    end)
    |> List.flatten()
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

  defp humanize_error_message(field, "can't be blank"),
    do: "The #{humanize_field(field)} cannot be blank."

  defp humanize_error_message(field, "is invalid"), do: "The #{humanize_field(field)} is invalid."

  defp humanize_error_message(field, "is too short"),
    do: "The #{humanize_field(field)} is too short."

  defp humanize_error_message(field, "is too long"),
    do: "The #{humanize_field(field)} is too long."

  defp humanize_error_message(_field, message), do: message

  defp humanize_field(field) when is_atom(field),
    do: Atom.to_string(field) |> String.replace("_", " ") |> String.capitalize()

  defp humanize_field(field), do: field
end
