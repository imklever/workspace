project(hello)
add_executable(${PROJECT_NAME} main.cpp hello.cpp)
add_definitions(-D__linux__)
add_subdirectory(src)
