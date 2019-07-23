defmodule ApiWeb.V1.SearchController do
  use ApiWeb, :controller

  action_fallback ApiWeb.FallbackController

  # Could make these just one variable, then parse out later so all are not required?
  def search(conn, %{"query" => query, "limit" => limit, "offset" => offset} = params) do    
    filters = if params["filters"] do 
      params["filters"] 
      |> String.slice(1..-1) # Remove first character "["
      |> String.slice(0..-2) # Remove last character "]"
      |> URI.decode_query # Convert query string into map
    else
      %{}
    end

    case Search.all(query, limit |> convert_params_to_int, offset |> convert_params_to_int, filters) do
      {:ok, search} ->
        conn
        |> put_view(ApiWeb.SearchView)
        |> render("index.json", %{search: search})
      {:error, _} ->
        conn
        |> put_status(400)
        |> json(%{message: "Search results not returned."})
    end
  end

  def search(conn, %{"query" => query, "limit" => limit, "offset" => offset, "filters" => filters, "type" => type}) do
    case type do
      "catalog" ->
        conn
        |> put_view(ApiWeb.SearchView)
        |> render("catalogs.json", %{results: Search.search_catalogs(query, limit, offset, filters)})

      "user" ->
        conn
        |> put_view(ApiWeb.SearchView)
        |> render("users.json", %{results: Search.search_users(query, limit, offset)})

      "collection" ->
        conn
        |> put_view(ApiWeb.SearchView)
        |> render("collections.json", %{results: Search.search_collections(query, limit, offset)})
    end
  end

  def search(conn, params) do
    conn
    |> put_status(400)
    |> json(%{message: "Search results not returned."})
  end

  def convert_params_to_int(input) when input |> is_integer, do: input
  def convert_params_to_int(input), do: input |> String.to_integer
end
