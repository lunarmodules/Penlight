# Copyright (C) 2007-2012 LuaDist.
# Submited by David Manura, Peter Drahos
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( penlight NONE )
cmake_minimum_required ( VERSION 2.8 )
include ( cmake/dist.cmake )
include ( lua )

install ( DIRECTORY lua/ DESTINATION ${INSTALL_LMOD} COMPONENT Runtime )
install_data ( CHANGES.md LICENSE.md README.md CONTRIBUTING.md )
install_doc ( doc/ )
install_test ( tests/ )
install_example ( examples/ )
