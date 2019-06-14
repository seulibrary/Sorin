defmodule Search.Collections do
  use Ecto.Schema
  import Ecto.Query

  #######################
  # SEARCH
  ########

  @doc """
  Queries the database for collections whose title or tags contain a specified
  query string.

  Takes a query as a string, a limit as an integer, and an offset from the
  first result as an integer.

  Returns a map containing the total number of results, and a list of the
  results, with the list ordered first by clone count, then by imports count,
  then by id.

  Each collection is returned with all of its content and associations,
  including all content and associations for each resource.

  ## Example

      iex> get_published_by_content("Proust", 2, 0)
      {:num_results: 8, results: [%Collection{}, %Collection{}]}

  """
  def get_published_by_content(string, limit, offset) do
    string_upcased = string |> String.upcase()

    count =
      from(
        c in Core.Collections.Collection,
        left_join: cu in Core.CollectionsUsers.CollectionUser,
        on: c.id == cu.collection_id,
        left_join: u in Core.Accounts.User,
        on: cu.user_id == u.id,
        where: ilike(c.title, ^"%#{string}%"),
        or_where:
          fragment(
            "exists (select * from unnest(?) tag where tag like ?)",
            c.tags,
            ^"%#{string_upcased}%"
          ),
        where: c.published == true,
        # Eliminates clones
        where: cu.write_access == true,
        select: count(c.id)
      )
      |> Core.Repo.one()

    resources_query =
      from(r in Core.Resources.Resource,
        preload: [:files, :notes],
        order_by: r.collection_index
      )

    list_of_collections =
      from(
        c in Core.Collections.Collection,
        left_join: cu in Core.CollectionsUsers.CollectionUser,
        on: c.id == cu.collection_id,
        left_join: u in Core.Accounts.User,
        on: cu.user_id == u.id,
        where: ilike(c.title, ^"%#{string}%"),
        or_where:
          fragment(
            "exists (select * from unnest(?) tag where tag like ?)",
            c.tags,
            ^"%#{string_upcased}%"
          ),
        where: c.published == true,
        # Eliminates clones
        where: cu.write_access == true,
        select: c,
        preload: [
          :files,
          :notes,
          resources: ^resources_query
        ],
        order_by: [desc: c.clones_count, desc: c.imports_count, desc: c.id],
        limit: ^limit,
        offset: ^offset
      )
      |> Core.Repo.all()

    %{num_results: count, results: list_of_collections}
  end

  @doc """
  Queries the database for collections whose creator's fullname contains a
  specified query string.

  Takes a query as a string, a limit as an integer, and an offset from the
  first result as an integer.

  Returns a map containing the total number of results, and a list of the
  results, with the list ordered first by clone count, then by imports count,
  then by id.

  Each collection is returned with all of its content and associations,
  including all content and associations for each resource.

  ## Example

      iex> get_published_by_user("Librarian, Jane Q.", 2, 0)
      {:num_results: 8, results: [%Collection{}, %Collection{}]}

  """
  def get_published_by_user(string, limit, offset) do
    count =
      from(
        c in Core.Collections.Collection,
        left_join: cu in Core.CollectionsUsers.CollectionUser,
        on: c.id == cu.collection_id,
        left_join: u in Core.Accounts.User,
        on: cu.user_id == u.id,
        where: ilike(u.fullname, ^"%#{string}%"),
        # Eliminates clones
        where: c.published == true,
        where: cu.write_access == true,
        select: count(c.id)
      )
      |> Core.Repo.one()

    resources_query =
      from(r in Core.Resources.Resource,
        preload: [:files, :notes],
        order_by: r.collection_index
      )

    list_of_collections =
      from(
        c in Core.Collections.Collection,
        left_join: cu in Core.CollectionsUsers.CollectionUser,
        on: c.id == cu.collection_id,
        left_join: u in Core.Accounts.User,
        on: cu.user_id == u.id,
        where: ilike(u.fullname, ^"%#{string}%"),
        # Eliminates clones
        where: c.published == true,
        where: cu.write_access == true,
        select: c,
        preload: [
          :files,
          :notes,
          resources: ^resources_query
        ],
        order_by: [desc: c.clones_count, desc: c.imports_count, desc: c.id],
        limit: ^limit,
        offset: ^offset
      )
      |> Core.Repo.all()

    %{num_results: count, results: list_of_collections}
  end
end
