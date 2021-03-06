# RubyChessEngine

## Play the engine
Clone the repo on your local machine and run

```
ruby ./lib/game.rb
```
## Background

A chess engine is an AI program for the game of chess. The best chess engines have outclassed the best human chess players at least since Deep Blue defeated Garry Kasparov in 1997. My goal is somewhat less lofty: to create a chess engine that is at least as good as myself. The techniques and algorithms for building chess engines are well-documented, so this project also constitutes an exploration into some pithy computer science content relating to search algorithms and data structures.

## Technologies and technical challenges

### Board representation and move generation
A chess engine requires a bug-free representation of the game state, with all the rules of chess included. This engine uses an object-oriented, grid-based board representation---that is, we store a board object which contains an 8x8 grid of pieces as well as the ancillary board data.

Generating possible moves from a position is an important function of the chess engine. Most chess engines today no longer use selective pruning---rather, they generate all possible moves from a position and evaluate each one. The search algorithm works best if we can order the generated moves so that the best move comes first, and certain moves are likely to be "killer moves" in a position: checks, captures, and moves that were played before in the same position.

### Search algorithm

The goal of a search algorithm in a chess engine is to maximize the "value" of the board for one player, while assuming that the other player is trying to minimize it. This is called a "minimax" algorithm, and a pseudocode for it (see [here](https://en.wikipedia.org/wiki/Minimax) looks like this:
```
01 function minimax(node, depth, maximizingPlayer)
02     if depth = 0 or node is a terminal node
03         return the heuristic value of node

04     if maximizingPlayer
05         bestValue := −∞
06         for each child of node
07             v := minimax(child, depth − 1, FALSE)
08             bestValue := max(bestValue, v)
09         return bestValue

10     else    (* minimizing player *)
11         bestValue := +∞
12         for each child of node
13             v := minimax(child, depth − 1, TRUE)
14             bestValue := min(bestValue, v)
15         return bestValue
```


Improvements on this algorithm can be made by introducing alpha-beta pruning: that is, if we are exploring a subtree of moves and find that some move by the opponent forces a worse position than the best outcome we have seen so far, then there is no need to look at other moves by the opponent. Pseudocode for the [alpha-beta search](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning) is below:


```
01 function alphabeta(node, depth, α, β, maximizingPlayer)
02      if depth = 0 or node is a terminal node
03          return the heuristic value of node
04      if maximizingPlayer
05          v := -∞
06          for each child of node
07              v := max(v, alphabeta(child, depth - 1, α, β, FALSE))
08              α := max(α, v)
09              if β ≤ α
10                  break (* β cut-off *)
11          return v
12      else
13          v := ∞
14          for each child of node
15              v := min(v, alphabeta(child, depth - 1, α, β, TRUE))
16              β := min(β, v)
17              if β ≤ α
18                  break (* α cut-off *)
19          return v
```
Once the search function has evaluated a position, we can cache the result in a transposition hash table so that if the same position is encountered again in another search, we don't have to re-evaluate it. This table is also used for ordering moves in move generation, as well as for checking if the game is a draw by threefold repetition.

### Board evaluation

We also need to have some way of guessing whether a position is good or bad for the player without actually searching the board. This is the thing our search algorithm is maximizing: the evaluation function. A simple evaluation function will suffice for a basic engine. It takes into account the balance in material as well as piece mobility (number of available moves).
