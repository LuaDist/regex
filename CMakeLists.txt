# Copyright (C) 2007-2012 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( rxspencer C )
cmake_minimum_required ( VERSION 2.8 )
include ( cmake/dist.cmake )

# simplified reimplementation of included "mkh" script.
function ( MKH INFILENAMES OUTFILENAME INC )
  set ( MATCH " ==[ \t]" )
  if ( INC )
    set ( MATCH " =[ \t]" )
  endif ( INC )
  set ( TEXT "" )
  foreach ( INFILENAME ${INFILENAMES} )
  file ( READ "${INFILENAME}" TEXT_MORE )
  set ( TEXT "${TEXT}${TEXT_MORE}" )
  endforeach ( INFILENAME )
  set ( TEXT "\n${TEXT}" )
  string ( REGEX REPLACE "\n" "\nN" TEXT "${TEXT}" )
  string ( REGEX REPLACE "\nN${MATCH}" "\nY" TEXT "${TEXT}" )
  string ( REGEX REPLACE "\nN[^\n]*" "" TEXT "${TEXT}" )
  string ( REGEX REPLACE "\nY([^\n]*)" "\\1\n" TEXT "${TEXT}" )
  set ( TEXT "#ifdef __cplusplus\nextern \"C\" {\n#endif\n${TEXT}#ifdef __cplusplus\n}\n#endif\n" )
  if ( INC )
    set ( TEXT "#ifndef ${INC}\n#define ${INC}\n${TEXT}#endif\n" )
  endif ( INC )
  file ( WRITE "${OUTFILENAME}" "${TEXT}" )
endfunction ( MKH )

# Patch regerror.c to avoid conflict in MSVC
if ( MSVC )
  file ( READ regerror.c REGERROR )
  string ( REGEX MATCH errcode REGERROR_UNPATCHED "${REGERROR}" )
  if ( REGERROR_UNPATCHED )
    string ( REPLACE errcode errorcode REGERROR "${REGERROR}" )
    file ( WRITE regerror.c "${REGERROR}" )
  endif ( )
endif ( )

# Patch regex.h for off_t on msvc
set ( REGEX_H regex.h )
if ( MSVC )
  file ( READ regex.h REGEXH )
  string ( REGEX MATCH "sys/types" REGEXH_PATCHED "${REGEXH}" )
  if ( NOT REGEXH_PATCHED )
    string ( REPLACE "typedef off_t" "#include <sys/types.h>\ntypedef off_t" REGEXH 
      "${REGEXH}" )
    file ( WRITE "${CMAKE_BINARY_DIR}/regex.h" "${REGEXH}" )
    set ( REGEX_H ${CMAKE_BINARY_DIR}/regex.h )
  endif ( )
endif ( )

mkh ( regcomp.c regcomp.ih "" )
mkh ( engine.c engine.ih "" )
mkh ( regerror.c regerror.ih "" )
mkh ( debug.c debug.ih "" )
mkh ( main.c main.ih "" )
mkh ( "regex2.h;regcomp.c;regerror.c;regexec.c;regfree.c" regex.h "_REGEX_H_" )

# rxspencer library
set ( CMAKE_INCLUDE_CURRENT_DIR 1 )
set ( RXSPENCER_SRCS regcomp.c regerror.c regexec.c regfree.c )

if ( MSVC )
  set ( DEF_FILE librxspencer.def )
endif ( )

add_library ( rxspencer ${RXSPENCER_SRCS} ${DEF_FILE} )
install_library ( rxspencer )

# Install headers
install_header ( ${REGEX_H} )

# Install docs
install_data ( COPYRIGHT README WHATSNEW )
