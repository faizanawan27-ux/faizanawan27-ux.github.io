# Collaborative Text Editor (Sockets + Multithreading)

Operating Systems Lab project — UET Peshawar, Spring 2024.

A real-time collaborative text editor: a multithreaded TCP server accepts up
to `MAX_CLIENTS` clients, and every message a client sends is broadcast to
all other connected clients, so everyone sees the same shared stream in
real time. All activity is timestamped and logged to `collab_editor.txt`.

## Architecture
- **Server** (`run_server`): binds/listens on port 8080, `accept()`s new
  connections and spawns a detached `pthread` per client (`handle_client`).
  Each client's messages are logged (mutex-protected file writes) and
  relayed to every other client via `broadcast_message`.
- **Client** (`run_client`): connects to the server, spawns a background
  thread (`receive_handler`) to print incoming broadcasts, while the main
  thread reads from `stdin` and sends what you type.

## System calls used
`socket()`, `bind()`, `listen()`, `accept()`, `connect()`, `send()`, `recv()`

## Build & run
```
gcc -o collab_editor collab_editor.c -pthread

# terminal 1 — start the server
./collab_editor server

# terminal 2+ — connect clients
./collab_editor client 127.0.0.1
```
Type a line and press Enter to broadcast it to every other connected client.

## Team
Faizan, Anees ur Rehman, Waqas Atta — Section B.
