defmodule ApiWeb.SearchChannel do
  use ApiWeb, :channel
  
  require Logger

  def join("search:" <> user_id, _params, socket) do
    current_user = socket.assigns.user_id

    case Phoenix.Token.verify(socket, "user_id", user_id, max_age: 86400) do
      {:ok, id} ->
        if current_user == id do
          {:ok, socket}
        else
          {:error, %{reason: "Invalid user"}}
        end

      {:error, _reason} ->
        {:error, %{reason: "Invalid user"}}
    end
  end

  def handle_in(
        "search",
        %{
          "query" => query,
          "limit" => limit,
          "offset" => offset,
          "filters" => filters
        },
        socket
      ) do

    case Search.all(query, limit, offset, filters) do
      {:ok, search} ->
        broadcast!(
          socket,
          "search",
          ApiWeb.SearchView.render("index.json", %{search: search})
        )
        {:noreply, socket}

      {:error, _} ->
        {:reply, {:error, %{msg: "Search results not returned"}}, socket}
    end
  end

  def handle_in(
    "load_more_catalog_results",
    params,
    socket
  ) do
    results = Search.search_catalogs(params["query"], params["limit"], params["offset"], params["filters"])
    
    broadcast!(
      socket,
      "load_more_catalog_results",
      ApiWeb.SearchView.render("catalogs.json", %{results: results})
      )
    {:noreply, socket}
  end

  def handle_in(
    "load_more_user_results",
    params,
    socket
  ) do
    results = Search.search_users(params["query"], params["limit"], params["offset"]) 

    broadcast!(
      socket,
      "load_more_user_results",
      ApiWeb.SearchView.render("users.json", %{results: results})
    )
    {:noreply, socket}
  end


  def handle_in(
    "load_more_collection_results",
    params,
    socket
  ) do
    results = Search.search_collections(params["query"], params["limit"], params["offset"])

    broadcast!(
      socket,
      "load_more_collection_results",
      ApiWeb.SearchView.render("collections.json", %{results: results})
    )
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    Logger.info"> leave - user_id: #{socket.assigns.user_id}, #{socket.topic}, #{inspect reason}"
    :ok
  end
end
