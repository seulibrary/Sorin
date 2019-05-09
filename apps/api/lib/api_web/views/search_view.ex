defmodule ApiWeb.SearchView do
  use ApiWeb, :view
  alias ApiWeb.SearchView

  def render("index.json", %{search: search}) do
    %{
      catalogs: search.catalogs,
      users: render_one(search.users, SearchView, "users.json", as: :results),
      collections: render_one(search.collections, SearchView, "collections.json", as: :results)
    }
  end

  def render("collections.json", %{results: results}) do
    %{
      num_results: results.num_results,
      results: render_many(results.results, ApiWeb.CollectionView, "collection.json", as: :collection) 
    }
  end

  def render("users.json", %{results: results}) do
    %{
      num_results: results.num_results,
      results: render_many(results.results, ApiWeb.CollectionView, "collection.json", as: :collection) 
    }
  end

  def render("catalogs.json", %{results: results}) do
    results
  end
end
