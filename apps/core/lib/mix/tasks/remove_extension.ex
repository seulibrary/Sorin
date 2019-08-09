defmodule Mix.Tasks.RemoveExtension do
  use Mix.Task
  require Mix.Generator

  @shortdoc "Removes extension files."
  def run(extensions) do
    Enum.map(extensions, fn extension -> 
      frontend_extension_path = "apps/frontend/assets/js/extensions/"

      #  Check to see if directory for extension exists
      if File.exists?(frontend_extension_path <> Macro.underscore(extension)) do
        File.rm_rf!(frontend_extension_path <> Macro.underscore(extension))

        IO.puts(extension <> " removed.")
        IO.puts("Make sure to remove any un-used settings in your sorin.exs file.")
      else
        IO.puts(extension <> " not found.")
      end
    end)
  end
end