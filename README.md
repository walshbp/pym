# Project PyM
Python bindings for the ProjectM Visualizer

## Warning

This project is a experimental proof of concept.  It is very early on (pre-alpha quality).  Use at you own risk.

## Getting Started

### Prerequisites
Pym was developed utilizing Python 3.6 under Ubuntu 17.10.  Early versions of Python 3 should work, but have not been tested.

A number of python packages are required to compile Pym and run the examples.  It is recommeded that the user creates a python virtual environment to install the packages and in which to build Pym.

```
python3 -m venv pym-python-env
source pym-python-env/bin/activate

pip install pysdl2 cython numpy PyOpenGL PyOpenGL_accelerate
```

Users will also need to install ProjectM. Installation instructions can be found [here](https://github.com/projectM-visualizer/projectm).

Note: the install script does not currently install all the correct header files into the {install}/include directory.  Users will need to manually copy these over.

```
cp libprojectm_src/src/libprojectM/Common.hpp libprojectm_install/include
cp libprojectm_src/src/libprojectM/dlldefs.h libprojectm_install/include
cp libprojectm_src/src/libprojectM/event.h libprojectm_install/include
cp libprojectm_src/src/libprojectM/fatal.h libprojectm_install/include
cp libprojectm_src/src/libprojectM/PCM.h libprojectm_install/include
```

### Installing

To install Pym the user must first modify the base_path variable in the setup.py to point towards the Project M installation folder.  From there:


```
python setup.py install
```


## Running 

A couple of examples are included in the exmaples directory. For both of them users nneed to edit the "main.py" to point to the correct "presetURL".

"pym_sdl" recreates Project M's project-M-sdl example. 

```
python examples/pym_sdl/main.py
```

"pym_sdl_wav" can be used to playback a wav file.  To run:


```
python examples/pym_sdl/main.py
```
