[![Hex.pm](https://img.shields.io/hexpm/v/livebook_utils.svg)](https://hex.pm/packages/livebook_utils) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/livebook_utils/0.1.0/readme.html)

# LivebookUtils

LivebookUtils is an experimental collection of utility tasks and modules that make managing a complex Livebook project easier.

We use this library at [DockYard Academy](https://github.com/DockYard-Academy/curriculum) and [LiveView Native Guides](https://github.com/BrooklinJazz/liveview_native_guides) and are in between migrating tasks and modules from those projects into this project.

## Installation

Add the dependency to your project's mix path.

```elixir
def deps do
  [
    {:livebook_utils, "~> 0.1.0"}
  ]
end
```

Configure project environment variables in your `dev.exs` file. 

* `:index_path` the path to the index file that contains links to all project notebooks in order.
* `"notebooks_path` the path to the folder that contains all project notebooks. Currently, we only support one flat folder, but hope to support multiple folders in the future.

```elixir
# Livebook Utils Configuration
config :livebook_utils,
  index_path: "guides/index.livemd",
  notebooks_path: "guides"
```

## Index

`LivebookUtils` assumes you have an index file. This file should contain links to all of your notebooks in chronological order.

For example

```md
* [Book 1](book1.livemd)
* [Book 2](book2.livemd)
* [Book 3](book3.livemd)
```

These links may be in any format or order as long as they match the regular expression we use to find links.