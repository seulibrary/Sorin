defmodule ApiWeb.UserChannel do
  use ApiWeb, :channel

  require Logger

  alias Core.Accounts

  def join("users:" <> user_id, _params, socket) do
    current_user = socket.assigns.user_id

    case Phoenix.Token.verify(socket, "user_id", user_id, max_age: 86400) do
      {:ok, id} ->
        if current_user == id do
          send(self(), :after_join)
          {:ok, socket}
        else
          {:error, %{reason: "Invalid user"}}
        end

      {:error, _reason} ->
        {:error, %{reason: "Invalid user"}}
    end
  end

  def handle_in("joined", _params, socket) do
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    data = ApiWeb.UserView.render("user.json", Accounts.get_user!(socket.assigns.user_id))

    push(socket, "joined", %{
      data: data
    })

    {:noreply, socket}
  end

  def handle_in("logout", _params, socket) do
    push(socket, "logged_out", %{})

    {:stop,
    :normal,
    socket
    |> assign(:user_id, nil)
    |> assign(:user, nil)
    }
  end

  def handle_in("get_tokens", _params, socket) do
    push(
      socket,
      "token_list",
      ApiWeb.TokenView.render(
        "tokens.json",
        %{data: Core.AuthTokens.get_auth_tokens_by_user_id(
          socket.assigns.user_id, "api")}))

    {:noreply, socket}
  end

  def handle_in("delete_token", params, socket) do
    with token when is_map(token) <- Core.AuthTokens.get_auth_token(%{key: params["token"]}),
         {:ok, %Core.AuthTokens.AuthToken{}} <- Core.AuthTokens.delete_auth_token(token) do
      push(socket, "deleted_token", ApiWeb.TokenView.render("token.json", data: token))
    end

    {:noreply, socket}
  end

  def handle_in("create_token", params, socket) do
    token = Phoenix.Token.sign("ElNO1SCiwmTp7Oxd9gkkv77FQutRdSMOTJvF8UBvT7hW2HrxZorkiPiXYY0xSmFN", "user_id", socket.assigns.user_id)

    with {:ok, authtoken} <- Core.AuthTokens.create_auth_token(%{
                  token: %{key: token},
                  label: params["label"],
                  user_id: socket.assigns.user_id,
                  type: "api"}) do
      push(socket, "created_token", ApiWeb.TokenView.render("token.json", data: authtoken))
    end

    {:noreply, socket}
  end

  def terminate(reason, socket) do
    Logger.info"> leave - user_id: #{socket.assigns.user_id}, #{socket.topic}, #{inspect reason}"
    :ok
  end
end
