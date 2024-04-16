#!/bin/bash
source "$WORKSPACE/devel/setup.bash" &>/dev/null || source "/opt/ros/$ROS_DISTRO/setup.bash"
export ROSCONSOLE_FORMAT='[${severity}] ${node}: ${message}'
export GAZEBO_RESOURCE_PATH="$WORKSPACE/gazebo:$GAZEBO_RESOURCE_PATH"
export GAZEBO_MODEL_PATH="$WORKSPACE/gazebo/models:$GAZEBO_MODEL_PATH"
exec $@
