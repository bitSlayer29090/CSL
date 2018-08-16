# set_rcsinfo.cmake.in
#
# This file is part of NEST.
#
# Copyright (C) 2004 The NEST Initiative
#
# NEST is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# NEST is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NEST.  If not, see <http://www.gnu.org/licenses/>.

execute_process(
  COMMAND /cluster/2020shachem/CSL/nestCompile7/nest-simulator-2.14.0/extras/create_rcsinfo.sh /cluster/2020shachem/CSL/nestCompile7/nest-simulator-2.14.0 /tmp
  OUTPUT_VARIABLE RCSINFO
  OUTPUT_STRIP_TRAILING_WHITESPACE
)


execute_process(
  COMMAND /usr/bin/sed -i "" -e "/^PROJECT_NUMBER/ s/=.*/= 2.14.0, ${RCSINFO} /" /cluster/2020shachem/CSL/nestCompile7/doc/normaldoc.conf
  COMMAND /usr/bin/sed -i "" -e "/^PROJECT_NUMBER/ s/=.*/= 2.14.0, ${RCSINFO} /" /cluster/2020shachem/CSL/nestCompile7/doc/fulldoc.conf
)
