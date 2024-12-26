defmodule Bookify.Utils.Upload do
  def uploads_dir do
    if System.get_env("FLY_APP_NAME") do
      "/app/uploads"
    else
      Path.expand("./uploads")
    end
  end
end
