#include <iostream>
#include <memory>
#include <string>
#include <vector>

#define ERGOLIGHT_VERSION "1.0.0"

namespace sample {
enum class Status { Draft, Paid, Shipped };

template <typename T>
class Repository final {
public:
    explicit Repository(std::vector<T> values) : values_(std::move(values)) {}

    [[nodiscard]] const T& at(std::size_t index) const {
        return values_.at(index);
    }

private:
    std::vector<T> values_;
};
}

int main() {
    auto repo = std::make_unique<sample::Repository<std::string>>(std::vector<std::string>{"draft", "paid"});
    std::cout << ERGOLIGHT_VERSION << " " << repo->at(1) << std::endl;
    return sizeof(int) > 0 ? 0 : 1;
}
