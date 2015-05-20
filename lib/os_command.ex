defmodule OsCommand do

    @moduledoc """
        This library is supposed to be a thin layer to
        run OS Commands and deal with their events.
    """

    @doc """
        Run a given command in the background.
    """
    def execute(command) when is_list(command) do
        spawn_link(fn -> 
            run(command)
        end)
        # Explicitly not returning the PID of spawned process.
        nil
    end

    @doc """
        Run given command and handle its events with given callback.

        The callback has to be a fun/1.
        The first argument given to the callback will always be a tuple.
    """
    def execute(command, callback) when is_list(command) and is_function(callback) do
        spawn_link(fn -> 
            port_id = run(command)
            handler(port_id, callback)
        end)
        # Explicitly not returning the PID of spawned process.
        nil
    end

    # Spawn a command and return the PortId.
    defp run(command) do
        Port.open({:spawn, command}, [:stderr_to_stdout, :exit_status, {:line, 4096}])
    end

    # Wait for events from the port, and handle them.
    defp handler(port_id, callback) do
        # Only handle messages from port.
        receive do
            {^port_id, data}
                ->  handle(data, callback)
                    # Stop if we get a exit status.
                    case data do
                        {:exit_status, _}   -> nil          # We can stop now
                        _   -> handler(port_id, callback)   # Proceed
                    end
        end
    end

    # Transform a line to a more handy tuple.
    defp handle({:data, {:eol, line}}, callback)  do
        callback.({:line, line})
    end

    # Process has ended
    defp handle({:exit_status, exit_code}, callback)  do
        callback.({:exit_status, exit_code})
    end
end
