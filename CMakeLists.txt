# Copyright (C) 2007-2011 LuaDist.
# Submited by David Manura, Peter Drahos
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

PROJECT(penlight NONE)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

INSTALL(DIRECTORY lua/ DESTINATION ${INSTALL_LMOD})
INSTALL(FILES CHANGES.txt LICENCE.txt README.txt README.txt DESTINATION ${INSTALL_DATA})
INSTALL(DIRECTORY docs/ DESTINATION ${INSTALL_DOC})
INSTALL(DIRECTORY tests/ DESTINATION ${INSTALL_TEST})
INSTALL(FILES run.lua DESTINATION ${INSTALL_TEST})
INSTALL(DIRECTORY examples DESTINATION ${INSTALL_DATA})
