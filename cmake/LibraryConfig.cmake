# Select library type
set(_PN ${PROJECT_NAME})
option(BUILD_SHARED_LIBS "Build ${_PN} as a shared library." OFF)
if(BUILD_SHARED_LIBS)
  set(LIBRARY_TYPE SHARED)
else()
  set(LIBRARY_TYPE STATIC)
endif()

# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
endif()
# Possible values of build type for cmake-gui
if(DEFINED CMAKE_BUILD_TYPE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}.")

# Target
add_library(${LIBRARY_NAME} ${LIBRARY_TYPE} ${SOURCES} ${HEADERS})

set_target_properties(${LIBRARY_NAME} PROPERTIES
  CXX_STANDARD 11
  CXX_STANDARD_REQUIRED YES
  CXX_EXTENSIONS NO
)

# Install library
install(TARGETS ${LIBRARY_NAME}
  EXPORT ${PROJECT_EXPORT}
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT bin
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT shlib
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}" COMPONENT stlib
  COMPONENT dev)

# Create 'version.h'
configure_file(version.h.in
  "${CMAKE_CURRENT_BINARY_DIR}/version.h" @ONLY)
set(HEADERS ${HEADERS} ${CMAKE_CURRENT_BINARY_DIR}/version.h)

# Generate '${PROJECT_NAME_LOWERCASE}.h' automatically
file(GLOB HEADER_FILES ${PROJECT_SOURCE_DIR}/${LIBRARY_NAME}/*.h)
foreach(file ${HEADER_FILES})
  # get basename of each header file
  get_filename_component(basename ${file} NAME)

  # append '#include <...>' to the '${PROJECT_NAME_LOWERCASE}.h' file
  # ToDo: set(...) creates a list separated with ';'. Find a different way.
  set(LIB_INCLUDES_STRING ${LIB_INCLUDES_STRING} "#include <PoseLib/${basename}>\n")
endforeach(file)
string(REPLACE ";" "" LIB_INCLUDES_STRING "${LIB_INCLUDES_STRING}")
configure_file(${PROJECT_NAME_LOWERCASE}.h.in
  "${CMAKE_CURRENT_BINARY_DIR}/poselib.h" @ONLY)
set(HEADERS ${HEADERS} ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWERCASE}.h)

# Install headers
install(FILES ${HEADERS}
  DESTINATION "${INSTALL_INCLUDE_DIR}/${LIBRARY_FOLDER}" )
