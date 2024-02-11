defmodule UnderstandingWeb.UserLive.Show do
  use UnderstandingWeb, :live_view

  alias Understanding.Accounts

  def render(assigns) do
    ~H"""
    <.header>
    User <%= @user.id %>
    <:subtitle>This is a user record from your database.</:subtitle>
    <:actions>
    <.link patch={~p"/users/#{@user}/show/edit"} phx-click={JS.push_focus()}>
      <.button>Edit user</.button>
    </.link>
    </:actions>
    </.header>

    <.list>
    <:item title="Name"><%= @user.name %></:item>
    <:item title="Age"><%= @user.age %></:item>
    </.list>

    <.back navigate={~p"/users"}>Back to users</.back>

    <.modal :if={@live_action == :edit} id="user-modal" show on_cancel={JS.patch(~p"/users/#{@user}")}>
    <.live_component
    module={UnderstandingWeb.UserLive.FormComponent}
    id={@user.id}
    title={@page_title}
    action={@live_action}
    user={@user}
    patch={~p"/users/#{@user}"}
    />
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, Accounts.get_user!(id))}
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end
