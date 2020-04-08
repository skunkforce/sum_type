macro(osf_generate_header_only_cmake this_name this_namespace include_test include_example this_depends_on)
include( CMakePackageConfigHelpers )

set( this_name           ${this_name} )
set( this_folder         "${this_name}" )
set( this_namespace      "osf")
set( this_target         "${this_name}-targets" )
set( this_config         "${this_name}-config.cmake" )
set( this_config_in      "${this_name}-config.cmake.in" )
set( this_config_version "${this_name}-config-version.cmake" )

# create the library target
add_library(${this_name} INTERFACE )
target_compile_features(${this_name} INTERFACE cxx_std_17)
add_library(${this_namespace}::${this_name} ALIAS ${this_name} )
target_sources(${this_name} INTERFACE "$<BUILD_INTERFACE:${detail_header_files};${header_files}>")

target_include_directories(${this_name} INTERFACE 
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/> 
$<INSTALL_INTERFACE:include/>)

foreach(lib ${this_depends_on})
	find_package(${lib} REQUIRED)
	target_link_libraries(${this_name} INTERFACE ${this_namespace}::${lib})
endforeach()

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
	set(IS_TOPLEVEL ON)
else()
	set(IS_TOPLEVEL OFF)
endif()

option(BUILD_TEST "build tests of ${this_name}" ${IS_TOPLEVEL})
if(${include_test} AND ${BUILD_TEST})
    add_subdirectory(test)
endif()


option(BUILD_EXAMPLE "build examples of ${this_name}" ${IS_TOPLEVEL})
if(${include_example} AND ${BUILD_EXAMPLE})
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
	INCLUDES DESTINATION include
)

install(
    EXPORT       ${this_target}
    NAMESPACE    ${this_namespace}::
	DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${this_folder}"
	FILE "${this_target}.cmake"
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


option(MAKE_INCLUDE_TESTS OFF)
if (MAKE_INCLUDE_TESTS)
	function(convert_name out filename)
		string(REGEX REPLACE "[\\./]" "_" result "${filename}")
		set(${out} ${result} PARENT_SCOPE)
	endfunction()
	function(make_test_includes_file file)
		convert_name(basename "${file}")
		file(WRITE ${CMAKE_BINARY_DIR}/include_test/${basename}.cpp
				"#include <${file}>\nint main() {}")
	endfunction()
	file(GLOB_RECURSE headers RELATIVE "${CMAKE_CURRENT_LIST_DIR}/tmp/"
			"${CMAKE_CURRENT_LIST_DIR}/tmp/*.hpp")
	foreach(file IN LISTS headers)
		make_test_includes_file(${file})
		convert_name(basename "${file}")
		add_executable(${basename} include_test/${basename}.cpp)
		target_link_libraries(${basename} ${this_name})
		target_compile_options(${basename} PUBLIC -Wall)
		add_dependencies(${this_name}_test ${basename})
	endforeach()
	file(GLOB_RECURSE tests RELATIVE "${CMAKE_CURRENT_LIST_DIR}/"
			"${CMAKE_CURRENT_LIST_DIR}/test/*.hpp")
	foreach (file IN LISTS tests)
		make_test_includes_file(${file})
		convert_name(basename "${file}")
		add_executable(${basename} include_test/${basename}.cpp)
		target_link_libraries(${basename} ${this_name})
		target_include_directories(${basename} PRIVATE ${CMAKE_CURRENT_LIST_DIR})
		target_compile_options(${basename} PUBLIC -Wall)
		add_dependencies(${this_name}_test ${basename})
	endforeach ()
endif ()


endmacro()