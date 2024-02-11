defmodule UnderstandingWeb.UserLive.Index do
  use UnderstandingWeb, :live_view

  alias Understanding.Accounts
  alias Understanding.Accounts.User

  def render(assigns) do
    ~H"""
    <.header>
      Listing Users
      <:actions>
        <.link patch={~p"/users/new"}>
          <.button>New User</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="users"
      rows={@streams.users}
      row_click={fn {_id, user} -> JS.navigate(~p"/users/#{user}") end}
    >
      <:col :let={{_id, user}} label="Name"><%= user.name %></:col>
      <:col :let={{_id, user}} label="Age"><%= user.age %></:col>
      <:action :let={{_id, user}}>
        <div class="sr-only">
          <.link navigate={~p"/users/#{user}"}>Show</.link>
        </div>
        <.link patch={~p"/users/#{user}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, user}}>
        <.link
          phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="user-modal" show on_cancel={JS.patch(~p"/users")}>
      <.live_component
        module={UnderstandingWeb.UserLive.FormComponent}
        id={@user.id || :new}
        title={@page_title}
        action={@live_action}
        user={@user}
        patch={~p"/users"}
      />
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, Accounts.list_users())}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  def handle_info({UnderstandingWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end
end
