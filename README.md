# GoFish - Elixir Implementation

A card game with multiple players.

Rules:
https://en.wikipedia.org/wiki/Go_Fish

variation:
- Instead of going round in a circle the turn switches to the person saying go fish.

## Notes for upcoming blog post.

Learnings:
- First implemented a version using raw processes with the `receive` and `send` functions. But it was cumbersome to implement synchronous messages and keeping state.
- We switched to using GenServer since it provided a good structure.
- We made sure the public API of each module always was functions, such that no process was sending messages directly to another process. Since this will be brittle, when the internal implementation changes.
- We tested the GenServers with ExUnit. First we used `start_link` in `setup` and `stop` in `on_exit`, but we found that not all processes had been terminated, before the next test started, and so we had to add sleep timers. A bit later we found that we could avoid this by using the inbuilt `start_supervised!` instead of `start_link` in the `setup` block for the tests. Then we could remove the sleep timers and our tests ran much faster.
- We added a supervisor application with the strategy one-to-one to recover from failure when a process failed.
- The tests started failing, because it was automatically starting the supervisor application before running the tests, and we would get the error that a process with the same name had already been registered. To avoid this in your tests you need to use `mix test --no-start` to avoid the application starting polluting the tests. To do this every time a test is run, you can add an alias in your `mix.exs` file as such `aliases: [test: "test --no-start"]`.

## References
Inspired by this tutorial https://www.youtube.com/watch?v=OG7e5SidbCU