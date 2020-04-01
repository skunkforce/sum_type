#pragma once
#include <variant>

//TODO make this real and dump std::variant dependantcy
template <typename... Ts>
class sum_type;

template <typename T, typename U>
class sum_type<T, U>
{
    std::variant<T, U> data;

public:
    template <typename A>
    sum_type(A &&in) : data{std::forward<A>(in)} {}
    template <typename F1, typename F2>
    auto operator()(F1 &&f1, F2 &&f2)
    {
        if (data.index() == 0)
        {
            return f1(std::get<0>(data));
        }
        else
        {
            return f2(std::get<1>(data));
        }
    }
};