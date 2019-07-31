defmodule ApiWeb.V1.ResourceController do
  use ApiWeb, :controller

  def create(conn, _params) do
    conn
  end
  
  def save_to_coookie(conn, %{"resource" => resource}) do
    # check for older cookies. Only one cookie at a time! (size limits in header restrict it)
    
    # Want any cookie that ends in _sorin_resource
    old_resources = Enum.filter(
      conn.cookies, fn {k, _v} -> String.contains?(k, "_sorin_resource") end
    )

    encoded_resource = resource
    |> Jason.encode!
    |> Base.encode64(padding: false)
    
    if (length(old_resources) > 0)  do
      # Old cookie is expired. New Cookie is set.
      # JOKE -> SORRY, DAVE. YOUR RESOURCE COULD NOT BE SAVED BECAUSE YOU CAN'T FOCUS FOR MORE THAN 3 SECONDS.
      {key, _data}  = old_resources |> List.first

      conn
      |> delete_resp_cookie(key)
      |> put_resp_cookie(
          resource["identifier"] <> "_sorin_resource", 
          encoded_resource, 
          http_only: false, 
          max_age: 180)
      |> put_status(200)
      |> json(%{msg: "Cookie created"})
    else
      conn
      |> put_resp_cookie(
          resource["identifier"] <> "_sorin_resource", 
          encoded_resource, 
          http_only: false, 
          max_age: 180)
      |> put_status(200)
      |> json(%{msg: "Cookie created"})
    end
  end
end
