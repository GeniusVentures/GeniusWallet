
# --------------------------------------------------------
# define third party directory
if (NOT DEFINED THIRDPARTY_DIR)
  if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../thirdparty/README.md")
    message("Setting default third party directory")
    set(THIRDPARTY_DIR "${CMAKE_CURRENT_LIST_DIR}/../../thirdparty")
    ## get absolute path
    #cmake_path(SET THIRDPARTY_DIR NORMALIZE "${THIRDPARTY_DIR}") # Doesn't work in Cmake 3.18 (Android SDK's installed version here)
  else()
    message( FATAL_ERROR "Cannot find thirdparty directory required to build" )
  endif()
endif()
