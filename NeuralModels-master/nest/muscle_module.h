/*
 *  musclemodule.h
 *
 *  Copyright (C) 2017 Lorenzo Vannucci
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef MUSCLEMODULE_H
#define MUSCLEMODULE_H

// Includes from sli:
#include "slifunction.h"
#include "slimodule.h"


namespace muscle {

/**
 * Muscle model.
 */
class MuscleModule : public SLIModule {

public:
  // Interface functions ------------------------------------------

  /**
   * Constructor.
   */
  MuscleModule();

  /**
   * Destructor.
   */
  ~MuscleModule();

  /**
   * Initialize module.
   * @param SLIInterpreter* SLI interpreter
   */
  void init(SLIInterpreter*) override;

  /**
   * Return the name of the model.
   */
  const std::string name(void) const override;

  /**
   * Return the name of the sli file to execute when mymodule is loaded.
   */
  const std::string commandstring( void ) const override;
};

} // namespace muscle

#endif
