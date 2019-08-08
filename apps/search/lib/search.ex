defmodule Search do
  @moduledoc """
  Documentation for Search.
  """

  @doc """
  High-level function for searching the active catalog, collections by
  content, and collections by user.

  Takes a search string as a string, an optional limit for number of
  results as an integer, an optional offset from the first result for
  results as an integer, and an optional set of filters as a map.

  Returns a tagged tuple containing a map of results by search target.

  ## Example

      iex> all("search phrase", 10, 0)
      {:ok, 
        %{catalogs: [results], 
          collections: [results], 
          users: [results]
         }
       }

  """
  def all(string, limit \\ 25, offset \\ 0, filters \\ %{}) do
    catalogs = Task.async(Search, :search_catalogs, [string, limit, offset, filters])
    collections = Task.async(Search, :search_collections, [string, limit, offset])
    users = Task.async(Search, :search_users, [string, limit, offset])

    {:ok,
     %{
       catalogs: Task.await(catalogs, 60_000),
       collections: Task.await(collections, 60_000),
       users: Task.await(users, 60_000)
     }}
  end

  @doc """
  High-level function for searching the active catalog.

  Takes a search string as a string, a limit as an integer, an offset as an 
  integer, and a set of filters as a map.

  Passes those values on to the search() function supplied by the extension
  for the catalog specified as active in sorin.exs.

  ## Example

      iex> search_catalogs("Proust", 25, 0)
      [%{}, ...]


  """
  def search_catalogs(string, limit, offset, filters) do
    Kernel.apply(
      Application.get_env(:search, :search_target),
      :search,
      [string, limit, offset, filters]
    )
  end

  @doc """
  Calls Search.Collections.get_published_by_content, with which it is
  redundant.

  Takes a search query as a string, a limit as an integer, and an offset
  from the first result as an integer.

  ## Example

      iex> search_collections("Proust", 2, 0)
      [%Collection{}, %Collection{}]

  """
  def search_collections(string, limit, offset) do
    Search.Collections.get_published_by_content(string, limit, offset)
  end

  @doc """
  Calls Search.Collections.get_published_by_user, with which it is
  redundant.

  Takes a search query as a string, a limit as an integer, and an offset
  from the first result as an integer.

  ## Example

      iex> search_users("Librarian, Jane Q.", 1, 0)
      [%Collection{}]

  """
  def search_users(string, limit, offset) do
    Search.Collections.get_published_by_user(string, limit, offset)
  end

  @doc """
  Randomly selects a word from the local dictionary file and passes it
  to Search.all.

  Takes an optional integer for the number of results desired.

  Provided as a convenience for development in iex.

  ## Example

      iex> random(1)
      {:ok, 
        %{catalogs: [%{}],
          collections: [%Collection{}],
          users: [%Collection{}]
         }
       }

  """
  def random(num_results \\ 25) do
    File.stream!("/usr/share/dict/words")
    |> Enum.random()
    |> String.trim()
    |> all(num_results)
  end
end
