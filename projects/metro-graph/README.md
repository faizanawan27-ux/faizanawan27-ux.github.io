# MetroGraph — k-th Shortest Path Finder

Data Structures & Algorithms Lab project — UET Peshawar, Spring 2024.

Models a metro network as a weighted, undirected graph (adjacency list) and
finds the **k-th shortest path** between two stations by enumerating all
simple paths with DFS and ranking them.

## Features
- `MetroGraph` class with a linked-list adjacency representation.
- `addEdge(u, v, weight)` — bidirectional weighted edges.
- `findPaths(...)` — DFS enumeration of every simple path start → end.
- `findKthShortestPath(start, end, k)` — reports the k-th shortest of those
  paths, with a friendly message if fewer than `k` paths exist.
- Interactive CLI: enter `k` repeatedly to view the 1st, 2nd, 3rd... shortest
  path, or `0` to exit.

## Example
Graph used in `main()`: 6 stations (0-5), edges as shown in `metro_graph.cpp`.
```
Enter the k-th shortest path to display (1 for first, 2 for second, etc.), or 0 to exit: 1
1-th shortest path from 0 to 5:
0 -> 2 -> 4 -> 5
```

## Complexity
- DFS path enumeration: `O(V!)` worst case (explores all simple paths).
- Space for stored paths: `O(V^2)`.

## Build & run
```
g++ -o metro_graph metro_graph.cpp
./metro_graph
```

## Future work
- Replace exhaustive DFS with Yen's algorithm for k-shortest paths at scale.
- Add a GUI to visualize the network and highlight the selected path.

## Author
Faizan — Section B.
