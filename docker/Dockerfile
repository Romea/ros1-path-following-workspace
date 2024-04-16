ARG FROM_IMAGE=osrf/ros:noetic-desktop
ARG WORKSPACE=/opt/tiara_ws
ARG REPOS_FILE=repositories

# multi-stage for caching
FROM $FROM_IMAGE AS cacher

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git python3-vcstool && \
    rm -rf /var/lib/apt/lists/*

ARG WORKSPACE
ARG REPOS_FILE
WORKDIR $WORKSPACE
COPY $REPOS_FILE repos
RUN --mount=type=ssh \
    mkdir -pm 700 ~/.ssh && \
    ssh-keyscan github.com >>~/.ssh/known_hosts && \
    ssh-keyscan gitlab-ssh.irstea.fr >>~/.ssh/known_hosts && \
    vcs import -w6 <repos

# copy manifests for caching
WORKDIR /opt
RUN mkdir -p /tmp/opt && \
    find . -name "package.xml"   | xargs cp --parents -t /tmp/opt && \
    find . -name "CATKIN_IGNORE" | xargs cp --parents -t /tmp/opt 2>/dev/null || true


# multi-stage for installing build dependencies
FROM $FROM_IMAGE AS installer

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        ccache \
        && \
    pip3 install --no-cache-dir \
        catkin-tools \
        && \
    rm -rf /var/lib/apt/lists/*

ARG WORKSPACE
WORKDIR $WORKSPACE

# install package dependencies
COPY --from=cacher /tmp/$WORKSPACE/src ./src
RUN apt-get update && \
    rosdep install -iyr --from-paths src && \
    rm -rf /var/lib/apt/lists/*


# multi-stage for developing
FROM installer as dever

ARG WORKSPACE
WORKDIR $WORKSPACE
ENV SHELL=/bin/bash
RUN rm -rf "$WORKSPACE"

COPY --chmod=755 ros_entrypoint.sh ros_setup.sh /
RUN echo 'source /ros_setup.sh' >>/etc/bash.bashrc


# multi-stage for building the packages inside the image
FROM installer AS builder

ARG WORKSPACE
ARG CCACHE_DIR=$WORKSPACE/.ccache
ENV CCACHE_DIR=$CCACHE_DIR
WORKDIR $WORKSPACE

# compile workspace
COPY --from=cacher $WORKSPACE ./
RUN --mount=type=cache,target=$CCACHE_DIR \
    . /opt/ros/$ROS_DISTRO/setup.sh && \
    catkin build \
        --cmake-args \
            -DCMAKE_C_COMPILER_LAUNCHER=ccache \
            -DCMAKE_CXX_COMPILER_LAUNCHER=ccache

# source workspace from entrypoint
RUN sed -i "s!^source .*!source '$WORKSPACE/devel/setup.bash'!" /ros_entrypoint.sh
