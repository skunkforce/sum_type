#include <osf/sum_type.hpp>
int main() {
	using namespace osf::sum_type;
	basic_visiter v{variant_indexer<std::variant<int, bool>>{}}; // g
	return 0;
}
