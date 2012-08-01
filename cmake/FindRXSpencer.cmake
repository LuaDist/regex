# Copyright (C) 2007-2009 LuaDist.
# Created by Peter Kapec <kapecp@gmail.com>
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
#	Note:
#		Searching headers and libraries is very simple and is NOT as powerful as scripts
#		distributed with CMake, because LuaDist defines directories to search for.
#		Everyone is encouraged to contact the author with improvements. Maybe this file
#		becomes part of CMake distribution sometimes.

# - Find rxspencer
# Find the native RXSPENCER headers and libraries.
#
# RXSPENCER_INCLUDE_DIRS	- where to find rxspencer.h, etc.
# RXSPENCER_LIBRARIES	- List of libraries when using rxspencer.
# RXSPENCER_FOUND	- True if rxspencer found.

# Look for the header file.
FIND_PATH(RXSPENCER_INCLUDE_DIR NAMES regex.h)

# Look for the library.
FIND_LIBRARY(RXSPENCER_LIBRARY NAMES rxspencer)

# Handle the QUIETLY and REQUIRED arguments and set RXSPENCER_FOUND to TRUE if all listed variables are TRUE.
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(RXSPENCER DEFAULT_MSG RXSPENCER_LIBRARY RXSPENCER_INCLUDE_DIR)

# Copy the results to the output variables.
IF(RXSPENCER_FOUND)
	SET(RXSPENCER_LIBRARIES ${RXSPENCER_LIBRARY})
	SET(RXSPENCER_INCLUDE_DIRS ${RXSPENCER_INCLUDE_DIR})
ELSE(RXSPENCER_FOUND)
	SET(RXSPENCER_LIBRARIES)
	SET(RXSPENCER_INCLUDE_DIRS)
ENDIF(RXSPENCER_FOUND)

MARK_AS_ADVANCED(RXSPENCER_INCLUDE_DIRS RXSPENCER_LIBRARIES)
