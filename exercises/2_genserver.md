# GenServer

## What is a GenServer?
A GenServer is a better abstraction over the stateful process. In the previous section we created a stateful process which would pass around the state recursively. GenServers allow the user to create stateful processes in a better way.

At its core a GenServer is a behaviour (think Java interfaces). To use a bevahiour there are some callback functions that must be implemented, as we will see in the next section.

## Creating a GenServer
You can create a GenServer as follows
```
defmodule GS do
  use GenServer

  def start(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    state = %{initial_args: args}
    {:ok, state}
  end
end
```
This will create a GenServer with the `state = %{initial_args: args}` as the state. The `init` function that we see above is one of the callback function described above. The `@impl true` is just a directive to the compiler that this is a callback function, not a module function.

As you can see here, we can pass in arbitrary arguments that will become part of the state. We can modify that in the `init` function.

Typically all the setup happens inside the `init` function. If the init function fails due, the GenServer process is never booted up.

## Naming a GenServer
### Local Name
```
defmodule GS do
  use GenServer

  def start(args) do
    GenServer.start_link(__MODULE__, args, name: MyGenServer)
  end
end
```

### Global Name
```
defmodule GS do
  use GenServer

  def start(args) do
    GenServer.start_link(__MODULE__, args, name: {:global, MyGenServerGlobal})
  end
end
```

### Name registration via external libraries
```
defmodule GS do
  use GenServer

  def start(args) do
    GenServer.start_link(__MODULE__, args,
	  name: name: {:via, :swarm, MyGenSwarmGenServer})
  end
end
```

## Interacting with GenServer
Interaction with GenServers happen via message passing. To send a message to a GenServer the calling process should know either the name or the pid. 

There are 3 ways to send a message to a GenServer:

### handle_call
This mode of communication is used when the response from GenServer is required.
```
defmodule CounterGenServer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: CounterGenServer)
  end

  @impl true
  def init(args) do
    {:ok, %{counter: 0}}
  end

  def increment() do
    GenServer.call(CounterGenServer, :increment)
  end
  
  @impl true
  def handle_call(:increment, from, state) do 
    # Here :increment is the message that we sent over
	{:reply, :response, state}
  end
end
```


### handle_cast
This mode of communication is used when the response is not required from a GenServer.
```
defmodule CounterGenServer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: CounterGenServer)
  end

  @impl true
  def init(args) do
    {:ok, %{counter: 0}}
  end

  def increment_async() do
    GenServer.call(CounterGenServer, :increment)
  end
  
  @impl true
  def handle_call(:increment, state) do 
    # Here :increment is the message that we sent over
	{:noreply, state}
  end
end
```

### handle_info
This mode has no reply as well. The handle_info callback gets the messages that are sent to a GenServer via the send function which we saw in [Process.md](1_process.md). However it is worth mentioning that the `send` function only works with pids. The name to pid translation needs to be done by the developer before using it.

```
defmodule CounterGenServer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: CounterGenServer)
  end

  @impl true
  def init(args) do
    {:ok, %{counter: 0}}
  end

  def increment_via_send() do
    pid = GenServer.whereis(CounterGenServer)
	send(pid, :increment)
  end

  @impl true
  def handle_info(:increment, state) do 
    # Here :increment is the message that we sent over
	{:noreply, state}
  end
end
```

## Updating state of GenServer
The state of the GenServer is updated in the returned tuple of all handle_call, handle_cast and handle_info callbacks.
To update the state, simply update the state field in the tuple that is being returned.

## Links
- Genserver: [https://hexdocs.pm/elixir/GenServer.html](https://hexdocs.pm/elixir/GenServer.html)
