# Examples

This folder contains sample cores demonstrating various features of the openFPGA platform.

### Prerequisites

In order to build the core, you will need to install [pf-dev-tools](https://pypi.org/project/pf-dev-tools/) and its dependencies.

### Building the cores

To build a core just cd into the example's folder and type:
```
pf make
```

If you define `CORE_INSTALL_VOLUME` to be the name of your pocket SD card then
```
pf install
```

will install the core in the right location. `CORE_INSTALL_VOLUME` defaults to `POCKET` if not defined anywhere.

To clean the project type:
```
pf clean
```

### Core properties

Rather than distribute the core info across various `json` files that the Pocket expects, all core configuration is located in one simple `toml` file which is then used by the build tools to generate the necessary `json` files automatically.
