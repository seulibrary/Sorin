defmodule ApiWeb.TokenView do
  use ApiWeb, :view

  def render("tokens.json", %{data: data}) do
    %{
      token_count: length(data),
      data: render_many(data, ApiWeb.TokenView, "token.json", as: :data)
    }
  end

  def render("token.json", %{data: data}) do
    %{
      token: data.token["key"] || data.token.key,
      use_count: data.use_count,
      label: data.label
    }
  end
end
