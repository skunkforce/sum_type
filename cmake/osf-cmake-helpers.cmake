macro(osf_generate_header_only_cmake this_name this_namespace include_test include_example this_depends_on)
include( CMakePackageConfigHelpers )

set( this_folder         "${this_name}" )
set( this_namespace      "osf")
set( this_target         "${this_name}-targets" )
set( this_config         "${this_name}-config.cmake" )
set( this_config_in      "${this_name}-config.cmake.in" )
set( this_config_version "${this_name}-config-version.cmake" )

# create the library target
add_library(${this_name} INTERFACE )
add_library(${this_namespace}::${this_name} ALIAS ${this_name} )
target_sources(${this_name} INTERFACE "$<BUILD_INTERFACE:${detail_header_files};${header_files}>")

target_include_directories(${this_name} INTERFACE 
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/> 
$<INSTALL_INTERFACE:include/>)

message(STATUS ${this_depends_on})
foreach(lib ${this_depends_on})
    find_package("${lib}" REQUIRED)
    target_link_libraries(${this_name} INTERFACE ${this_namespace}::"${lib}")
endforeach()

option(BUILD_TEST "build tests of ${this_name}" OFF)
if(${BUILD_TEST})
    add_subdirectory(test)
endif()

option(BUILD_EXAMPLE "build examples of ${this_name}" OFF)
if(include_example AND ${BUILD_EXAMPLE})
	add_subdirectory(example)
endif()


#configure
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${this_config_in}"
    "${CMAKE_CURRENT_BINARY_DIR}/${this_config}"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${this_folder}"
)
write_basic_package_version_file("${this_name}-config-version.cmake" COMPATIBILITY ExactVersion)

# Installation:

install(
    TARGETS      ${this_name}
    EXPORT       ${this_target}
)

install(
    EXPORT       ${this_target}
    NAMESPACE    ${this_nspace}::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${this_folder}"
)

install(
    FILES       "${CMAKE_CURRENT_BINARY_DIR}/${this_config}"
                "${CMAKE_CURRENT_BINARY_DIR}/${this_config_version}"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${this_folder}"
)

install(
    DIRECTORY   "include/"
    DESTINATION "include/"
)

install(FILES LICENSE DESTINATION ".")


endmacro()