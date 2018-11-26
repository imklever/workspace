cmake_minimum_required(VERSION 2.8)

project(hello)


set(INCLUDE_DIRECTORIES src)
include_directories(${INCLUDE_DIRECTORIES})

aux_source_directory(src src_files)

add_executable(${PROJECT_NAME} main.cpp ${src_files})

message(STATUS "this is a message: CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")
