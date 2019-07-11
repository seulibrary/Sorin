defmodule ApiWeb.CollectionChannel do
  use ApiWeb, :channel

  require Logger

  import ApiWeb.Utils

  alias Core.{
    Accounts,
    Collections,
    CollectionsUsers,
    Files,
    Notes,
    Resources
  }

  alias ApiWeb.Presence

  def join("collection:" <> collection_id, _params, socket) do
    case can_move_collection(socket.assigns.user_id, collection_id) do
      {:ok, _} ->
        Logger.info "> Connect to channel collection:" <> collection_id

        send(self(), :after_join)

        {:ok, socket}
      {:error, msg} ->
        Logger.error "> Error Connecting to channel collection:" <> collection_id
        {:reply, {:error, %{msg: msg}}, socket}
    end
  end

  def handle_info(:after_join, socket) do
    # adding test data in the map. Could add in extra data like user name?
    collection_id = String.split(socket.topic, ":") |> List.last

    {:ok, _} = Presence.track(socket, :users, %{
          name: socket.assigns.user.fullname,
          collection_id: collection_id,
          # can_edit_collection: can_edit_collection?(socket.assigns.user_id, collection_id),
          online_at: inspect(System.system_time(:second))
                              })

    push_presence_state(socket)

    {:noreply, socket}
  end

  defp push_presence_state(socket) do
    push(socket, "presence_state", Presence.list(socket))
  end

  def handle_in("edit_collection", payload, socket) do
    Logger.info "> Edit Collection"

    case can_move_collection(socket.assigns.user_id, payload["collection"]["id"]) do
      {:ok, collectionUser} ->
        if payload["color"] do
          Logger.info "> Update Collection Color"

          CollectionsUsers.update_collection_user(
            collectionUser, %{
              color: payload["color"],
              archived: payload["archived"],
              pending_approval: payload["pending_approval"]
            })
        end
    end

    case can_edit_collection(socket.assigns.user_id, payload["collection"]["id"]) do
      {:error, _} ->
        {:reply, {:error, %{msg: "You are unauthorized to edit this collection."}}, socket}

      {:ok, collectionUser} ->
        title = if !is_inbox(socket.assigns.user_id, payload["collection"]["id"]) do
            payload["collection"]["title"]
          else
            "Inbox"
          end

        published = if !is_inbox(socket.assigns.user_id, payload["collection"]["id"]) do
            payload["collection"]["published"]
          else
            false
          end

        Collections.update_collection(
            collectionUser.collection,
          %{
            title: title,
            published: published})
    end

    if payload["currentCollectionNote"] && payload["currentCollectionNote"] != "" do
      case Notes.create_note(%{collection_id: payload["collection"]["id"], body: payload["currentCollectionNote"]}) do
        {:ok, note} ->
          broadcast!(socket, "add_collection_note", %{
                collection_id: payload["collection"]["id"],
                payload: %{
                  id: note.id,
                  body: payload["currentCollectionNote"],
                  updated_at: note.updated_at
                }})
          {:error, _} ->
            {:error, "Note not created"}
      end
    end

    if payload["collection"]["notes"] do
      Notes.update_note_by_id(
        payload["collection"]["notes"]["id"],
        payload["collection"]["notes"]["body"]
      )
    end

    broadcast!(socket, "updated_collection", payload)
    {:noreply, socket}
  end

  def handle_in("add_collection_tag", payload, socket) do
    case can_edit_collection?(socket.assigns.user_id, payload["collection_id"]) do
      false ->
        {:reply, {:error, %{msg: "Permissions lacking"}}, socket}

      true ->
        case Collections.add_tag_by_collection_id(
              payload["collection_id"],
               payload["label"]
             ) do
          {:ok, _} ->
            broadcast!(socket, "add_collection_tag", %{
              collection_id: payload["collection_id"],
              tag: payload["label"]
            })

            {:noreply, socket}
          _ ->
            {:reply, {:error, %{msg: "Tag was not created"}}, socket}
        end
    end
  end

  def handle_in("remove_collection_tag", payload, socket) do
    case can_edit_collection?(socket.assigns.user_id, payload["collection_id"]) do
      false ->
        {:reply, {:error, %{msg: "Permissions lacking"}}, socket}

      true ->
        Collections.remove_tag_by_collection_id(
          payload["collection_id"],
          payload["tag"]
        )

        broadcast!(socket, "remove_collection_tag", %{
          collection_id: payload["collection_id"],
          tag: payload["tag"]
        })

        {:noreply, socket}
    end
  end

  def handle_in("create_resource", payload, socket) do
    case can_edit_collection?(socket.assigns.user_id, payload["collection_id"]) do
      false ->
        {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}

      true ->
        case Resources.create_indexed_resource(
            payload["data"],
            payload["collection_id"]
             ) do
          {:ok, resource} ->
            broadcast!(socket, "add_resource", %{
              id: resource.id,
              collection_id: payload["collection_id"],
              data: ApiWeb.CollectionView.render("resource.json", %{collection: resource})
            })

            {:noreply, socket}

          {:error, _} ->
            {:reply, {:error, %{msg: "Note not created"}}, socket}
        end
    end
  end

  def handle_in("remove_resource", payload, socket) do
    case can_edit_collection?(socket.assigns.user_id, payload["collection_id"]) do
      false ->
        {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}

      true ->
        if Resources.remove_resource_by_id(payload["resource_id"]) do
          broadcast!(socket, "remove_resource", payload)
          {:noreply, socket}
        else
          {:reply, {:error, %{msg: "Something went wrong"}}, socket}
        end
    end
  end

  def handle_in("edit_resource", payload, socket) do
    case can_edit_collection?(socket.assigns.user_id, payload["collection_id"]) do
      false ->
        {:reply, {:error, %{msg: "Invalid Permissions"}}, socket}

      true ->
        resource = Resources.get_resource!(payload["data"]["id"])
        title = if resource.identifier, do: resource.title, else: payload["data"]["title"]

        catalog_url =
          if resource.identifier, do: resource.catalog_url, else: payload["data"]["catalog_url"]

        updates = %{
          title: title,
          catalog_url: catalog_url
        }

        Resources.update_resource(resource, updates)

        if payload["data"]["currentCollectionNote"] &&
             payload["data"]["currentCollectionNote"] != nil do
          case Notes.create_note(%{resource_id: payload["data"]["id"], body: payload["data"]["currentCollectionNote"]}) do
            {:ok, note} ->
              broadcast!(socket, "add_resource_note", %{
                collection_id: payload["collection_id"],
                resource_id: payload["data"]["id"],
                payload: %{
                  id: note.id,
                  body: payload["data"]["currentCollectionNote"],
                  updated_at: note.updated_at
                }
              })

            {:error, _} ->
              {:error, %{msg: "Note not created"}}
          end
        end

        if payload["data"]["notes"] != "" && payload["data"]["notes"] != nil do
          Notes.update_note_by_id(
            payload["data"]["notes"]["id"],
            payload["data"]["notes"]["body"]
          )
        end

        broadcast!(socket, "updated_resource", payload)
        {:noreply, socket}
    end
  end

  def handle_in("upload_file", payload, socket) do
    broadcast!(socket, "start_upload_file", %{})

    file =
      payload
      |> keys_to_atoms()
      |> decode_binary()

    case payload["type"] do
      "collection" ->
        case Files.upload_file(
              file,
              socket.assigns.user_id,
              :collection,
              payload["collection_id"]
             ) do
          {:ok, data} ->
            broadcast!(socket, "file_uploaded", %{
              collection_id: payload["collection_id"],
              resource_id: payload["resource_id"],
              file: %{
                uuid: data.uuid,
                title: data.title,
                size: data.size,
                resource_id: data.resource_id,
                media_type: data.media_type,
                id: data.id,
                collection_id: data.collection_id
              }
            })

            {:reply, {:ok, %{msg: "File Uploaded"}}, socket}

          {:error, msg} ->
            {:reply, {:error, %{msg: msg}}, socket}
        end

      "resource" ->
        case Files.upload_file(
              file,
              socket.assigns.user_id,
              :resource,
              payload["resource_id"]
             ) do
          {:ok, data} ->
            broadcast!(socket, "file_uploaded", %{
              collection_id: payload["collection_id"],
              resource_id: payload["resource_id"],
              file: %{
                uuid: data.uuid,
                title: data.title,
                size: data.size,
                resource_id: data.resource_id,
                media_type: data.media_type,
                id: data.id,
                collection_id: data.collection_id
              }
            })

            {:reply, {:ok, %{msg: "File Uploaded"}}, socket}

          {:error, msg} ->
            {:reply, {:error, %{msg: msg}}, socket}
        end
    end
  end

  def handle_in("delete_file", payload, socket) do
    case Files.get_file_by_uuid(payload["file_id"]) do
      file when is_nil(file) ->
        {:reply, {:error, %{msg: "File Not Deleted!"}}, socket}

      file ->
        broadcast!(socket, "start_delete_file", %{})

        Files.delete_file_by_id(file.id)

        broadcast!(socket, "delete_file", %{
          collection_id: file.collection_id || payload["collection_id"],
          resource_id: file.resource_id,
          file_id: file.id
        })

        {:reply, {:ok, %{msg: "File Deleted"}}, socket}
    end
  end

  def handle_in("google_export", payload, socket) do
    push(socket, "start_google_export", %{})
    case Api.GoogleToken.auth_token(Accounts.get_user!(socket.assigns.user_id)) do
      {:ok, token} ->
        connection = GoogleApi.Drive.V3.Connection.new(token)
        tmp_file_name = Ecto.UUID.generate()
        data = payload["collection_data"]

        # Create File
        File.write(
          "/tmp/#{tmp_file_name}.html",

          Phoenix.View.render_to_iodata(ApiWeb.CollectionView, "google_export.html", data: data["data"])
        )
        Logger.info "> Export File Created."

        # Upload File
        GoogleApi.Drive.V3.Api.Files.drive_files_create_simple(
          connection,
          "multipart",
          %{name: data["data"]["title"], mimeType: "application/vnd.google-apps.document"},
          "/tmp/#{tmp_file_name}.html"
        )
        Logger.info "> Export File Uploaded to Google."

        # Delete file!
        File.rm!("/tmp/#{tmp_file_name}.html")
        Logger.info "> Export File Removed."
      {:error, msg} ->
        Logger.error"> #{msg}"
        push(socket, "export_error", %{msg: msg})
    end

    push(socket, "end_google_export", %{})
    {:reply, {:ok, %{msg: "File exported."}}, socket}
  end

  def terminate(reason, socket) do
    Logger.info"> leave - user_id: #{socket.assigns.user_id}, #{socket.topic}, #{inspect reason}"
    :ok
  end

  defp keys_to_atoms(params) do
    Map.new(params, fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp decode_binary(params) do
    Map.put(params, :binary, Base.decode64!(params.binary))
  end
end
