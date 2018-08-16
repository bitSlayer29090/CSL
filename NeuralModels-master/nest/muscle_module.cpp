/*
 *  musclemodule.cpp
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

#include "muscle_module.h"

// Generated includes:
#include "config.h"

#include "muscle_spindle.h"

// Includes from nestkernel:
#include "dynamicloader.h"
#include "exceptions.h"
#include "genericmodel.h"
#include "genericmodel_impl.h"
#include "kernel_manager.h"
#include "model.h"
#include "model_manager_impl.h"
#include "nestmodule.h"
#include "target_identifier.h"

// Includes from sli:
#include "booldatum.h"
#include "integerdatum.h"
#include "sliexceptions.h"
#include "tokenarray.h"

// -- Interface to dynamic module loader ---------------------------------------
#if defined( LTX_MODULE ) | defined( LINKED_MODULE )
muscle::MuscleModule muscle_module_LTX_mod;
#endif

// -- DynModule functions ------------------------------------------------------

muscle::MuscleModule::MuscleModule() {
#ifdef LINKED_MODULE
    nest::DynamicLoaderModule::registerLinkedModule( this );
#endif
}

muscle::MuscleModule::~MuscleModule() {}

const std::string muscle::MuscleModule::name( void ) const {
    return std::string( "Muscle Module" ); // Return name of the module
}

const std::string muscle::MuscleModule::commandstring( void ) const {
    // Instruct the interpreter to load muscle_module-init.sli
    return std::string( "(muscle_module-init) run" );
}

//-------------------------------------------------------------------------------------

void muscle::MuscleModule::init(SLIInterpreter*) {
    nest::kernel().model_manager.register_node_model< muscle_spindle >("muscle_spindle");
}
