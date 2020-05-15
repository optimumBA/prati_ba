defmodule PratiBa.Release do
  @app :prati_ba

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn(repo) ->
        # Run the seed script if it exists
        seed_script = priv_path_for(repo, "seeds.exs")

        if File.exists?(seed_script) do
          IO.puts("Running seed script..")
          Code.eval_file(seed_script)
        end
      end)
    end
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config(), :otp_app)

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end
end
