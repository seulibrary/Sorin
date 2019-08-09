defmodule Mix.Tasks.SetupExtension do
  use Mix.Task
  require Mix.Generator

  @shortdoc "Copies the javascript from the module being setup into the 
  extensions folder in the front end application. Then calls the same name
  mix task for any addition setup."
  def run(extensions) do
    Enum.map(extensions, fn extension -> 
      frontend_extension_path = "apps/frontend/assets/js/extensions/"

      #  Check to see if directory for extension exists
      if !File.exists?(frontend_extension_path <> Macro.underscore(extension)) do
        File.mkdir!(frontend_extension_path <> Macro.underscore(extension))
      end
      
      if File.exists?(Mix.Project.deps_path() <> "/" <> Macro.underscore(extension) <> "/assets/js/" <> extension <> "/package.json") do
        # Run NPM install to get any deps
        Mix.Shell.Process.cmd("npm install --prefix " <> Mix.Project.deps_path() <> "/" <> Macro.underscore(extension) <> "/assets/js/" <> extension)
        
        IO.puts "npm ran"
      end

      # Run mix task for extension if it exists
      if Mix.Task.get(Macro.underscore(extension)) do
        Mix.Task.run(Macro.underscore(extension))
      end
      
      # Copy files from extension to frontend if js directory exists
      if File.exists?(Mix.Project.deps_path() <> "/" <> Macro.underscore(extension) <> "/assets/js/" <> extension) do
        File.cp_r(Mix.Project.deps_path() <> "/" <> Macro.underscore(extension) <> "/assets/js/" <> extension, frontend_extension_path <> Macro.underscore(extension), fn source, destination ->
        IO.gets("Overwriting #{destination} by #{source}. Type y to confirm. ") == "y\n" end)
      end
    end)

    IO.puts "Extensions are now setup"
  end
end