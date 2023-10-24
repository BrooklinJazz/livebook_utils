defmodule Mix.Tasks.AddNavigationTest do
  use ExUnit.Case
  doctest Mix.Tasks.AddNavigation
  alias Mix.Tasks.AddNavigation
  @notebooks_path Enum.random(["guides", "test_notebooks", "test_folder"])

  setup do
    on_exit(fn ->
      File.rm_rf!(@notebook_path)
    end)
  end

  test "mix add_navigation _ create new navigation" do
    notebook_path = Enum.random(["guides"])
    Application.put_env(:livebook_utils, :index, "#{@notebooks_path}/index.livemd")
    Application.put_env(:livebook_utils, :notebooks_path, @notebooks_path)

    File.mkdir(@notebooks_path)

    index = """
    [Book 1](book1.livemd)
    [Book 2](book2.livemd)
    [Book 3](book3.livemd)
    """

    File.write!("#{@notebooks_path}/index.livemd", index)

    page = """
    # Heading
    ## Sub Heading
    <!-- navigation-start -->
    <!-- navigation-end -->
    """

    File.write!("#{@notebooks_path}/book1.livemd", page)
    File.write!("#{@notebooks_path}/book2.livemd", page)
    File.write!("#{@notebooks_path}/book3.livemd", page)

    AddNavigation.run([])

    book1 = File.read!("#{@notebooks_path}/book1.livemd")
    book2 = File.read!("#{@notebooks_path}/book2.livemd")
    book3 = File.read!("#{@notebooks_path}/book3.livemd")

    refute book1 =~ "book1.livemd"
    refute book1 =~ "Book 1"
    assert book1 =~ "book2.livemd"
    assert book1 =~ "Book 2"
    refute book1 =~ "book3.livemd"
    refute book1 =~ "Book 3"

    assert book2 =~ "book1.livemd"
    assert book2 =~ "Book 1"
    refute book2 =~ "book2.livemd"
    refute book2 =~ "Book 2"
    assert book2 =~ "book3.livemd"
    assert book2 =~ "Book 3"

    refute book3 =~ "book1.livemd"
    refute book3 =~ "Book 1"
    assert book3 =~ "book2.livemd"
    assert book3 =~ "Book 2"
    refute book3 =~ "book3.livemd"
    refute book3 =~ "Book 3"
  end
end
