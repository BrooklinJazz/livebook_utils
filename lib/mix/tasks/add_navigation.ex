defmodule Mix.Tasks.AddNavigation do
  @doc """
  Run the `mix add_navigation` task to automatically add navigation.

  Sections for navigation should be included in the notebook using the following comments:

  ```md
  <!-- navigation-start -->
  <!-- navigation-end -->
  ```

  This way, `livebook_utils` can update your navigation whenever your index file changes. You also have control over where navigation goes.
  Typically, we recommend putting a navigation section at the top and the bottom of the file.

  Here's an example template livebook file with navigation at the top and bottom of the file.

  ```md
  # Title
  <!-- navigation-start -->
  <!-- navigation-end -->

  ## Subtitle

  <!-- navigation-start -->
  <!-- navigation-end -->

  You must have two or more notebooks in your index file with valid paths and titles to add navigation.
  ```
  """
  use Mix.Task
  require Logger

  def run(_args) do
    Logger.info("Adding Navigation")
    index_path = Application.get_env(:livebook_utils, :index_path)
    notebooks_path = Application.get_env(:livebook_utils, :notebooks_path)
    index = File.read!(index_path)
    notebooks = get_notebooks(index, notebooks_path)

    if Enum.count(notebooks) <= 1 do
      raise "Cannot add navigation with one or fewer books"
    else
      write_navigation_sections!(notebooks, notebooks_path)
    end
  end

  defp get_notebooks(index, notebooks_path) do
    Regex.scan(~r/\[(.*)\]\((.*)\)/, index)
    |> Enum.map(fn [_, title, path] -> %{path: path, title: title} end)
    |> Enum.filter(fn %{path: path, title: title} ->
      String.contains?(path, ".livemd") and File.exists?(Path.join(notebooks_path, path)) and
        title != ""
    end)
  end

  defp write_navigation_sections!(notebooks, notebooks_path) do
    List.flatten([nil, notebooks])
    |> Enum.chunk_every(3, 1, [nil])
    |> Enum.map(fn
      [prev, current, next] ->
        file = File.read!(Path.join(notebooks_path, current.path))

        file_with_nav =
          Regex.replace(
            ~r/<!-- navigation-start -->(?:.|\n)*?<!-- navigation-end -->/,
            file,
            nav_snippet(prev, current, next)
          )

        File.write!("#{notebooks_path}/#{current.path}", file_with_nav)
    end)
  end

  defp nav_snippet(prev, _, next) do
    """
    <!-- navigation-start -->
    ## Navigation

    <div style="display: flex; align-items: center; width: 100%; justify-content: space-between; font-size: 1rem; color: #61758a; background-color: #f0f5f9; height: 4rem; padding: 0 1rem; border-radius: 1rem;">
    #{if prev, do: prev_snippet(prev)}
    #{if next, do: next_snippet(next)}
    </div>
    <!-- navigation-end -->
    """
  end

  defp next_snippet(next) do
    """
    <div style="display: flex; margin-left: auto;">
    <a style="display: flex; color: #61758a; margin-right: 1rem;" href="#{next[:path]}">#{next[:title]}</a>
    <i class="ri-arrow-right-fill"></i>
    </div>
    """
  end

  defp prev_snippet(prev) do
    """
    <div style="display: flex; margin-right: auto;">
    <i class="ri-arrow-left-fill"></i>
    <a style="display: flex; color: #61758a; margin-left: 1rem;" href="#{prev[:path]}">#{prev[:title]}</a>
    </div>
    """
  end
end
