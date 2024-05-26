
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

# --------------------------------------------------------
# Set config of SuperGenius project
if (NOT DEFINED SUPERGENIUS_SRC_DIR)
  if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../SuperGenius/Readme.md")
    message("Setting default SuperGenius directory")
    set(SUPERGENIUS_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/../../SuperGenius" CACHE STRING "Default SuperGenius Library")
    ## get absolute path
    #cmake_path(SET SUPERGENIUS_SRC_DIR NORMALIZE "${SUPERGENIUS_SRC_DIR}")
  else()
    message( FATAL_ERROR "Cannot find SuperGenius directory required to build" )
  endif()
endif()

# --------------------------------------------------------
# Set config of SuperGenius project
if (NOT DEFINED GENIUSSDK_SRC_DIR)
  if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../GeniusSDK/Readme.MD")
    message("Setting default SuperGenius directory")
    set(GENIUSSDK_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/../../GeniusSDK" CACHE STRING "Default SuperGenius Library")
    ## get absolute path
    #cmake_path(SET GENIUSSDK_SRC_DIR NORMALIZE "${GENIUSSDK_SRC_DIR}")
  else()
    message( FATAL_ERROR "Cannot find SuperGenius directory required to build" )
  endif()
endif()
