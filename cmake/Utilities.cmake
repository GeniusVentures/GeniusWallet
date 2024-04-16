
MACRO (TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE target)
  IF (WIN32)
    FOREACH (arg ${ARGN})
      TARGET_LINK_LIBRARIES(${target} ${arg})
      SET_TARGET_PROPERTIES(
        ${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${arg}"
      )
    ENDFOREACH ()
  ELSE ()
    IF (APPLE)
      SET(LINK_FLAGS "-Wl,-force_load")
      SET(UNDO_FLAGS "")
    ELSE ()
      SET(LINK_FLAGS "-Wl,--whole-archive")
      SET(UNDO_FLAGS "-Wl,--no-whole-archive")
    ENDIF ()
    TARGET_LINK_LIBRARIES(${target} ${LINK_FLAGS} ${ARGN} ${UNDO_FLAGS})
  ENDIF ()
ENDMACRO ()

MACRO (TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_PUB target)
  IF (WIN32)
    FOREACH (arg ${ARGN})
      TARGET_LINK_LIBRARIES(${target} PUBLIC ${arg})
      SET_TARGET_PROPERTIES(
        ${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${arg}"
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
    TARGET_LINK_LIBRARIES(${target} PUBLIC ${LINK_FLAGS} ${ARGN} ${UNDO_FLAGS})
  ENDIF ()
ENDMACRO ()