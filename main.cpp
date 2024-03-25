#include <cstdlib>

#include <iostream>
#include <string>
#include <vector>
#include <numeric>
#include <bitset>
#include <utility>

template <typename T>
struct Min_max {
  T min{};
  T max{};
};

class Error : public std::runtime_error {
  using std::runtime_error::runtime_error;
};

template <typename T>
std::vector<T> series(T number, Min_max<unsigned int> number_of_steps) {
  std::vector<T> result{};

  bool valid_series{false};

  unsigned int step_number{(rand() % (number_of_steps.max - number_of_steps.min)) + number_of_steps.min};

  for (unsigned int i{0}; i < step_number - 1; ++i) {
    result.push_back(rand());
  }

  result.push_back(number - std::accumulate(result.begin(), result.end(), 0));

  return result;
}

void print_help() {
  std::cout << "help: program <number> <min_number_of_steps> <max_number_of_steps>" << std::endl;
}

std::pair<int, Min_max<unsigned int>> handle_args(int argc, char **argv) {
  if (argc != 4) {
    print_help();
    throw Error{"ERROR. Not enough arguments."};
  }

  int number{};

  try {
    number = std::stoi(argv[1]);
  }
  catch (...) {
    throw Error{"Failed to retrieve the argument <number>."};
  }

  Min_max<unsigned int> number_of_steps{};

  try {
    number_of_steps.min = std::stoul(argv[2]);
  }
  catch (...) {
    throw Error{"Failed to retrieve the argument <min_number_of_steps>."};
  }

  try {
    number_of_steps.max = std::stoul(argv[3]);
  }
  catch (...) {
    throw Error{"Failed to retrieve the argument <max_number_of_steps>."};
  }

  return {number, number_of_steps};
}

int main(int argc, char **argv) {
 auto [number, number_of_steps] = handle_args(argc, argv);

  srand(0);

  auto result = series<int>(number, number_of_steps);

  for (auto &el : result) {

    enum class Format {
      hex,
      oct,
      bin,
      dec,
    };

    std::string prefix{"32'"};

    switch (static_cast<Format>(rand() % 2)) {
      case Format::hex: std::cout << prefix << "h" << std::hex << el << ' '; break;
      case Format::oct: std::cout << prefix << "o" << std::oct << el << ' '; break;
      case Format::bin: {
        std::bitset<32> bits{static_cast<unsigned int>(el)};
        std::cout << prefix << "b" << bits << ' ';
      } break;
      case Format::dec: std::cout << prefix << "d" << std::dec << el << ' '; break;
    }
  }

  return 0;
}
