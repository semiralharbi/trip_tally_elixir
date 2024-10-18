defmodule TripTally.MediaTest do
  use TripTally.DataCase, async: true

  alias TripTally.Attachments.Attachment
  alias TripTally.Media

  @upload_directory "uploads"
  @fixture_path Path.expand("../support/assets", __DIR__)

  setup do
    File.mkdir_p!(@upload_directory)

    {:ok, user: insert(:user)}
  end

  test "upload_file_to_storage/1 uploads the file and returns the correct path", %{user: _user} do
    file_path = Path.join(@fixture_path, "test.jpg")

    upload = %Plug.Upload{
      filename: "test.jpg",
      path: file_path,
      content_type: "image/jpeg"
    }

    assert {:ok, destination_path} = Media.upload_file_to_storage(upload)

    assert File.exists?(destination_path)
    assert String.starts_with?(destination_path, @upload_directory)

    File.rm(destination_path)
  end

  test "upload_image/2 uploads an image, calculates aspect ratio, and creates an attachment", %{
    user: user
  } do
    file_path = Path.join(@fixture_path, "test.jpg")

    upload = %Plug.Upload{
      filename: "test.jpg",
      path: file_path,
      content_type: "image/jpeg"
    }

    assert {:ok, %Attachment{} = attachment} = Media.upload_image(user, upload)

    assert attachment.user_id == user.id
    assert attachment.filename == "test.jpg"
    assert attachment.type == :image
    assert attachment.aspect_ratio == 1.4144432586268232

    assert File.exists?(attachment.url)

    File.rm(attachment.url)
  end

  test "upload_image/2 returns error if the file upload fails", %{user: user} do
    upload = %Plug.Upload{
      filename: "non_existent.jpg",
      path: "non_existent_path",
      content_type: "image/jpeg"
    }

    host = System.get_env("PHX_HOST") || "localhost"
    port = Application.get_env(:trip_tally_web, TripTallyWeb.Endpoint)
    dir = Application.app_dir(:trip_tally_web)

    assert {:error, _reason} = Media.upload_image(user, upload)
  end
end
