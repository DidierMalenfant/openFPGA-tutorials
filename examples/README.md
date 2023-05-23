# Examples

This folder contains sample cores demonstrating various features of the openFPGA platform.

### Prerequisites

The build system relies on a docker image to provide consistent access to the Intel Quartus tools. You will therefore need to install [Docker Desktop](https://www.docker.com/get-started/) on your machine.

You will also need to install the [pf-fpga-tools](https://pypi.org/project/pf-fpga-tools/), wich in turns requires a [supported](https://didier.malenfant.net/blog/nerdy/2022/08/17/installing-python.html) version of Python.

Finally you will need [GNU Make](https://www.gnu.org/software/make/) which will come built-in on macOS or Linux and [git](https://git-scm.com) which also comes built-in on macOS or Linux.

### Building the cores

To build a core just cd into the example's folder and type:
```
make
```

If you define `CORE_INSTALL_VOLUME` to be the name of your pocket SD card then
```
make install
```

will install the core in the right location.

`CORE_INSTALL_VOLUME` defaults to POCKET if not defined anywhere.

To clean the project type:
```
make clean
```

### Core properties

Rather than distribute the core info across various `json` files that the Pocket expects, all core configuration is located in one simple `toml` file which is then used by the build tools to generate the necessary `json` files automatically.
