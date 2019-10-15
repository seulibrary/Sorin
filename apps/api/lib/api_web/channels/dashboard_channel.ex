defmodule ApiWeb.DashboardChannel do
  use ApiWeb, :channel
  # use Phoenix.Socket, log: :debug

  require Logger

  import ApiWeb.Utils

  alias Core.{
    Accounts,
    Collections,
    CollectionsUsers,
    Resources
  }

  def join("dashboard:" <> _dashboard_id, _params, socket) do
    if socket.assigns.user_id do
      dashboard = Accounts.get_dashboard(socket.assigns.user_id)

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
    if !is_inbox(socket.assigns.user_id, payload["collection_id"]) && payload["new_index"] != 0 do
      case can_move_collection?(socket.assigns.user_id, payload["collection_id"]) do
        true ->
          CollectionsUsers.move_collection(
            payload["collection_id"],
            socket.assigns.user_id,
            payload["new_index"]
          )

          broadcast!(socket, "move_collection", payload)
          {:reply, {:ok, %{msg: "Collection moved."}}, socket}

        false ->
          {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}
      end
    end
  end

  def handle_in("move_resource", payload, socket) do
    if can_edit_collection?(socket.assigns.user_id, payload["source_collection_id"]) ||
         (can_move_collection?(socket.assigns.user_id, payload["source_collection_id"]) &&
            can_move_collection?(socket.assigns.user_id, payload["target_collection_id"])) do
      Resources.move_resource_by_id(
        payload["resource_id"],
        payload["target_collection_id"],
        payload["target_index"]
      )

      broadcast!(socket, "move_resource", payload)
      {:reply, {:ok, %{msg: "Resource moved."}}, socket}
    else
      {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}
    end
  end

  def handle_in("create_collection", %{"title" => title}, socket) do
    if socket.assigns.user_id do
      case Collections.new_collection(socket.assigns.user_id, title) do
        %CollectionsUsers.CollectionUser{} = collection ->
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
      case can_move_collection?(socket.assigns.user_id, payload["collection_id"]) do
        true ->
          Collections.remove_collection(
            payload["collection_id"],
            socket.assigns.user_id
          )

          broadcast!(socket, "remove_collection", payload)
          {:noreply, socket}

        false ->
          {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}
      end
    else
      {:reply, {:error, %{msg: "You cannot delete your inbox."}}, socket}
    end
  end

  def handle_in("share_collection", _payload, socket) do
    # Does user exist?
    # Share success?

    # Collections.share_collection(payload["collection_id"], payload["user_email"])
    {:noreply, socket}
  end

  def handle_in("approve_collection", _payload, socket) do
    # Update collection to pending false
    {:noreply, socket}
  end

  def handle_in("clone_collection", payload, socket) do
    collection =
      try do
        Collections.clone_collection_by_id(payload["collection_id"], socket.assigns.user_id)
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
        Collections.import_collection_by_id(payload["collection_id"], socket.assigns.user_id)
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
end
