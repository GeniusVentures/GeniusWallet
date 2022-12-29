cmake_minimum_required(VERSION 3.4.1)  
 
add_library(
        native
        SHARED
        IMPORTED
        GLOBAL
)
set_target_properties(native PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/kotlin/${ANDROID_ABI}/libnative.so)