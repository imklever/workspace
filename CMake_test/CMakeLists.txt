cmake_minimum_required(VERSION 2.8)

project(hello)

set(INCLUDE_DIRECTORIES src)
include_directories(${INCLUDE_DIRECTORIES})

##/*
#this
add_subdirectory(src)
add_executable(${PROJECT_NAME} main.cpp)

#or this
#aux_source_directory(<dir> <variable>)
aux_source_directory(src src_files)
add_executable(${PROJECT_NAME} main.cpp ${src_files})
##*/
target_link_libraries(hello func)


message(STATUS "----------this is a message: CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")


#add_definitions(-D__linux__)
#set(CMAKE_BUILD_TYPE    "Debug")



#https://www.cnblogs.com/dverdon/p/4574221.html
#
#cmake_policy()
#cmake_policy(SET CMP0022 OLD)
#
#cmake_policy(SET CMP<NNNN> NEW)
#cmake_policy(SET CMP<NNNN> OLD)
#
#cmake_policy(GET CMP<NNNN> <variable>)
#该命令检查一个给定的策略是否设置为旧行为或新行为。如果策略被设置，输出的变量值会是“OLD”或“NEW”，否则为空。
#
#cmake_policy(PUSH)
#       cmake_policy(POP)
#
#if(POLICY policy-id)
#        如果给出的名字是一个已有的策略（格式是CMP<NNNN>），表达式为真。


#if(COMMAND command-name)
#    　　如果给出的名字是一个可以被调用的命令，宏，或者函数的话，整个表达式的值为真。
