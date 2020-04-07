add_executable(osf-sum_type_test test.cpp)

target_compile_features(osf-sum_type_test PRIVATE cxx_std_17)
        
target_link_libraries(osf-sum_type_test osf-sum_type)
target_compile_options(osf-sum_type_test PUBLIC -ftemplate-depth=2048 -Wall)