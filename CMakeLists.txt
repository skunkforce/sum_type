cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(osf-sum-type LANGUAGES CXX VERSION 0.0.0)

set(detail_header_files
)
set(header_files
    ${CMAKE_CURRENT_SOURCE_DIR}/include/osf/sum_type.hpp 
)

include("cmake/osf-cmake-helpers.cmake")
osf_generate_header_only_cmake(osf-sum-type osf 1 0 osf-tmp)







