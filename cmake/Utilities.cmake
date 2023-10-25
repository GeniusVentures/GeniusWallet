
MACRO (TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE target)
  IF (WIN32)
    FOREACH (arg IN LISTS ARGN)
      SET_TARGET_PROPERTIES(
        ${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${lib}"
      )
    ENDFOREACH ()
  ELSE ()
    IF (APPLE)
      SET(LINK_FLAGS "-Wl,-all_load")
      SET(UNDO_FLAGS "-Wl,-noall_load")
    ELSE ()
      SET(LINK_FLAGS "-Wl,--whole-archive")
      SET(UNDO_FLAGS "-Wl,--no-whole-archive")
    ENDIF ()
    TARGET_LINK_LIBRARIES(${target} ${LINK_FLAGS} ${ARGN} ${UNDO_FLAGS})
  ENDIF ()
ENDMACRO ()
