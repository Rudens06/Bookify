defmodule Bookify.Utils.Image do
  alias Bookify.Books.Book
  alias Bookify.Authors.Author

  @uploads_dir Path.join(:code.priv_dir(:bookify), "static/uploads")
  @public_image_path "/uploads/"
  @not_found_image "/images/image-not-found.jpg"

  def image(%Author{} = author), do: resolve_image(author.image_filename)
  def image(%Book{} = book), do: resolve_image(book.cover_image_filename)

  defp resolve_image(nil), do: @not_found_image
  defp resolve_image(""), do: @not_found_image

  defp resolve_image(filename) do
    if File.exists?(file_path(filename)) do
      @public_image_path <> filename
    else
      @not_found_image
    end
  end

  defp file_path(filename) do
    Path.join(@uploads_dir, filename)
  end
end
