defmodule OsCommandTest do
  use ExUnit.Case

  test "run true wihtout callback" do
    File.rm("foo")
    OsCommand.execute('touch foo')
    :timer.sleep(100)
    assert File.exists?("foo")
    File.rm("foo")
  end

  test "run true" do
  	pid = self()
	  OsCommand.execute('true', fn data -> send(pid, data) end)
	  assert_receive {:exit_status, 0}
  end

  test "run false" do
  	pid = self()
	  OsCommand.execute('false', fn data -> send(pid, data) end)
	  assert_receive {:exit_status, 1}
  end

  test "echo single line" do
  	pid = self()
	  OsCommand.execute('echo "foo"', fn data -> send(pid, data) end)
	  assert_receive {:line, 'foo'}
	  assert_receive {:exit_status, 0}
  end

  test "echo three lines" do
  	pid = self()
	  OsCommand.execute('echo -e "foo\nbar\nbaz"', fn data -> send(pid, data) end)
  	assert_receive {:line, 'foo'}
  	assert_receive {:line, 'bar'}
  	assert_receive {:line, 'baz'}
  	assert_receive {:exit_status, 0}
  end

end
