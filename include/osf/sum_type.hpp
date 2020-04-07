#pragma once
#include <variant>
#include <osf/tmp.hpp>

namespace osf {
	namespace sum_type {
		namespace detail {

			template <typename V, typename F, typename R, R (*... p)(V, F)>
			struct to_compile_time {
				static constexpr R (*a[])(V, F) = {p...};
			};
		} // namespace detail

		template <typename Indexer, typename Fun>
		class basic_visiter {
			Indexer idxer;
			Fun f;

		public:
			basic_visiter(Indexer i) : idxer{i} {
			}
			template <typename V>
			auto operator()(V v) {
				detail::to_compile_time<V, Fun, void>::a[idxer(v)](v, f);
				return 0;
			}
		};

		template <typename Indexer>
		basic_visiter(Indexer)->basic_visiter<Indexer, typename Indexer::extent>;

		template <typename V>
		struct variant_indexer;

		template <typename... Ts>
		struct variant_indexer<std::variant<Ts...>> {
			using extent = tmp::int_<sizeof...(Ts)>;
		};

		// TODO make this real and dump std::variant dependantcy
		template <typename... Ts>
		class sum_type;

		template <typename T, typename U>
		class sum_type<T, U> {
			std::variant<T, U> data;

		public:
			template <typename A>
			sum_type(A &&in) : data{std::forward<A>(in)} {
			}
			template <typename F1, typename F2>
			auto operator()(F1 &&f1, F2 &&f2) {
				if (data.index() == 0) {
					return f1(std::get<0>(data));
				} else {
					return f2(std::get<1>(data));
				}
			}
		};
	} // namespace sum_type
} // namespace osf