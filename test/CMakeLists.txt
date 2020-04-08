add_executable(${this_name}_test test.cpp)

target_compile_features(${this_name}_test PRIVATE cxx_std_17)
        
target_link_libraries(${this_name}_test ${this_name})
target_compile_options(${this_name}_test PUBLIC -ftemplate-depth=2048 -Wall)