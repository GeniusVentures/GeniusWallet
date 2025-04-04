
MACRO (TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE target)
  IF (WIN32)
    FOREACH (arg ${ARGN})
      TARGET_LINK_LIBRARIES(${target} ${arg})
      target_link_options(${target} 
      /WHOLEARCHIVE:$<TARGET_FILE:${arg}>
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

MACRO (TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_W_TYPE target link_type)
  IF (WIN32)
    FOREACH (arg ${ARGN})
      TARGET_LINK_LIBRARIES(${target} ${link_type} ${arg})
      target_link_options(${target} ${link_type}
      /WHOLEARCHIVE:$<TARGET_FILE:${arg}>
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
    TARGET_LINK_LIBRARIES(${target} ${link_type} ${LINK_FLAGS} ${ARGN} ${UNDO_FLAGS})
  ENDIF ()
ENDMACRO ()
