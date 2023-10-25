defmodule Mix.Tasks.AddNavigationTest do
  use ExUnit.Case
  doctest Mix.Tasks.AddNavigation
  alias Mix.Tasks.AddNavigation

  @test_paths ["guides", "test_notebooks", "test_folder"]
  @notebooks_path Enum.random(@test_paths)

  setup do
    Application.put_env(:livebook_utils, :index, "#{@notebooks_path}/index.livemd")
    Application.put_env(:livebook_utils, :notebooks_path, @notebooks_path)

    on_exit(fn ->
      # notebook created must be deleted
      File.rm_rf!(@notebooks_path)
      # cleanup other test folders if they exist (makes viewing test folder output easier)
      Enum.map(@test_paths, &File.rm/1)
    end)
  end

  test "mix add_navigation _ create new navigation" do
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

    # Ensures navigation contains correct links and titles

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

  test "add_navigation _ update multiple existing navigation" do
    File.mkdir(@notebooks_path)

    index = """
    [Book 1](book1.livemd)
    [Book 2](book2.livemd)
    [Book 3](book3.livemd)
    """

    File.write!("#{@notebooks_path}/index.livemd", index)

    page = """
    # Heading
    <!-- navigation-start -->
      Old Navigation
    <!-- navigation-end -->
    ## Sub Heading
    <!-- navigation-start -->
      Old Navigation
    <!-- navigation-end -->
    """

    File.write!("#{@notebooks_path}/book1.livemd", page)
    File.write!("#{@notebooks_path}/book2.livemd", page)
    File.write!("#{@notebooks_path}/book3.livemd", page)

    AddNavigation.run([])

    book2 = File.read!("#{@notebooks_path}/book2.livemd")

    # Ensures content was not overwritten.
    assert Regex.scan(~r/navigation-(end|start)/, book2) |> Enum.map(&hd/1) == [
             "navigation-start",
             "navigation-end",
             "navigation-start",
             "navigation-end"
           ]

    # Ensures navigation includes correct links and titles
    assert book2 =~ "book1.livemd"
    assert book2 =~ "Book 1"
    refute book2 =~ "book2.livemd"
    refute book2 =~ "Book 2"
    assert book2 =~ "book3.livemd"
    assert book2 =~ "Book 3"
  end

  test "add_navigation _ ignore notebooks without path or title" do
    File.mkdir(@notebooks_path)

    index = """
    [Book 1](book1.livemd)
    [Book 2]()
    [Book 3](book3.livemd)
    [](book4.livemd)
    [Book 5](book5.livemd)
    """

    File.write!("#{@notebooks_path}/index.livemd", index)

    page = """
    <!-- navigation-start -->
    <!-- navigation-end -->
    """

    File.write!("#{@notebooks_path}/book1.livemd", page)
    File.write!("#{@notebooks_path}/book2.livemd", page)
    File.write!("#{@notebooks_path}/book3.livemd", page)
    File.write!("#{@notebooks_path}/book4.livemd", page)
    File.write!("#{@notebooks_path}/book5.livemd", page)

    AddNavigation.run([])

    book3 = File.read!("#{@notebooks_path}/book3.livemd")

    # Ignore notebooks without path or title
    assert book3 =~ "book1.livemd"
    assert book3 =~ "Book 1"
    refute book3 =~ "book2.livemd"
    refute book3 =~ "Book 2"
    refute book3 =~ "book3.livemd"
    refute book3 =~ "Book 3"
    refute book3 =~ "book4.livemd"
    refute book3 =~ "Book 4"
    assert book3 =~ "book5.livemd"
    assert book3 =~ "Book 5"
  end
end
