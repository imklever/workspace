cmake_minimum_required(VERSION 2.8)

project(hello)

add_subdirectory(src)

set(INCLUDE_DIRECTORIES src)
include_directories(${INCLUDE_DIRECTORIES})

add_executable(${PROJECT_NAME} main.cpp ${src_files})

target_link_libraries(hello func)


message(STATUS "this is a message: CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")
