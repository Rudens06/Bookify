defmodule BookifyWeb.Modules.LiveUploader do
  import Bookify.Utils.Upload
  alias Phoenix.LiveView

  def handle_upload(socket, upload_name) do
    LiveView.consume_uploaded_entries(socket, upload_name, fn %{path: temp_path}, entry ->
      unique_filename = "#{entry.uuid}-#{entry.client_name}"

      target_path =
        Path.join(uploads_dir(), unique_filename)

      File.cp!(temp_path, target_path)

      {:ok, unique_filename}
    end)
  end
end
