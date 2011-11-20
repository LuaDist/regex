# Copyright (C) 2007-2009 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

PROJECT(rxspencer C)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

# simplified reimplementation of included "mkh" script.
FUNCTION(MKH INFILENAMES OUTFILENAME INC)
  SET(MATCH " ==[ \t]")
  IF (INC)
    SET(MATCH " =[ \t]")
  ENDIF (INC)
  SET(TEXT "")
  FOREACH(INFILENAME ${INFILENAMES})
    FILE(READ "${INFILENAME}" TEXT_MORE)
    SET(TEXT "${TEXT}${TEXT_MORE}")
  ENDFOREACH(INFILENAME)
  SET(TEXT "\n${TEXT}")
  STRING(REGEX REPLACE "\n" "\nN" TEXT "${TEXT}")
  STRING(REGEX REPLACE "\nN${MATCH}" "\nY" TEXT "${TEXT}")
  STRING(REGEX REPLACE "\nN[^\n]*" "" TEXT "${TEXT}")
  STRING(REGEX REPLACE "\nY([^\n]*)" "\\1\n" TEXT "${TEXT}")
  SET(TEXT "#ifdef __cplusplus\nextern \"C\" {\n#endif\n${TEXT}#ifdef __cplusplus\n}\n#endif\n")
  IF (INC)
    SET(TEXT "#ifndef ${INC}\n#define ${INC}\n${TEXT}#endif\n")
  ENDIF (INC)
  FILE(WRITE "${OUTFILENAME}" "${TEXT}")
ENDFUNCTION(MKH)

# Patch regerror.c to avoid conflict in MSVC
IF (MSVC)
  FILE(READ regerror.c REGERROR)
  STRING(REGEX MATCH errcode REGERROR_UNPATCHED "${REGERROR}")
  IF (REGERROR_UNPATCHED)
    STRING(REPLACE errcode errorcode REGERROR "${REGERROR}")
    FILE(WRITE regerror.c "${REGERROR}")
  ENDIF()
ENDIF()

# Patch regex.h for off_t on msvc
SET(REGEX_H regex.h)
IF (MSVC)
  FILE(READ regex.h REGEXH)
  STRING(REGEX MATCH "sys/types" REGEXH_PATCHED "${REGEXH}")
  IF (NOT REGEXH_PATCHED)
    STRING(REPLACE "typedef off_t" "#include <sys/types.h>\ntypedef off_t" REGEXH "${REGEXH}")
    FILE(WRITE "${CMAKE_BINARY_DIR}/regex.h" "${REGEXH}")
    SET(REGEX_H ${CMAKE_BINARY_DIR}/regex.h)
  ENDIF()
ENDIF()

MKH(regcomp.c  regcomp.ih  "")
MKH(engine.c   engine.ih   "")
MKH(regerror.c regerror.ih "")
MKH(debug.c    debug.ih    "")
MKH(main.c     main.ih     "")
MKH("regex2.h;regcomp.c;regerror.c;regexec.c;regfree.c" regex.h "_REGEX_H_")

# rxspencer library
SET(CMAKE_INCLUDE_CURRENT_DIR 1)
SET(RXSPENCER_SRCS regcomp.c regerror.c regexec.c regfree.c )

IF(MSVC)
	SET(DEF_FILE librxspencer.def)
ENDIF()

ADD_LIBRARY(rxspencer SHARED ${RXSPENCER_SRCS} ${DEF_FILE})
INSTALL(TARGETS rxspencer RUNTIME DESTINATION ${INSTALL_BIN} LIBRARY DESTINATION ${INSTALL_LIB} ARCHIVE DESTINATION ${INSTALL_LIB})

# Install headers
INSTALL(FILES ${REGEX_H}  DESTINATION ${INSTALL_INC})

# Install docs
INSTALL(FILES COPYRIGHT README WHATSNEW regex.3 regex.7 DESTINATION ${INSTALL_DATA})
