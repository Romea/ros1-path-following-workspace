## Installation

### Create workspace

You need to install `vcstool`. You can install it using pip (python 3):
```
pip install vcstool
```

Clone this project (if you haven't already done so) using the correct URL and go to the root:
```
git clone ...
cd path_following_workspace
```

All the following commands must be run from the root of this project.
Execute this script to clone all the ROS packages and download the gazebo models:
```
./scripts/create_ws
```

### Build the docker image and compile

The recommended method for compiling the workspace and running the programs is to use docker.
If you do not want to use docker and you are using Ubuntu 20.04 and ROS Noetic, you can skip these
steps and directly use catkin and ros commands.
However, the following instructions assume that docker is being used.

You first need to install a recent version of docker compose by [following the instruction on the
docker documentation](https://docs.docker.com/compose/install/linux/).
If it is already installed, you can check that its version is greater or equal to `2.20` using the
command:
```
docker compose version
```

Since the docker image is hosted in a private repository, you must first log docker in to the
registry server.
You can do it using this access token:
```
docker login gitlab-registry.irstea.fr -u romea -p zL4yPdPqtQsNQ9w3hyD4
```

After that, you can build the image and compile the workspace:
```
docker compose run --rm --build compile
```
This command will:
* pull the lastest image containing a ROS environment with all the workspace dependencies installed
* build a local image based on the previous one but including a copy of your local user in order to
execute every command using the same user as the host system
* run the `compile` service that execute a `catkin build` command to compile everything

## Installation (using tokens in URL of repositories)

If you do not have access to the projects on gitlab.irstea.fr, you can use alternative repositories
with private tokens in URLs.
To do that, you have to add `REPOS_FILE` in the `.env` file before creating the workspace and
building the docker image.
Execute the following commands from the root of this project:
```bash
echo 'REPOS_FILE=repositories.tokens' >> .env
./scripts/create_ws
docker login gitlab-registry.irstea.fr -u romea -p zL4yPdPqtQsNQ9w3hyD4
docker compose run --rm --build compile
```


## Running

You can to open a shell on the docker using the `bash` service:
```
docker compose run --rm bash
```
All the ROS commands are available from the docker.
The option `--rm` allows to automatically delete the container when the shell is closed.
Because the home directory is mounted inside the container, no data are lost (except files created
in `/tmp`).


## Architecture of the workspace

Here is a brief presentation of the main directories:

* `build` contains the files generated by the compilation step
* `docker` contains the configuration files for docker
* `gazebo` contains the downloaded gazebo models that are too large to be versioned
* `devel` contains the shared files and executables of the ROS packages
* `logs` contains the logged information of the compilation
* `scripts` contains some useful tools to prepare the workspace
* `src` contains all the cloned ROS packages

### How the docker image works

The docker image corresponds to an Ubuntu 20.04 image with a complete installation of ROS Noetic
and all the dependencies of the ROS packages of this workspace.
The image is built from the [Dockerfile](docker/Dockerfile) and is pushed to a container registry
in order to avoid rebuilding the full image when installing a new machine.
If you want to include other dependencies, you can create your own Dockerfile based on this image
and add your shell commands.
Then, you just have to replace the URL of this image by the URL of yours in the file
[common.yaml](docker/common.yaml).

When a docker service is started, this workspace is mounted as a volume inside the docker
container and the ROS commands are run using your own Linux user.
This makes using the tools in docker similar to using them directly.
This means that, if you have ROS Noetic on your host system, you should be able to direclty run ros
commands without using docker commands.


## Updating

All the ROS packages may evolve during the hackathon.
You can update them by using the command
```
vcs pull -nw6
```

Some projects may fail to update.
This may be due to local modifications.
You have to manually handle this projects.
However, it is possible to stash your local changes on every project before updating by running
```
vcs custom -nw6 --args pull --rebase --autostash 
```

If you want to update projects and re-download the gazebo models, you can re-run the installation
script
```
./scripts/create_ws
```
