defmodule Core.AuthTokens do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.AuthTokens.AuthToken

  @doc """
   Returns the list of auth_tokens.

  ## Examples

      iex> list_auth_tokens()
      [%AuthToken{}, ...]

  """
  def list_auth_tokens do
    Repo.all(AuthToken)
  end

  @doc """
  Gets a single auth_token by token.

  Raises `Ecto.NoResultsError` if the Auth token does not exist.

  ## Examples

      iex> get_auth_token!(123)
      %AuthToken{}

      iex> get_auth_token!(456)
      ** (Ecto.NoResultsError)

  """
  def get_auth_token(token), do: Repo.get_by(AuthToken, token: token)

  @doc """
  Gets all auth_tokens by user_id.

  Raises `Ecto.NoResultsError` of tje Auth token does not exist.

  ## Examples

      iex> get_auth_tokens_by_user_id!(123)
      [%AuthToken{}]

      iex> get_auth_tokens_by_user_id!(456)
      []
  """
  def get_auth_tokens_by_user_id(id, type) do
    AuthToken
    |> where(user_id: ^id, type: ^type)
    |> Repo.all
  end

  @doc """
  Get loging auth_token by user_id.

  Raises `Ecto.NoResultsError` of tje Auth token does not exist.

  ## Examples

  iex> get_login_token_by_user_id!(123)
  %AuthToken{}

  iex> get_login_token_by_user_id!(456)
  ** (Ecto.NoResultsError)
  """
  def get_login_token_by_user_id(id) do
    AuthToken
    |> Repo.get_by(user_id: id, type: "login")
  end

  @doc """
  Creates a auth_token.

  ## Examples

      iex> create_auth_token(%{field: value})
      {:ok, %AuthToken{}}

      iex> create_auth_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_auth_token(attrs \\ %{}) do
    %AuthToken{}
    |> AuthToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a auth_token.

  ## Examples

      iex> update_auth_token(auth_token, %{field: new_value})
      {:ok, %AuthToken{}}

      iex> update_auth_token(auth_token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_auth_token(%AuthToken{} = auth_token, attrs) do
    auth_token
    |> AuthToken.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AuthToken.

  ## Examples

      iex> delete_auth_token(auth_token)
      {:ok, %AuthToken{}}

      iex> delete_auth_token(auth_token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_auth_token(%AuthToken{} = auth_token) do
    Repo.delete(auth_token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking auth_token changes.

  ## Examples

      iex> change_auth_token(auth_token)
      %Ecto.Changeset{source: %AuthToken{}}

  """
  def change_auth_token(%AuthToken{} = auth_token) do
    AuthToken.changeset(auth_token, %{})
  end
end
