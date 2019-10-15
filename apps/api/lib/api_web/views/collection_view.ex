defmodule ApiWeb.CollectionView do
  use ApiWeb, :view
  use Phoenix.HTML

  def render("index.json", %{data: data}) do
    %{data: render_many(data, __MODULE__, "show.json")}
  end

  def render("show.json", %{collection: collection}) do
    render_one(collection, __MODULE__, "dashboardCollection.json")
  end

  def render("dashboardCollection.json", %{collection: data}) do
    %{
      archived: data.archived,
      cloned_from: data.cloned_from,
      collection: render_one(data.collection, __MODULE__, "collection.json", as: :collection),
      color: data.color,
      index: data.index,
      id: data.id,
      pending_approval: data.pending_approval,
      write_access: data.write_access
    }
  end

  def render("collection.json", %{collection: collection}) do
    files =
      if Map.has_key?(collection, :files) do
        if Ecto.assoc_loaded?(collection.files) do
          render_many(collection.files, __MODULE__, "file.json", as: :file)
        else
          []
        end
      end

    notes =
      if Map.has_key?(collection, :notes) do
        if Ecto.assoc_loaded?(collection.notes) do
          render_one(collection.notes, __MODULE__, "note.json", as: :note)
        else
          nil
        end
      end

    resources =
      if Map.has_key?(collection, :resources) do
        if Ecto.assoc_loaded?(collection.resources) do
          render_many(collection.resources, __MODULE__, "resource.json")
        else
          []
        end
      end

    %{
      clones_count: collection.clones_count,
      creator_id: collection.creator_id,
      files: files,
      id: collection.id,
      imports_count: collection.imports_count,
      inserted_at: collection.inserted_at |> NaiveDateTime.to_string(),
      notes: notes,
      permalink: collection.permalink,
      import_stamp: collection.import_stamp,
      published: collection.published,
      resources: resources,
      tags: collection.tags,
      title: collection.title,
      updated_at: collection.updated_at |> NaiveDateTime.to_string(),
      # users: collection.users, not preloaded
      write_users: collection.write_users
    }
  end

  def render("resource.json", %{collection: rec}) do
    files =
      if Map.has_key?(rec, :files) do
        if Ecto.assoc_loaded?(rec.files) do
          render_many(rec.files, __MODULE__, "file.json", as: :file)
        else
          []
        end
      end

    notes =
      if Map.has_key?(rec, :notes) do
        if Ecto.assoc_loaded?(rec.notes) do
          render_one(rec.notes, __MODULE__, "note.json", as: :note)
        else
          nil
        end
      end

    %{
      catalog_url: rec.catalog_url,
      call_number: rec.call_number,
      collection_index: rec.collection_index,
      contributor: rec.contributor,
      coverage: rec.coverage,
      creator: rec.creator,
      date: rec.date,
      description: rec.description,
      doi: rec.doi,
      ext_collection: rec.ext_collection,
      files: files,
      format: rec.format,
      id: rec.id,
      identifier: rec.identifier,
      inserted_at: rec.inserted_at,
      is_part_of: rec.is_part_of,
      issue: rec.issue,
      journal: rec.journal,
      language: rec.language,
      notes: notes,
      page_start: rec.page_start,
      page_end: rec.page_end,
      pages: rec.pages,
      publisher: rec.publisher,
      relation: rec.relation,
      rights: rec.rights,
      series: rec.series,
      source: rec.source,
      subject: rec.subject,
      tags: rec.tags,
      title: rec.title,
      type: rec.type,
      updated_at: rec.updated_at,
      volume: rec.volume
    }
  end

  def render("inbox_save.json", %{resource: resource, inbox_id: inbox_id}) do
    %{
      inbox_id: inbox_id,
      data: resource
    }
  end

  def render("file.json", %{file: file}) do
    %{
      collection_id: file.collection_id,
      # file_url: file.file_url, Does not belong in FE
      id: file.id,
      inserted_at: file.inserted_at |> NaiveDateTime.to_string(),
      media_type: file.media_type,
      resource_id: file.resource_id,
      size: file.size,
      title: file.title,
      updated_at: file.updated_at |> NaiveDateTime.to_string(),
      # user: file.user,
      uuid: file.uuid
    }
  end

  def render("note.json", %{note: note}) do
    %{
      body: note.body,
      collection_id: note.collection_id,
      id: note.id,
      inserted_at: note.inserted_at |> NaiveDateTime.to_string(),
      resource_id: note.resource_id,
      updated_at: note.updated_at |> NaiveDateTime.to_string()
    }
  end
end
