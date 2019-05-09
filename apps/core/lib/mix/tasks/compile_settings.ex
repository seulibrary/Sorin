defmodule Mix.Tasks.CompileSettings do
  use Mix.Task
  require Mix.Generator

  @shortdoc "Copies the site settings from sorin.exs into a config.js file for
  the frontend application."
  def run(_args) do
    # Generate config file from sorin.exs file and move it to correct JS folder
    json_config = 
    Application.get_env(:frontend, :settings)
    |> Jason.encode!
    
    # Where the config.json needs to live
    config_path = "apps/frontend/assets/js/utils/"

    File.write!(config_path <> "/config.json", json_config)
    File.close(config_path <> "/config.json")

    IO.puts "Settings Compiled"
  end
end