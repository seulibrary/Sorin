defmodule ApiWeb.DashboardChannel do
  use ApiWeb, :channel

  require Logger
  
  import ApiWeb.Utils

  def join("dashboard:" <> _collection_id, _params, socket) do
    if socket.assigns.user_id do
      dashboard = Core.Accounts.get_dashboard(socket.assigns.user_id)

      {:ok, ApiWeb.CollectionView.render("index.json", %{data: dashboard}), socket}
    else
      {:error, %{msg: "unauthorized"}}
    end
  end

  def handle_in("get_collection", payload, socket) do
    # used to keep real time renders in sync if user has multiple browsers open
    broadcast!(socket, "get_collection", payload)
    {:noreply, socket}
  end

  def handle_in("move_collection", payload, socket) do
    if !is_inbox(socket.assigns.user_id, payload["collection_id"]) && payload["newIndex"] != 0 do
      case can_move_collection(socket.assigns.user_id, payload["collection_id"]) do
        {:ok, _} ->
          Core.Dashboard.Collections.move_collection(
            payload["collection_id"],
            socket.assigns.user_id,
            payload["newIndex"]
          )
          broadcast!(socket, "move_collection", payload)
          {:reply, {:ok, %{msg: "Collection moved."}}, socket}
        {:error, _} -> 
          {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}
      end
    end
  end

  def handle_in("move_resource", payload, socket) do
    if payload["source_collection_id"] == payload["target_collection_id"] do
      case can_edit_collection(socket.assigns.user_id, payload["source_collection_id"]) do
        {:ok, _} -> 
          Core.Dashboard.Resources.move_resource(
            payload["resource_id"],
            payload["target_collection_id"],
            payload["target_index"]
          )

          {:noreply, socket}
        {:error, _} ->
          {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}
      end
    else
      if can_move_collection(socket.assigns.user_id, payload["source_collection_id"]) &&
           can_move_collection(socket.assigns.user_id, payload["target_collection_id"]) do
        Core.Dashboard.Resources.move_resource(
          payload["resource_id"],
          payload["target_collection_id"],
          payload["target_index"]
        )

        # broadcast! socket, "remove_resource", payload
        # broadcast! socket, "add_resource_by_index", payload
        {:noreply, socket}
      else
        {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}
      end
    end
  end

  def handle_in("create_collection", %{"title" => title}, socket) do
    if socket.assigns.user_id do
      case Core.Dashboard.Collections.new_collection(socket.assigns.user_id, title) do
        {:ok, collection} ->
          broadcast!(
            socket,
            "add_collection_to_dashboard",
            ApiWeb.CollectionView.render("dashboardCollection.json", collection: collection)
          )

          {:noreply, socket}

        _ ->
          {:reply, {:error, %{msg: "Collection not created."}}, socket}
      end
    else
      {:reply, {:error, %{msg: "You must be signed in."}}}
    end
  end

  def handle_in("remove_collection", payload, socket) do
    if !is_inbox(socket.assigns.user_id, payload["collection_id"]) do
      case can_move_collection(socket.assigns.user_id, payload["collection_id"]) do
        {:ok, _} -> 
          Core.Dashboard.Collections.remove_collection(
            socket.assigns.user_id,
            payload["collection_id"]
          )

          broadcast!(socket, "remove_collection", payload)
          {:noreply, socket}
        {:error, _} -> 
          {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}
      end
    else
      {:reply, {:error, %{msg: "You cannot delete your inbox."}}, socket}
    end
  end

  def handle_in("clone_collection", payload, socket) do
    collection =
      try do
        Search.Collections.clone_collection(payload["collection_id"], socket.assigns.user_id)
      catch
        _, _ -> :error
      end

    case collection do
      :error ->
        {:reply, {:error, %{msg: "Collection was not cloned"}}, socket}

      _ ->
        broadcast!(
          socket,
          "clone_collection",
          ApiWeb.CollectionView.render("dashboardCollection.json", collection: collection)
        )

        {:noreply, socket}
    end
  end

  def handle_in("import_collection", payload, socket) do
    collection =
      try do
        Search.Collections.import_collection(payload["collection_id"], socket.assigns.user_id)
      catch
        _, _ -> :error
      end

    case collection do
      :error ->
        {:reply, {:error, %{msg: "Collection was not imported"}}, socket}

      _ ->
        broadcast!(
          socket,
          "import_collection",
          ApiWeb.CollectionView.render("dashboardCollection.json", collection: collection)
        )

        {:noreply, socket}
    end
  end

  def terminate(reason, socket) do
    Logger.info"> leave - user_id: #{socket.assigns.user_id}, #{socket.topic}, #{inspect reason}"
    :ok
  end
end
