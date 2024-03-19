#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

using namespace std;

bool canPlaceShip(int x, int y, int width, int height, vector<vector<bool>>& grid) {
    if (x < 0 || y < 0 || x + width > 10 || y + height > 10)
        return false;

    for (int i = x - 1; i < x + width + 1; ++i) {
        for (int j = y - 1; j < y + height + 1; ++j) {
            if (i >= 0 && j >= 0 && i < 10 && j < 10 && grid[i][j])
                return false;
        }
    }
    return true;
}

void placeShip(int x, int y, int width, int height, vector<vector<bool>>& grid) {
    for (int i = x; i < x + width; ++i) {
        for (int j = y; j < y + height; ++j) {
            grid[i][j] = true;
        }
    }
}

vector<pair<int, int>> coordinatesToPlace(int x, int y, int width, int height, vector<vector<bool>>& grid) {
    if (canPlaceShip(x, y, width, height, grid)) {
        placeShip(x, y, width, height, grid);
        vector<pair<int, int>> coordinates;
        for (int i = x; i < x + width; ++i) {
            for (int j = y; j < y + height; ++j) {
                coordinates.push_back({ i, j });
            }
        }
        return coordinates;
    }

    return vector<pair<int, int>>(0);
}

vector<vector<pair<int, int>>> placeShips(const vector<pair<int, int>>& ships) {
    vector<vector<bool>> grid(10, vector<bool>(10, false));
    vector<vector<pair<int, int>>> result;

    for (const auto& ship : ships) {
        int width = ship.first;
        int height = ship.second;
        bool placed = false;

        for (int attempt = 0; attempt < 100; ++attempt) {
            int x = rand() % 10;
            int y = rand() % 10;

            vector<pair<int, int>> coordinates = coordinatesToPlace(x, y, width, height, grid);
            if (coordinates.size() == 0) {
                swap(width, height);
                vector<pair<int, int>> coordinates = coordinatesToPlace(x, y, width, height, grid);
                if (coordinates.size() != 0) {
                    placed = true;
                    result.push_back(coordinates);
                    break;
                }
            } else {
                placed = true;
                result.push_back(coordinates);
                break;
            }
        }

        if (!placed) {
            result.clear();
            break;
        }
    }

    cout << "Grid:" << endl;
    for (const auto& row : grid) {
        for (const auto& cell : row) {
            cout << (cell ? "1 " : "0 ");
        }
        cout << endl;
    }

    return result;
}

int main() {
    srand(time(nullptr));

    vector<pair<int, int>> ships = { {1, 1}, {2, 1}, {2, 1}, {4, 2}, {3, 2}, {2, 2}, {3, 2}, {5, 1}, {3, 1}, {1, 3} };

    vector<vector<pair<int, int>>> shipCoordinates = placeShips(ships);

    if (shipCoordinates.empty()) {
        cout << "Unable to place ships on the board." << endl;
    }
    else {
        cout << "Ship Coordinates:" << endl;
        for (const auto& ship : shipCoordinates) {
            cout << "[";
            for (const auto& coord : ship) {
                cout << "(" << coord.first << ", " << coord.second << ") ";
            }
            cout << "]" << endl;
        }
    }

    return 0;
}