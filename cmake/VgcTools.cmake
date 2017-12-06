# Specify where to write final build output
set(VGC_LIB_OUTPUT_DIRECTORY       ${CMAKE_BINARY_DIR}/lib)
set(VGC_PYTHON_OUTPUT_DIRECTORY    ${CMAKE_BINARY_DIR}/python)
set(VGC_WRAP_OUTPUT_DIRECTORY      ${CMAKE_BINARY_DIR}/python/vgc)
set(VGC_APP_OUTPUT_DIRECTORY       ${CMAKE_BINARY_DIR}/bin)
set(VGC_RESOURCES_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/resources)

# Note: we could do the following to set default output directories
# However, we normally don't need this since our helper functions
# explicitly set the output directories using the variables above
#
#   set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
#   set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
#   set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Prefixes all strings of a comma-separated list of string with a common
# string, and stores the result in a new variable.
#
# Usage:
# vgc_prepend_(myVariable "prefix_" "string1;string2")
# message(${myVariable}) # -> "prefix_string1;prefix_string2"
#
function(vgc_prepend_ var prefix)
   set(listVar "")
   foreach(f ${ARGN})
      list(APPEND listVar "${prefix}${f}")
   endforeach()
   set(${var} "${listVar}" PARENT_SCOPE)
endfunction()

# Defines a new VGC library. This calls add_library under the hood.
#
# Usage:
# vgc_add_library(myvgclib1
#     THIRD_DEPENDENCIES
#         thirdlib1
#         thirdlib2
#
#     VGC_DEPENDENCIES
#         myvgclib2
#
#     CPP_FILES
#         file1.cpp
#         file2.cpp
# )
#
function(vgc_add_library LIB_NAME)
    message("-- VGC Library: ${LIB_NAME}")

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs THIRD_DEPENDENCIES VGC_DEPENDENCIES CPP_FILES COMPILE_DEFINITIONS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Prepend LIB_NAME with "vgc_lib_" to get target name.
    vgc_prepend_(TARGET_NAME "vgc_lib_" ${LIB_NAME})

    # Add library
    add_library(${TARGET_NAME} SHARED ${ARG_CPP_FILES})

    # VGC dependencies
    vgc_prepend_(VGC_DEPENDENCIES "vgc_lib_" ${ARG_VGC_DEPENDENCIES})
    target_link_libraries(${TARGET_NAME} ${VGC_DEPENDENCIES})

    # Third-party dependencies
    target_link_libraries(${TARGET_NAME} ${ARG_THIRD_DEPENDENCIES})

    # Compile definitions, that is, values given to preprocessor variables
    target_compile_definitions(${TARGET_NAME} PRIVATE ${ARG_COMPILE_DEFINITIONS})

    # Set output name. Prefixes are automatically added from:
    # ${CMAKE_SHARED_LIBRARY_PREFIX} and ${CMAKE_SHARED_LIBRARY_SUFFIX}
    # Example:
    #   LIB_NAME               = geometry
    #   LIB_OUTPUT_NAME        = vgcgeometry
    #   actual output on Linux = libvgcgeometry.so
    set(LIB_OUTPUT_NAME "vgc${LIB_NAME}")
    set_target_properties(${TARGET_NAME}
        PROPERTIES
        OUTPUT_NAME ${LIB_OUTPUT_NAME}
        LIBRARY_OUTPUT_DIRECTORY "${VGC_LIB_OUTPUT_DIRECTORY}"
    )

endfunction()

