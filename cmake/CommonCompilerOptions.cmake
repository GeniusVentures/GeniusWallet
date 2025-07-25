set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


if(NOT CMAKE_SKIP_THIRD_PARTY)
  if (DEFINED SANITIZE_CODE AND "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
      add_compile_options("-fsanitize=${SANITIZE_CODE}")
      add_link_options("-fsanitize=${SANITIZE_CODE}")
  endif()


  if(NOT DEFINED ZKLLVM_DIR)
      if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../zkLLVM")
        message(STATUS "Setting default zkLLVM directory")
        set(ZKLLVM_DIR "${CMAKE_CURRENT_LIST_DIR}/../../zkLLVM" CACHE STRING "Default zkLLVM Library")
        cmake_path(SET ZKLLVM_DIR NORMALIZE "${ZKLLVM_DIR}")	
      else()
          message(FATAL_ERROR "Cannot find zkLLVM directory required to build")
      endif()
  endif()

  # --------------------------------------------------------
  # define third party directory
  if (NOT DEFINED THIRDPARTY_DIR)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../thirdparty")
      message("Setting default third party directory")
      set(THIRDPARTY_DIR "${CMAKE_CURRENT_LIST_DIR}/../../thirdparty")
      ## get absolute path
      cmake_path(SET THIRDPARTY_DIR NORMALIZE "${THIRDPARTY_DIR}") # Doesn't work in Cmake 3.18 (Android SDK's installed version here)
    else()
      message( FATAL_ERROR "Cannot find thirdparty directory required to build" )
    endif()
  endif()

  # --------------------------------------------------------
  # Set config of SuperGenius project
  if (NOT DEFINED SUPERGENIUS_SRC_DIR)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../SuperGenius")
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
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../GeniusSDK")
      message("Setting default GeniusSDK directory")
      set(GENIUSSDK_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/../../GeniusSDK" CACHE STRING "Default GeniusSDK Library")
      ## get absolute path
      #cmake_path(SET GENIUSSDK_SRC_DIR NORMALIZE "${GENIUSSDK_SRC_DIR}")
    else()
      message( FATAL_ERROR "Cannot find GeniusSDK directory required to build" )
    endif()
  endif()

endif()