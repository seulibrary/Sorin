defmodule EctoHelper do
  @exceptions [NaiveDateTime, DateTime]
  @bloat [:__meta__, :__struct__, :__cardinality__, :__field__, :__owner__]

  def strip_meta(list) when is_list(list) do
    Enum.map(list, &strip_meta/1)
  end

  def strip_meta(schema) when is_map(schema) do
    Map.take(schema, Map.keys(schema) -- @bloat) |> Enum.map(&strip_meta/1) |> Enum.into(%{})
  end

  def strip_meta({key, %{__struct__: struct} = val})
      when struct in @exceptions,
      do: {key, val}

  def strip_meta({key, val}) when is_map(val) or is_list(val) do
    {key, strip_meta(val)}
  end

  def strip_meta(data), do: data
end
