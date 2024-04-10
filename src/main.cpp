#include "errors.hpp"

#include <cstdlib>
#include <cassert>

#include <compare>
#include <iostream>
#include <string>
#include <vector>
#include <numeric>
#include <utility>
#include <bitset>
#include <map>
#include <functional>
#include <string_view>
#include <span>
#include <random>

using std::to_string;
template <typename T> requires std::three_way_comparable<T> && requires (T t) {to_string(t);}
struct Min_max {
  constexpr Min_max &set_max(T value) {
    m_max = value;
    return *this;
  }

  constexpr Min_max &set_min(T value) {
    m_min = value;
    return *this;
  }

  constexpr T get_min() const {
    check_range();
    return m_min;
  }

  constexpr T get_max() const {
    check_range();
    return m_max;
  }

  constexpr void check_range() const {
    using namespace std;
    if (m_max <= m_min) {
      throw Errors::Error{
          "Min_max: (max==" + to_string(m_max) + ") <= (min==" + to_string(m_min) + ")."
      };
    }
  }

  private:
    T m_min{};
    T m_max{};
};

enum class Op {
  op_xor,
  op_add,
};

template <typename T>
using op_func = std::function<T(const T&a, const T&b)>;

template <typename T>
op_func<T> to_func(Op op) {
  using enum Op;
  switch (op) {
    case op_xor: return std::bit_xor<T>();
    case op_add: return std::plus<T>();
  }

  assert(0 && "Some unhandled op encountered.");
}

static std::mt19937::result_type get_rand() {
  static std::random_device rd{};   // a seed source for the random number engine
  static std::mt19937 gen{rd()};
  return gen();
}

template <typename T>
T calculate_last_in_series(T number, const std::span<T> series, Op op) {
  switch (op) {
    case Op::op_add: return number - std::accumulate(series.begin(), series.end(), static_cast<T>(0), to_func<T>(op));
    case Op::op_xor: return number ^ std::accumulate(series.begin(), series.end(), static_cast<T>(0), to_func<T>(op));
  }

  assert(0 && "Some unhandled op encountered.");
}

template <typename T>
std::vector<T> series(T number, Min_max<unsigned int> number_of_steps, Op op) {
  std::vector<T> result{};

  const unsigned int step_number{(static_cast<unsigned int>(get_rand()) % (number_of_steps.get_max() - number_of_steps.get_min())) + number_of_steps.get_min()};

  for (unsigned int i{0}; i < step_number - 1; ++i) {
    result.push_back(static_cast<T>(get_rand()));
  }

  result.push_back(calculate_last_in_series<T>(number, result, op));

  return result;
}

void print_help() {
  std::cout << "help: program <number> <min_number_of_steps> <max_number_of_steps> [<op>]" << std::endl
            << "  " << "Range: [<min_number_of_steps>, <max_number_of_steps>)" << std::endl
            << "  " << "<op> is one of: add, xor. The default is add." << std::endl;
}

struct Args {
  int                   number{};
  Min_max<unsigned int> number_of_steps{};
  Op                    op{};
};

Args handle_args(const std::span<char*> &args) {
  const bool is_op_absent{args.size() == 4};
  if ((args.size() != 5) && !is_op_absent) {
    throw Errors::Arg_error{"Wrong number of arguments."};
  }

  int number{};

  try {
    number = std::stoi(args[1]);
  }
  catch (...) {
    throw Errors::Arg_error{"Failed to retrieve the argument <number>.", {0}};
  }

  Min_max<unsigned int> number_of_steps{};

  try {
    number_of_steps.set_min(std::stoul(args[2]));
  }
  catch (...) {
    throw Errors::Arg_error{"Failed to retrieve the argument <min_number_of_steps>.", {1}};
  }

  try {
    number_of_steps.set_max(std::stoul(args[3]));
  }
  catch (...) {
    throw Errors::Arg_error{"Failed to retrieve the argument <max_number_of_steps>.", {2}};
  }

  Op op{};
  const std::map<std::string_view, Op> op_map{
      {"xor", Op::op_xor},
      {"add", Op::op_add},
  };
  if (is_op_absent) {
    op = Op::op_add;
  } else {
    try {
      op = op_map.at(args[4]);
    } catch (...) {
      throw Errors::Arg_error{"Failed to retrieve the argument <op>.", {3}};
    }
  }

  try {
    number_of_steps.check_range();
  } catch (const Errors::Error &error) {
    throw Errors::Arg_error{error.what(), {1, 2}};
  }

  return {.number=number, .number_of_steps=number_of_steps, .op=op};
}

int main(int argc, char **argv) {
  int                   number{};
  Min_max<unsigned int> number_of_steps{};
  Op                    op{};
  try {
    const auto &handler_result = handle_args(std::span<char*>{argv, static_cast<std::size_t>(argc)});
    number          = handler_result.number;
    number_of_steps = handler_result.number_of_steps;
    op              = handler_result.op;
  } catch (const Errors::Arg_error &error) {
    std::cerr << "ERROR. " << error.what() << std::endl;
    print_help();
    return EXIT_FAILURE;
  }

  const auto &result = series<unsigned int>(static_cast<unsigned int>(number), number_of_steps, op);

  for (const auto &el : result) {

    enum class Format {
      hex,
      oct,
      bin,
      dec,
    };

    std::string prefix{"32'"};

    switch (static_cast<Format>(get_rand() % 4)) {
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
