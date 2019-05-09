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

  def handle_in("joined", _payload, socket) do
    # broadcast(socket, "joined", %{data: data})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    data = ApiWeb.UserView.render("user.json", Accounts.get_user!(socket.assigns.user_id))
    
    push(socket, "joined", %{
      data: data
    })
    
    {:noreply, socket}
  end

  def handle_in("logout", _payload, socket) do
    push(socket, "logged_out", %{})
    
    {:stop,
    :normal, 
    socket 
    |> assign(:user_id, nil)
    |> assign(:user, nil)
    }
  end

  def terminate(reason, socket) do
    Logger.info"> leave - user_id: #{socket.assigns.user_id}, #{socket.topic}, #{inspect reason}"
    :ok
  end
end
