# GoFish - Elixir Implementation

A card game with multiple players.

Rules:
- Five cards are dealt from a standard 52-card deck to each player, or seven cards if there are only two players. The remaining cards are shared between the players, usually spread out in a disorderly pile referred to as the "ocean."
- The player whose turn it is to play asks another player for their cards of a particular face value. For example, Alice may ask, "Bob, do you have any threes?" Alice must have at least one card of the rank she requested. Bob must hand over all cards of that rank if possible and is responsible for delivering the cards to the player no matter their location. If he has none, Bob tells Alice to "go fish," and Alice draws a card from the pool and places it in her own hand. Then it is Bob's turn, since the turn switches to the person saying "go fish." When any player at any time has four cards of one face value, it forms a book, and the cards must be placed face up in front of that player. When all sets of cards have been laid down in books, the game ends. The player with the most books wins.


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
