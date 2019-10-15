defmodule ApiWeb.V1.SearchController do
  use ApiWeb, :controller

  require Logger

  action_fallback ApiWeb.FallbackController

  def search(conn, params) do
    filters =
      if params["filters"] do
        params["filters"]
        # Remove first character "["
        |> String.slice(1..-1)
        # Remove last character "]"
        |> String.slice(0..-2)
        # Convert query string into map
        |> URI.decode_query()
      else
        %{}
      end

    limit =
      if params["limit"] do
        params["limit"]
        |> convert_params_to_int
      else
        25
      end

    offset =
      if params["offset"] do
        params["offset"]
        |> convert_params_to_int
      else
        0
      end

    {status, user_id} =
      Phoenix.Token.verify(conn, "user_id", conn.private[:plug_session]["user_id"], max_age: 86400)

    # if type param is being passed in, it's an append (not the item_type under filters)
    if params["type"] do
      case params["type"] do
        "catalog" ->
          Logger.info(
            "> Search: #{params["query"]}, limit: #{limit}, offset: #{offset}, filters: #{
              params["filters"]
            }, type: catalog"
          )

          conn
          |> put_view(ApiWeb.SearchView)
          |> remove_non_authorized_content(user_id, "catalogs.json", %{
            results: Search.search_catalogs(params["query"], limit, offset, filters)
          })

        "user" ->
          Logger.info(
            "> Search: #{params["query"]}, limit: #{limit}, offset: #{offset}, filters: #{
              params["filters"]
            }, type: user"
          )

          conn
          |> put_view(ApiWeb.SearchView)
          |> remove_non_authorized_content(user_id, "users.json", %{
            results: Search.search_users(params["query"], limit, offset)
          })

        "collection" ->
          Logger.info(
            "> Search: #{params["query"]}, limit: #{limit}, offset: #{offset}, filters: #{
              params["filters"]
            }, type: collection"
          )

          conn
          |> put_view(ApiWeb.SearchView)
          |> remove_non_authorized_content(user_id, "collections.json", %{
            results: Search.search_collections(params["query"], limit, offset)
          })
      end
    else
      case Search.all(params["query"], limit, offset, filters) do
        {:ok, search} ->
          Logger.info(
            "> Search: #{params["query"]}, limit: #{limit}, offset: #{offset}, filters: #{
              params["filters"]
            }, type: all"
          )

          conn
          |> put_view(ApiWeb.SearchView)
          |> remove_non_authorized_content(user_id, "index.json", %{search: search})

        {:error, _} ->
          Logger.error(
            "> Search Error: #{params["query"]}, limit: #{limit}, offset: #{offset}, filters: #{
              params["filters"]
            }, type: all"
          )

          conn
          |> put_status(400)
          |> json(%{message: "Search results not returned."})
      end
    end
  end

  defp convert_params_to_int(input) when input |> is_integer, do: input
  defp convert_params_to_int(input), do: input |> String.to_integer()

  defp remove_non_authorized_content(
         conn,
         :missing,
         "catalogs.json",
         %{:results => _content} = data
       ) do
    conn
    |> render("catalogs.json", data)
  end

  defp remove_non_authorized_content(conn, :missing, view, %{:results => content}) do
    conn
    |> render(view, %{results: nil})
  end

  defp remove_non_authorized_content(conn, :missing, view, %{:search => content}) do
    data =
      content
      |> update_in([:users, :results], fn _ -> [] end)
      |> update_in([:collections, :results], fn _ -> [] end)

    conn
    |> render(view, %{search: data})
  end

  defp remove_non_authorized_content(conn, user_id, view, content) do
    conn
    |> render(view, content)
  end
end
