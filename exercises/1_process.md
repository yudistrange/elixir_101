x = spawn(fn -> IO.puts("hello") end)
# Process
## What's a process?
All code in Elixir is executed inside a process. They are akin to threads, but much light weight than the OS threads. There can be a million concurrent processes running on the same machine without any hiccups.

All processes are isolated from each other and the only mode of communication is message passing

## Creating a process

### spawn
Erlang and Elixir both have a built-in function called `spawn` that can spawn off a new process. It can be used as follows:

```
pid = spawn(fn -> 
  :timer.sleep(5000)
  IO.puts("Wake up now"!)
end)
```

This example will create a process which will print on the console after 5 seconds. The return value of the spawn function is the pid (process id) of the newly created process. We will see in the following sections on how we can leverage that for inter process communication.

Another thing worth noting is that after executing the print, since the process doesn't have any other operations, it will be cleaned up.

### Task
Task is another way to create processes that is exclusive to Elixir.

```
{:ok, pid} = Task.start(fn -> 
  :timer.sleep(5000)
  IO.puts("Task accomplished")
end)
```

The [Task](https://hexdocs.pm/elixir/master/Task.html) module comes with lots of bells and whistles. It's worthwhile going through it. For instance Task supports `async-await` type concurrency, wherein you can await the result of a `Task`.

## Naming a process
In the previous section we saw that the `spawn` function and the `Task` module return back pid of the created process. This pid is typically of the form `#PID<0.112.0>` which is not very readable. 
Elixir provides with name registries which can give the pid a meaningful name.

### :global
:global is a registry that's provided by the erlang runtime. Herein processes can be registered against a name. 
```
x = spawn(fn ->
  :timer.sleep(10000)
  "something"
end

:global.register_name(:something, x)

pid = :global.whereis_name(:something)
```
Note: If the elixir application is running in a clustered mode, the :global name registrations are unique across the cluster

### Registry
The [Registry](https://hexdocs.pm/elixir/master/Registry.html) is an Elixir module that provides name registrations. The advantage of `Registry` over `:global` is the ability to attach multiple pids to the same name. Thus `Registry` can be leveraged to handroll a pub-sub where in all the subsribers are registered under a name

```
Registry.start_link(keys: :unique, name: Registry.Unique)
# This will start a registry with name Registry.Unique that will not allow multiple processes per name

Registry.start_link(keys: :duplicate, name: Registry.PubSub)
# This will start a registry with name Registry.PubSub that will allow for pub-sub described above
```
Note: We can create multiple registries with different names and registration formats. This is not possible with `:global`. However on the downside, `Registry` are local to the elixir node. Thus if a service is running in a clustered mode, each node will have it's own set of Registries.

## Interacting with processes
In the previous section we saw how the `spawn` function and the `Task` module return back a pid whenever a new process is created. This pid can be used for sending messages for to the newly created process.

```
x = spawn(fn -> IO.puts("hello") end)
send(x, :something)
```

## Creating a long running process
In the previous section we learnt how to create a process which will perform some work and terminate. But what if we want to create long running processes which does not exit after execution. We can create a process that has a receive block. Such a process will keep listening to incoming messages to it and never die (unless there is an exception in the execution flow or if the process is sent a :kill message)

```
# This needs to go in a module
def process() do
  receive do
    :exit ->
	  IO.puts("Exiting..")
    x ->
      IO.puts(x)
   	  process()

x = spawn(process)
send(x, "hello")
send(x, :kill)
```

## Stateful processes
In the previous section we saw that to create a long running process, it needs to get into a receive block that recursively calls itself. We can leverage the recursive calls to pass around state to the next iteration of the process, hence making it stateful in some sense

```
def process(counter) do
  receive do
    :exit ->
	  IO.puts("Exiting... Final Counter: #{counter}")
    :increment ->
      IO.puts(x)
   	  process(x + 1)
	:decrement ->
	  IO.puts(x)
	  process(x - 1)
	otherwise ->
	  IO.puts(otherwise)
	  process(x)

x = spawn(process)
send(x, "hello")
send(x, :increment)
send(x, :decrement)
```

## Links
1. Processes: [https://elixir-lang.org/getting-started/processes.html]()
2. Task: [https://hexdocs.pm/elixir/master/Task.html](https://hexdocs.pm/elixir/master/Task.html)
3. Registry: [https://hexdocs.pm/elixir/master/Registry.html](https://hexdocs.pm/elixir/master/Registry.html)
