defmodule ApiWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", ApiWeb.RoomChannel
  channel "users:*", ApiWeb.UserChannel
  channel "collection:*", ApiWeb.CollectionChannel
  channel "dashboard:*", ApiWeb.DashboardChannel
  channel "search:*", ApiWeb.SearchChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(%{"token" => user_id_token} = _params, socket) do
    case Phoenix.Token.verify(socket, "user_id", user_id_token, max_age: 86400) do
      {:ok, id} ->
        {:ok,
         socket
         |> assign(:user_id, id)
         |> assign(:user, Core.Accounts.get_user!(id))}

      {:error, :expired} ->
        {:ok,
         socket
         |> assign(:user_id, nil)
         |> assign(:user, nil)}

      {:error, _} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ApiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # def id(_socket), do: nil
end
