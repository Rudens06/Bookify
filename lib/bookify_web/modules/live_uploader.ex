defmodule BookifyWeb.Modules.LiveUploader do
  alias Phoenix.LiveView
  @uploads_dir Path.join(:code.priv_dir(:bookify), "static/uploads")

  def ensure_uploads_dir do
    File.mkdir_p!(@uploads_dir)
  end

  def handle_upload(socket, upload_name) do
    ensure_uploads_dir()

    LiveView.consume_uploaded_entries(socket, upload_name, fn %{path: temp_path}, entry ->
      unique_filename = "#{entry.uuid}-#{entry.client_name}"
      target_path = Path.join(@uploads_dir, unique_filename)

      File.cp!(temp_path, target_path)

      {:ok, unique_filename}
    end)
  end

  def uploads_dir, do: @uploads_dir
end
