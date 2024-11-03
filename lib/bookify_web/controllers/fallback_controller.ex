defmodule BookifyWeb.FallbackController do
  use BookifyWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BookifyWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, {:not_found, message}}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: BookifyWeb.ErrorHTML, json: BookifyWeb.ErrorJSON)
    |> render(:"404", %{message: message})
  end

  def call(conn, {:error, {:forbidden, message}}) do
    message = message || "Forbidden access"

    conn
    |> put_status(:forbidden)
    |> put_view(html: BookifyWeb.ErrorHTML, json: BookifyWeb.ErrorJSON)
    |> render(:"403", %{message: message})
  end
end
