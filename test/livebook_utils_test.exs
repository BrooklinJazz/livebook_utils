defmodule LivebookUtilsTest do
  use ExUnit.Case
  doctest LivebookUtils

  setup do
    Application.put_env(:livebook_utils, :outline_path)
  end
end