# Defines a new python extension module that wraps the given
# VGC library. This calls pybind11_add_module() under the hood
#
# Usage:
# vgc_wrap_library(mylib
#     module.cpp
#     wrap_file1.cpp
#     wrap_file2.cpp
# )
#
function(vgc_wrap_library LIB_NAME)
    message("-- VGC Library: ${LIB_NAME} (python wrappers)")

    cmake_parse_arguments(ARG "" "" "" ${ARGN})

    # Get cmake target name for the python module and the C++ lib
    # Example:
    #   LIB_NAME = geometry
    #   LIB_TARGET_NAME = vgc_lib_geometry
    #   MODULE_TARGET_NAME = vgc_wrap_geometry
    vgc_prepend_(LIB_TARGET_NAME "vgc_lib_" ${LIB_NAME})
    vgc_prepend_(WRAP_TARGET_NAME "vgc_wrap_" ${LIB_NAME})

    # Use pybind11 helper function. This calls add_library(${TARGET_NAME} ...)
    # and sets all required include dirs and libs to link.
    pybind11_add_module(${WRAP_TARGET_NAME} ${ARG_UNPARSED_ARGUMENTS})

    # Set the output name. This name must match how python users
    # import the library, e.g., "from vgc.geometry import Point"
    set_target_properties(${WRAP_TARGET_NAME}
        PROPERTIES
        OUTPUT_NAME "${LIB_NAME}"
        LIBRARY_OUTPUT_DIRECTORY "${VGC_WRAP_OUTPUT_DIRECTORY}"
    )

    # Link to the C++ library this Python module is wrapping
    target_link_libraries(${WRAP_TARGET_NAME} PRIVATE ${LIB_TARGET_NAME})

endfunction()

# Defines a new VGC app. This calls add_executable under the hood.
#
# Usage:
# vgc_add_app(myvgcapp
#     THIRD_DEPENDENCIES
#         thirdlib1
#         thirdlib2
#
#     VGC_DEPENDENCIES
#         vgclib1
#
#     CPP_FILES
#         main.cpp
# )
#
function(vgc_add_app APP_NAME)
    message("-- VGC App: ${APP_NAME}")

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs THIRD_DEPENDENCIES VGC_DEPENDENCIES CPP_FILES COMPILE_DEFINITIONS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Prepend LIB_NAME with "vgc_lib_" to get target name.
    vgc_prepend_(TARGET_NAME "vgc_app_" ${APP_NAME})

    # Add library
    add_executable(${TARGET_NAME} ${ARG_CPP_FILES})

    # VGC dependencies
    vgc_prepend_(VGC_DEPENDENCIES "vgc_lib_" ${ARG_VGC_DEPENDENCIES})
    target_link_libraries(${TARGET_NAME} ${VGC_DEPENDENCIES})

    # Third-party dependencies
    target_link_libraries(${TARGET_NAME} ${ARG_THIRD_DEPENDENCIES})

    # Compile definitions, that is, values given to preprocessor variables
    target_compile_definitions(${TARGET_NAME} PRIVATE ${ARG_COMPILE_DEFINITIONS})

    # Set the output name. Example (for now): vgcillustration
    # Under Windows, we may want to call it "VGC_Illustration_2020.exe"
    # Under Linux, we may want to call it vgc-illustration-2020
    vgc_prepend_(APP_OUTPUT_NAME "vgc" ${APP_NAME})
    set_target_properties(${TARGET_NAME}
        PROPERTIES
        OUTPUT_NAME "${APP_OUTPUT_NAME}"
        RUNTIME_OUTPUT_DIRECTORY "${VGC_APP_OUTPUT_DIRECTORY}"
    )

endfunction()

# Add runtime resources to the 'resources' folder.
# Example of resources: GLSL shaders, icons, color schemes, etc.
#
# Unlike the Qt resources system, we do not store resources
# within the executable. The idea is to make them easily "hackable":
# users may want to modify the shaders or icons themselves, and since
# it's technically easy to do, why not allow them? VGC is open-source
# anyway, there's nothing to hide.
#
# Usage:
# vgc_add_resources(icons
#     copy.png
#     cut.png
#     paste.png
# )
#
function(vgc_add_resources DIRECTORY_NAME)
    message("-- VGC Resources: ${DIRECTORY_NAME}")

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs "")
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(DIRECTORY ${VGC_RESOURCES_OUTPUT_DIRECTORY}/${DIRECTORY_NAME})

    file(MAKE_DIRECTORY ${DIRECTORY})
    file(COPY ${ARG_UNPARSED_ARGUMENTS} DESTINATION ${DIRECTORY})

endfunction()
