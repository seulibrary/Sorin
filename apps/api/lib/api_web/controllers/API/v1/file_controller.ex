defmodule ApiWeb.V1.FileController do
    use ApiWeb, :controller
  
    require Logger

    def get_file(conn, %{"id" => id, "user" => user}) do
        case Phoenix.Token.verify(conn, "user_id", user, max_age: 86400) do
            {:ok, user_id} ->
              Logger.info"> User Id: #{user_id}, Download File: #{id}"

              file = Core.Files.get_file_by_uuid(id)
              file_download = Core.Files.download_file_by_uuid(id)

              conn
              |> put_resp_header("x-filename", file.title)
              |> send_download({:binary, file_download}, filename: file.title)
            _ ->
              Logger.error"> ERROR: File not downloaded. User not verified. File: #{id}"

              conn
              |> put_status(400)
              |> json(%{message: "ERROR: User Not Verified"})
        end
    end
end
