defmodule ApiWeb.UserView do
    use ApiWeb, :view
    alias Core.Accounts.User

    def render("user.json", %User{} = user) do
        %{
            fullname: user.fullname,
            email: user.email,
            photo_url: user.photo_url
        }
    end
end
