defmodule TripTally.Media do
  @moduledoc """
  This module holds the logic for the media files like images, pdfs, videos
  """

  alias Ecto.Multi
  alias Ecto.UUID
  alias TripTally.Accounts.User
  alias TripTally.Attachments.Attachment
  alias TripTally.Repo

  @upload_directory "uploads"

  @doc """
  Uploads a file to local storage and returns the file's URL.
  """
  def upload_file_to_storage(%{filename: filename, path: temp_path}) do
    File.mkdir_p!(@upload_directory)

    unique_filename = "#{UUID.autogenerate()}_#{filename}"

    destination_path = Path.join(@upload_directory, unique_filename)

    case File.cp(temp_path, destination_path) do
      :ok -> {:ok, destination_path}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Uploads an image and associate with user.
  """
  def upload_image(
        %User{} = user,
        %{filename: filename, content_type: content_type, path: path} = file
      ) do
    with {:ok, url} <- upload_file_to_storage(file),
         {:ok, aspect_ratio} <- calculate_aspect_ratio(path) do
      user = user |> Repo.preload(:profile_picture)

      Multi.new()
      |> Multi.run(:delete_old_picture, fn _repo, _changes ->
        delete_old_profile_picture(user)
      end)
      |> Multi.insert(:insert_attachment, %Attachment{
        url: url,
        type: :image,
        filename: filename,
        content_type: content_type,
        aspect_ratio: aspect_ratio,
        user_id: user.id
      })
      |> Repo.transaction()
      |> case do
        {:ok, %{insert_attachment: attachment}} -> {:ok, attachment}
        {:error, %{insert_attachment: changeset}} -> {:error, changeset}
      end
    end
  end

  defp calculate_aspect_ratio(image_path) do
    image = Mogrify.open(image_path) |> Mogrify.verbose()

    case {image.width, image.height} do
      {width, height} when is_integer(width) and is_integer(height) ->
        aspect_ratio = width / height
        {:ok, aspect_ratio}

      _ ->
        {:ok, 1.0}
    end
  end

  defp delete_old_profile_picture(%User{profile_picture: %Attachment{id: id, url: url}}) do
    attachment = Repo.get(Attachment, id)

    case attachment do
      nil ->
        {:ok, nil}

      _ ->
        with {:ok, _} <- delete_attachment(attachment),
             :ok <- delete_file_from_storage(url) do
          {:ok, :deleted}
        else
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp delete_old_profile_picture(_user), do: {:ok, nil}

  defp delete_attachment(attachment) do
    case Repo.delete(attachment) do
      {:ok, _} -> {:ok, :deleted}
      {:error, reason} -> {:error, reason}
    end
  end

  defp delete_file_from_storage(url) do
    case File.rm(Path.join(@upload_directory, Path.basename(url))) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
