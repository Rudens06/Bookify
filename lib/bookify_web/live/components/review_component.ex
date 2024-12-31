defmodule BookifyWeb.ReviewComponent do
  use BookifyWeb, :live_component
  import Bookify.Utils.User

  alias Bookify.Reviews
  alias Bookify.Reviews.Review

  def render(assigns) do
    ~H"""
    <div class="review-component">
      <.header>
        Add Review
      </.header>
      <.simple_form for={@form} phx-submit="save_review" phx-target={@myself}>
        <.input field={@form[:title]} type="text" label="Title" placeholder="Title" />
        <.input field={@form[:body]} type="textarea" label="Body" placeholder="Content..." />
        <.input
          field={@form[:rating]}
          type="number"
          min="1"
          max="5"
          step="0.5"
          label="Rating (1-5)"
          placeholder="Rating"
        />
        <.button phx-disable-with="Saving..." class="my-4">
          Save Review
        </.button>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    review_changeset = Reviews.change_review(%Review{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: to_form(review_changeset))}
  end

  def handle_event("save_review", %{"review" => review_params}, socket) do
    book = socket.assigns.book
    user = current_user(socket)
    if user do
      case Reviews.create_review(book, user, review_params) do
        {:ok, review} ->
          notify_parent({:review_saved, review})

        {:noreply, socket}

        {:error, changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      {:noreply,
      socket
      |> put_flash(:error, "You must be logged in to leave a review")
      |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), msg)
end
