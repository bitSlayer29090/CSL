# Muscle Spindle model

![License](https://img.shields.io/badge/license-GPLv2-green.svg)

This repository hosts a spike based computational model of muscle spindle activity, as described in the paper

Vannucci L., Falotico F., Laschi C., **"Proprioceptive Feedback through a Neuromorphic Muscle Spindle Model"**, 2017, *Frontiers in Neuroscience*, 11, 341 [(link)](http://journal.frontiersin.org/article/10.3389/fnins.2017.00341)

# Installing and running (NEST module)
The model is provided as an extension module for [NEST](http://www.nest-simulator.org/) 2.12, and it is build with [cmake](https://cmake.org/). The source code of NEST 2.12 have to be available for this build, therefore NEST must have been compiled from source.  Then it can be compiled and installed with the following:

```sh
$ cd musclespindle/nest
$ mkdir build && cd build
$ cmake --with-nest=/path_to_nest/nest-config ..
$ make
$ make install
```

For more details on installing NEST extension modules, please refer to the [official documentation](https://nest.github.io/nest-simulator/extension_modules).

After a successful installation, the model should be available from both SLI and PyNest and the examples should run.

# Installing and running (SpiNNaker)
The model is provided as new neuron type for [SpiNNaker](https://spinnakermanchester.github.io/2016.001.AnotherFineProductFromTheNonsenseFactory/) 2016.001. Before using it, the SpiNNaker development environment must be set up as described [here](https://spinnakermanchester.github.io/2016.001.AnotherFineProductFromTheNonsenseFactory/spynnaker/PyNNOnSpinnakerDeveloperInstall.html).  Then it can be compiled with the following:

```sh
$ cd musclespindle/spinnaker/c_models
$ make
```

After a succesful compilation and after setting the PYTHONPATH environment variable to include the musclespindle/spinnaker folder, the example provided should run.


## License

This program is open source software and is licensed under the [GNU General Public License v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html).


## Citing

Please cite the following article if you use this model in your work:

Vannucci L., Falotico F., Laschi C., **"Proprioceptive Feedback through a Neuromorphic Muscle Spindle Model"**, 2017, *Frontiers in Neuroscience*, 11, 341

Here is a suitable BibTeX entry:

```latex
@ARTICLE{vannucci:proprioceptive,
  author={Vannucci, Lorenzo and Falotico, Egidio and Laschi, Cecilia},
  title={Proprioceptive Feedback through a Neuromorphic Muscle Spindle Model},
  journal={Frontiers in Neuroscience},
  volume={11},      
  pages={341},
  year={2017},
  url={http://journal.frontiersin.org/article/10.3389/fnins.2017.00341},
  doi={10.3389/fnins.2017.00341},
  issn={1662-453X},
}
```