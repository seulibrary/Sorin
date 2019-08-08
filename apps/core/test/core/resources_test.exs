defmodule Core.ResourcesTest do
  use Core.DataCase

  alias Core.Resources

  describe "resources" do
    alias Core.Resources.Resource

    @valid_attrs %{call_number: "some call_number", catalog_url: "some catalog_url", collection_index: 42, contributor: [], coverage: "some coverage", creator: [], date: "some date", description: "some description", direct_url: "some direct_url", doi: "some doi", ext_collection: "some ext_collection", format: "some format", identifier: "some identifier", is_part_of: "some is_part_of", issue: "some issue", journal: "some journal", language: "some language", page_end: "some page_end", page_start: "some page_start", pages: "some pages", publisher: "some publisher", relation: "some relation", rights: "some rights", series: "some series", source: "some source", subject: [], tags: [], title: "some title", type: "some type", volume: "some volume"}
    @update_attrs %{call_number: "some updated call_number", catalog_url: "some updated catalog_url", collection_index: 43, contributor: [], coverage: "some updated coverage", creator: [], date: "some updated date", description: "some updated description", direct_url: "some updated direct_url", doi: "some updated doi", ext_collection: "some updated ext_collection", format: "some updated format", identifier: "some updated identifier", is_part_of: "some updated is_part_of", issue: "some updated issue", journal: "some updated journal", language: "some updated language", page_end: "some updated page_end", page_start: "some updated page_start", pages: "some updated pages", publisher: "some updated publisher", relation: "some updated relation", rights: "some updated rights", series: "some updated series", source: "some updated source", subject: [], tags: [], title: "some updated title", type: "some updated type", volume: "some updated volume"}
    @invalid_attrs %{call_number: nil, catalog_url: nil, collection_index: nil, contributor: nil, coverage: nil, creator: nil, date: nil, description: nil, direct_url: nil, doi: nil, ext_collection: nil, format: nil, identifier: nil, is_part_of: nil, issue: nil, journal: nil, language: nil, page_end: nil, page_start: nil, pages: nil, publisher: nil, relation: nil, rights: nil, series: nil, source: nil, subject: nil, tags: nil, title: nil, type: nil, volume: nil}

    def resource_fixture(attrs \\ %{}) do
      {:ok, resource} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Resources.create_resource()

      resource
    end

    test "list_resources/0 returns all resources" do
      resource = resource_fixture()
      assert Resources.list_resources() == [resource]
    end

    test "get_resource!/1 returns the resource with given id" do
      resource = resource_fixture()
      assert Resources.get_resource!(resource.id) == resource
    end

    test "create_resource/1 with valid data creates a resource" do
      assert {:ok, %Resource{} = resource} = Resources.create_resource(@valid_attrs)
      assert resource.call_number == "some call_number"
      assert resource.catalog_url == "some catalog_url"
      assert resource.collection_index == 42
      assert resource.contributor == []
      assert resource.coverage == "some coverage"
      assert resource.creator == []
      assert resource.date == "some date"
      assert resource.description == "some description"
      assert resource.direct_url == "some direct_url"
      assert resource.doi == "some doi"
      assert resource.ext_collection == "some ext_collection"
      assert resource.format == "some format"
      assert resource.identifier == "some identifier"
      assert resource.is_part_of == "some is_part_of"
      assert resource.issue == "some issue"
      assert resource.journal == "some journal"
      assert resource.language == "some language"
      assert resource.page_end == "some page_end"
      assert resource.page_start == "some page_start"
      assert resource.pages == "some pages"
      assert resource.publisher == "some publisher"
      assert resource.relation == "some relation"
      assert resource.rights == "some rights"
      assert resource.series == "some series"
      assert resource.source == "some source"
      assert resource.subject == []
      assert resource.tags == []
      assert resource.title == "some title"
      assert resource.type == "some type"
      assert resource.volume == "some volume"
    end

    test "create_resource/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_resource(@invalid_attrs)
    end

    test "update_resource/2 with valid data updates the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{} = resource} = Resources.update_resource(resource, @update_attrs)
      assert resource.call_number == "some updated call_number"
      assert resource.catalog_url == "some updated catalog_url"
      assert resource.collection_index == 43
      assert resource.contributor == []
      assert resource.coverage == "some updated coverage"
      assert resource.creator == []
      assert resource.date == "some updated date"
      assert resource.description == "some updated description"
      assert resource.direct_url == "some updated direct_url"
      assert resource.doi == "some updated doi"
      assert resource.ext_collection == "some updated ext_collection"
      assert resource.format == "some updated format"
      assert resource.identifier == "some updated identifier"
      assert resource.is_part_of == "some updated is_part_of"
      assert resource.issue == "some updated issue"
      assert resource.journal == "some updated journal"
      assert resource.language == "some updated language"
      assert resource.page_end == "some updated page_end"
      assert resource.page_start == "some updated page_start"
      assert resource.pages == "some updated pages"
      assert resource.publisher == "some updated publisher"
      assert resource.relation == "some updated relation"
      assert resource.rights == "some updated rights"
      assert resource.series == "some updated series"
      assert resource.source == "some updated source"
      assert resource.subject == []
      assert resource.tags == []
      assert resource.title == "some updated title"
      assert resource.type == "some updated type"
      assert resource.volume == "some updated volume"
    end

    test "update_resource/2 with invalid data returns error changeset" do
      resource = resource_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_resource(resource, @invalid_attrs)
      assert resource == Resources.get_resource!(resource.id)
    end

    test "delete_resource/1 deletes the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{}} = Resources.delete_resource(resource)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_resource!(resource.id) end
    end

    test "change_resource/1 returns a resource changeset" do
      resource = resource_fixture()
      assert %Ecto.Changeset{} = Resources.change_resource(resource)
    end
  end
end
