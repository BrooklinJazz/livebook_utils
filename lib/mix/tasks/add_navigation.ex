defmodule Mix.Tasks.AddNavigation do
  use Mix.Task
  require Logger

  @readme_path "README.md"
  @ignored_sections ["## Prerequisites"]

  def run(_args) do
    Logger.info("Adding Navigation")
    index_path = Application.get_env(:livebook_utils, :index)
    notebooks_path = Application.get_env(:livebook_utils, :notebooks_path)
    index = File.read!(index_path)

    notebooks =
      Regex.scan(~r/\[(.*)\]\((.*)\)/, index)
      |> Enum.map(fn [_, title, path] -> %{path: path, title: title} end)

    List.flatten([nil, notebooks])
    |> Enum.chunk_every(3, 1, [nil])
    |> Enum.map(fn
      [prev, current, next] = vals ->
        file = File.read!(Path.join(notebooks_path, current.path))

        file_with_nav =
          Regex.replace(
            ~r/<!-- navigation-start -->(?:.|\n)*<!-- navigation-end -->/,
            file,
            nav_snippet(prev, current, next)
          )

        File.write!("#{notebooks_path}/#{current.path}", file_with_nav)
    end)
  end

  def nav_snippet(prev, _, next) do
    """
    <!-- navigation-start -->
    ## Navigation

    <div style="display: flex; align-items: center; width: 100%; justify-content: space-between; font-size: 1rem; color: #61758a; background-color: #f0f5f9; height: 4rem; padding: 0 1rem; border-radius: 1rem;">#{if prev, do: prev_snippet(prev)}#{if next, do: next_snippet(next)}</div>
    <!-- navigation-end -->
    """
  end

  defp prev_snippet(prev) do
    """
    <div style="display: flex; margin-right: auto;">
    <i class="ri-arrow-left-fill"></i>
    <a style="display: flex; color: #61758a; margin-left: 1rem;" href="#{prev[:path]}">#{prev[:title]}</a>
    </div>
    """
    |> String.trim()
  end

  defp next_snippet(next) do
    """
    <div style="display: flex; margin-left: auto;">
    <a style="display: flex; color: #61758a; margin-right: 1rem;" href="#{next[:path]}">#{next[:title]}</a>
    <i class="ri-arrow-right-fill"></i>
    </div>
    """
    |> String.trim()
  end
end
