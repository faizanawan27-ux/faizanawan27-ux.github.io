#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <time.h>

#define PORT 8080
#define MAX_CLIENTS 10
#define BUFFER_SIZE 1024

typedef struct {
    int socket;
    struct sockaddr_in address;
} client_t;

client_t *clients[MAX_CLIENTS];
pthread_mutex_t clients_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t file_mutex = PTHREAD_MUTEX_INITIALIZER;
FILE *log_file;

char* current_time_str() {
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    static char time_str[20];
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", t);
    return time_str;
}

void broadcast_message(char *message, int sender_socket) {
    pthread_mutex_lock(&clients_mutex);
    for (int i = 0; i < MAX_CLIENTS; ++i) {
        if (clients[i]) {
            if (clients[i]->socket != sender_socket) {
                if (send(clients[i]->socket, message, strlen(message), 0) < 0) {
                    perror("ERROR: send to client");
                    close(clients[i]->socket);
                    free(clients[i]);
                    clients[i] = NULL;
                }
            }
        }
    }
    pthread_mutex_unlock(&clients_mutex);
}

void *handle_client(void *arg) {
    char buffer[BUFFER_SIZE];
    int n;
    client_t *cli = (client_t *)arg;

    printf("Client connected: %d\n", cli->socket);

    while ((n = recv(cli->socket, buffer, sizeof(buffer), 0)) > 0) {
        buffer[n] = '\0';
        printf("Received from client %d: %s", cli->socket, buffer);

        // Write the message to the log file
        pthread_mutex_lock(&file_mutex);
        fprintf(log_file, "[%s] Client %d: %s\n", current_time_str(), cli->socket, buffer);
        fflush(log_file);
        pthread_mutex_unlock(&file_mutex);

        broadcast_message(buffer, cli->socket);
    }

    close(cli->socket);
    pthread_mutex_lock(&clients_mutex);
    for (int i = 0; i < MAX_CLIENTS; ++i) {
        if (clients[i] && clients[i]->socket == cli->socket) {
            clients[i] = NULL;
            break;
        }
    }
    pthread_mutex_unlock(&clients_mutex);
    free(cli);
    pthread_detach(pthread_self());
    printf("Client disconnected: %d\n", cli->socket);
    return NULL;
}

void run_server() {
    int server_socket, new_socket;
    struct sockaddr_in server_addr, new_addr;
    socklen_t addr_size;
    pthread_t tid;

    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        perror("ERROR: Socket creation failed");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    if (bind(server_socket, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("ERROR: Socket binding failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_socket, 10) < 0) {
        perror("ERROR: Socket listening failed");
        exit(EXIT_FAILURE);
    }

    // Open the log file for writing
    log_file = fopen("collab_editor.txt", "a");
    if (!log_file) {
        perror("ERROR: Could not open log file");
        exit(EXIT_FAILURE);
    }

    printf("=== Collaborative Text Editor Server ===\n");

    while (1) {
        addr_size = sizeof(new_addr);
        new_socket = accept(server_socket, (struct sockaddr*)&new_addr, &addr_size);

        if (new_socket < 0) {
            perror("ERROR: Client connection failed");
            exit(EXIT_FAILURE);
        }

        pthread_mutex_lock(&clients_mutex);
        for (int i = 0; i < MAX_CLIENTS; ++i) {
            if (!clients[i]) {
                clients[i] = (client_t *)malloc(sizeof(client_t));
                clients[i]->socket = new_socket;
                clients[i]->address = new_addr;
                pthread_create(&tid, NULL, handle_client, (void*)clients[i]);
                break;
            }
        }
        pthread_mutex_unlock(&clients_mutex);
    }

    // Close the log file
    fclose(log_file);
    close(server_socket);
}

void *receive_handler(void *sockfd) {
    int sock = *((int *)sockfd);
    char message[BUFFER_SIZE];
    int length;

    while ((length = recv(sock, message, sizeof(message), 0)) > 0) {
        message[length] = '\0';
        printf("%s", message);
    }

    if (length == 0) {
        printf("Server disconnected.\n");
    } else if (length == -1) {
        perror("recv failed");
    }

    close(sock);
    pthread_exit(NULL);
    return NULL;
}

void run_client(const char *server_ip) {
    int sockfd;
    struct sockaddr_in server_addr;
    pthread_t recv_thread;
    char message[BUFFER_SIZE];

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        perror("ERROR: Socket creation failed");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(server_ip);
    server_addr.sin_port = htons(PORT);

    if (connect(sockfd, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("ERROR: Connection to server failed");
        exit(EXIT_FAILURE);
    }

    printf("=== Connected to the Collaborative Text Editor ===\n");

    pthread_create(&recv_thread, NULL, receive_handler, (void*)&sockfd);

    while (1) {
        fgets(message, BUFFER_SIZE, stdin);
        if (send(sockfd, message, strlen(message), 0) < 0) {
            perror("ERROR: send message");
            exit(EXIT_FAILURE);
        }
    }

    pthread_join(recv_thread, NULL);
    close(sockfd);
}

int main(int argc, char *argv[]) {
    if (argc != 2 && argc != 3) {
        fprintf(stderr, "Usage: %s <server|client> [server_ip]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    if (strcmp(argv[1], "server") == 0) {
        run_server();
    } else if (strcmp(argv[1], "client") == 0) {
        if (argc != 3) {
            fprintf(stderr, "Usage: %s client <server_ip>\n", argv[0]);
            exit(EXIT_FAILURE);
        }
        run_client(argv[2]);
    } else {
        fprintf(stderr, "Invalid mode: %s\n", argv[1]);
        fprintf(stderr, "Usage: %s <server|client> [server_ip]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    return 0;
}
