#pragma once

#include <sstream>
#include <iterator>
#include <set>

namespace Errors {
  class Error : public std::runtime_error {
    public:
      using std::runtime_error::runtime_error;
  };

  class Arg_error : public Error {
    public:
      Arg_error(const std::string &message = "", const std::set<unsigned int> &arg_pos = {})
          : Error{message} {
        std::stringstream arg_pos_stream{};

        std::copy(arg_pos.begin(), arg_pos.end(), std::ostream_iterator<unsigned int>{arg_pos_stream, ", "});

        m_what_result_str = Error::what();

        if (!arg_pos.empty()) {
          m_what_result_str += " Problem argument's positions: " + std::move(arg_pos_stream).str();
        }
      }

      const char* what() const noexcept override {
        return m_what_result_str.c_str();
      }

    private:
      std::string m_what_result_str{};
  };
}
