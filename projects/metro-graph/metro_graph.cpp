#include <iostream>
#include <climits>
#include <cstring>

using namespace std;

const int MAX_STATIONS = 100; // maximum number of stations

struct Edge {
    int to;
    int weight;
    Edge* next;
};

struct Station {
    Edge* head;
};

class MetroGraph {
    int numStations;
    Station stations[MAX_STATIONS];

public:
    MetroGraph(int stations) : numStations(stations) {
        for (int i = 0; i < MAX_STATIONS; ++i) {
            this->stations[i].head = NULL;
        }
    }

    void addEdge(int u, int v, int weight) {
        Edge* newEdge = new Edge{v, weight, stations[u].head};
        stations[u].head = newEdge;

        newEdge = new Edge{u, weight, stations[v].head};
        stations[v].head = newEdge;
    }

    void findPaths(int start, int end, int path[], bool visited[], int& pathIndex, int k, int& k_count, int allPaths[][MAX_STATIONS], int pathLengths[]) {
        visited[start] = true;
        path[pathIndex++] = start;

        if (start == end) {
            // If this is the k-th shortest path, store it
            memcpy(allPaths[k_count], path, pathIndex * sizeof(int));
            pathLengths[k_count] = pathIndex;
            k_count++;
        } else {
            for (Edge* edge = stations[start].head; edge != NULL; edge = edge->next) {
                int v = edge->to;
                if (!visited[v]) {
                    findPaths(v, end, path, visited, pathIndex, k, k_count, allPaths, pathLengths);
                }
            }
        }

        // Backtrack
        pathIndex--;
        visited[start] = false;
    }

    void printKthPath(int allPaths[][MAX_STATIONS], int pathLengths[], int k) {
        for (int i = 0; i < pathLengths[k-1]; ++i) {
            cout << allPaths[k-1][i];
            if (i < pathLengths[k-1] - 1)
                cout << " -> ";
        }
        cout << endl;
    }

    void findKthShortestPath(int start, int end, int k) {
        // Find all paths
        int allPaths[MAX_STATIONS][MAX_STATIONS];
        int pathLengths[MAX_STATIONS] = {0};
        int path[MAX_STATIONS];
        bool visitedPaths[MAX_STATIONS];
        memset(visitedPaths, false, sizeof(visitedPaths));
        int pathIndex = 0;
        int k_count = 0;

        findPaths(start, end, path, visitedPaths, pathIndex, k, k_count, allPaths, pathLengths);

        // Check if there are at least k paths
        if (k_count < k) {
            cout << "There are fewer than " << k << " paths available.\n";
            return;
        }

        cout << "\n" << k << "-th shortest path from " << start << " to " << end << ":\n";
        printKthPath(allPaths, pathLengths, k);
    }

    int findMinDistance(int distances[], bool visited[]) {
        int min = INT_MAX, minIndex = -1;

        for (int i = 0; i < numStations; ++i) {
            if (!visited[i] && distances[i] <= min) {
                min = distances[i];
                minIndex = i;
            }
        }
        return minIndex;
    }
};

int main() {
    int numStations = 6;
    MetroGraph mg(numStations);

    mg.addEdge(0, 1, 4);
    mg.addEdge(0, 2, 2);
    mg.addEdge(1, 2, 5);
    mg.addEdge(1, 3, 10);
    mg.addEdge(2, 4, 3);
    mg.addEdge(4, 3, 4);
    mg.addEdge(3, 5, 11);
    mg.addEdge(4, 5, 8);

    int start = 0;
    int end = 5;

    int choice;
    do {
        cout << "\nEnter the k-th shortest path to display (1 for first, 2 for second, etc.), or 0 to exit: ";
        cin >> choice;

        if (choice > 0) {
            mg.findKthShortestPath(start, end, choice);
        } else if (choice < 0) {
            cout << "Invalid choice. Please enter a valid option.\n";
        }

    } while (choice != 0);

    return 0;
}
