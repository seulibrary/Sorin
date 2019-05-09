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
	left_join: cu in Core.Collections.CollectionsUsers,
	on: c.id == cu.collection_id,
	left_join: u in Core.Accounts.User,
	on: cu.user_id == u.id,
	where: ilike(c.title, ^"%#{string}%"),
	or_where: fragment("exists (select * from unnest(?) tag where tag like ?)",
	  c.tags, ^"%#{string_upcased}%"),
	where: c.published == true,
	where: cu.write_access == true, # Eliminates clones
	select: count(c.id)
      )
      |> Core.Repo.one()

    resources_query =
      from r in Core.Resources.Resource,
      preload: [:files, :notes],
      order_by: r.collection_index

    list_of_collections =
      from(
	c in Core.Collections.Collection,
	left_join: cu in Core.Collections.CollectionsUsers,
	on: c.id == cu.collection_id,
	left_join: u in Core.Accounts.User,
	on: cu.user_id == u.id,
	
	where: ilike(c.title, ^"%#{string}%"),
	or_where: fragment("exists (select * from unnest(?) tag where tag like ?)",
	  c.tags, ^"%#{string_upcased}%"),
	where: c.published == true,
	where: cu.write_access == true, # Eliminates clones
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
	left_join: cu in Core.Collections.CollectionsUsers,
	on: c.id == cu.collection_id,
	left_join: u in Core.Accounts.User,
	on: cu.user_id == u.id,
	where: ilike(u.fullname, ^"%#{string}%"),
	where: c.published == true, # Eliminates clones
	where: cu.write_access == true,
	select: count(c.id)
      )
      |> Core.Repo.one()
    
    resources_query =
      from r in Core.Resources.Resource,
      preload: [:files, :notes],
      order_by: r.collection_index

    list_of_collections =
      from(
	c in Core.Collections.Collection,
	left_join: cu in Core.Collections.CollectionsUsers,
	on: c.id == cu.collection_id,
	left_join: u in Core.Accounts.User,
	on: cu.user_id == u.id,
	where: ilike(u.fullname, ^"%#{string}%"),
	where: c.published == true, # Eliminates clones
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

  #######################
  # IMPORT/CLONE
  ##############

  @doc """
  High-level function for "cloning" a collection, where cloning means that
  a new collections_users record is created for a specified collection and a
  specified user, with write_access set to false. The collection will appear
  on the new user's dashboard, and they will get all updates to it in real 
  time, but they will not be able to edit it themselves.

  The original collection's "clones_count" field is incremented, and the
  "cloned_from" field on the new collections_users record is populated with
  the fullname of the original collection's creator.

  Takes a valid collection id as an integer and a valid user id as an integer.

  Returns a custom map containing the collection struct and certain fields
  from the new collections_users record.

  ## Example

      iex> clone_collection(collection_id, user_id)
      %{archived: false,
      cloned_from: "Librarian, Jane Q.",
      collection: %Collection{},
      color: nil, 
      ...}

  """
  def clone_collection(collection_id, user_id) do
    new_index = Core.Accounts.get_highest_collections_users_index(user_id) + 1

    Core.Repo.transaction(fn ->
      author_name =
        from(
          c in Core.Collections.Collection,
          left_join: cu in Core.Collections.CollectionsUsers,
          on: c.id == cu.collection_id,
          left_join: u in Core.Accounts.User,
          on: cu.user_id == u.id,
          where: c.id == ^collection_id,
          where: u.id == c.creator_id,
          select: u.fullname)
        |> Core.Repo.one()

      Core.Collections.create_collections_users(%{
        collection_id: collection_id,
        user_id: user_id,
        index: new_index,
        write_access: false,
        cloned_from: author_name})

      from(
        c in Core.Collections.Collection,
        where: c.id == ^collection_id)
      |> Core.Repo.update_all(inc: [clones_count: 1])
    end)

    resources_query =
      from r in Core.Resources.Resource,
      preload: [:files, :notes],
      order_by: r.collection_index
    
    from(
      c in Core.Collections.Collection,
      left_join: cu in Core.Collections.CollectionsUsers,
      on: c.id == cu.collection_id,

      where: cu.user_id == ^user_id,
      where: c.id == ^collection_id,
      select: %{
        archived:         cu.archived,
        cloned_from:      cu.cloned_from,
        collection:       c,
        color:            cu.color,
	index:            cu.index,
        pending_approval: cu.pending_approval,
        write_access:     cu.write_access
      },
      preload: [
	:files,
	:notes,
	resources: ^resources_query
      ],
      order_by: cu.index
    )
    |> Core.Repo.one()
  end

  @doc """
  High-level function for "importing" a collection, where importing means
  the specified collection is exactly recreated as an original collection
  for the specified user with all content and associations intact, except 
  for file associations, which are not imported.

  The original collection's "imports_count" field is incremented, and the
  new collection's "provenance" field is populated with a string recording
  that it was imported from [fullname of original collection's creator] on
  [timestamp].

  Takes a valid collection id as an integer and a valid user id as an integer.

  Returns a map containing the new collection struct and certain fields from
  the new collections_users record.

  ## Example

      iex> import_collection(collection_id, user_id)
      %{archived: false,
      collection: %Collection{},
      color: nil,
      provenance: "Imported from Librarian, Jane Q. on [timestamp].",
      ...}

  """
  def import_collection(collection_id, user_id) do
    new_index = Core.Accounts.get_highest_collections_users_index(user_id) + 1

    # Subquery for resources' assocations in order to preserve
    # correct resource indexing (ordering)
    resources_query =
      from r in Core.Resources.Resource,
      preload: [:notes],
      order_by: r.collection_index

    # Main collection query
    source_collection =
      from(
        c in Core.Collections.Collection,
        where: c.id == ^collection_id,
        select: c,
        preload: [
	  :notes,
	  resources: ^resources_query])
      |> Core.Repo.one()

    # Get current timestamp and full name of the source collection's creator
    # for the new collection's provenance field; get fullname of new user
    # for write_users field of new collection
    date =
      DateTime.utc_now()
      |> DateTime.truncate(:second)
      |> DateTime.to_naive()

    creator_fullname =
      Core.Accounts.get_user!(source_collection.creator_id)
      |> Map.get(:fullname)

    new_user_fullname =
      Core.Accounts.get_user!(user_id)
      |> Map.get(:fullname)

    # Create the new collection	
    {:ok, new_collection} =
      Core.Collections.create_collection(
	%{creator_id: user_id,
          permalink: Ecto.UUID.generate(),
          title: source_collection.title,
          provenance: "Imported from #{creator_fullname} on #{date} UTC",
	  write_users: ["#{new_user_fullname}"],
	})

    # Create the new collections_users record
    Core.Repo.transaction(fn ->
      Core.Collections.create_collections_users(
	%{collection_id: new_collection.id,
          user_id: new_collection.creator_id,
          index: new_index,
          write_access: true})
      # Increment imports count on original
      from(
        c in Core.Collections.Collection,
        where: c.id == ^collection_id)
      |> Core.Repo.update_all(inc: [imports_count: 1])
    end)

    # If exists, migrate note association
    cond do
      source_collection.notes == nil -> nil
      true ->
	Core.Notes.import_note_to_collection(source_collection.notes.id, new_collection.id)
    end

    # Import resources to the new collection
    # NOTE: Core.Resources.copy_resource() creates a new resource with
    #       certain fields copied from the original. Notes are imported,
    #       but not files.
    source_collection.resources
    |> Enum.map(fn x -> Map.get(x, :id) end)
    |> Enum.map(fn x -> Core.Resources.copy_resource(x, new_collection.id) end)

    # Return the imported collection
    from(
      c in Core.Collections.Collection,
      left_join: cu in Core.Collections.CollectionsUsers,
      on: c.id == cu.collection_id,
      where: cu.user_id == ^user_id,
      where: c.id == ^new_collection.id,
      select: %{
	archived:         cu.archived,
        cloned_from:      cu.cloned_from,
        collection:       c,
        color:            cu.color,
	index:            cu.index,
        pending_approval: cu.pending_approval,
        write_access:     cu.write_access
      },
      preload: [
	:files,
	:notes,
	resources: ^resources_query
      ])
    |> Core.Repo.one()
  end
end
