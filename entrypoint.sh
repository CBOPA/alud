#!/bin/bash
# Инициализация окружения ROS
source /opt/ros/noetic/setup.bash
source /home/root/catkin_ws/devel/setup.bash
source /home/root/PX4-Autopilot/Tools/setup_gazebo.bash /home/root/PX4-Autopilot /home/root/PX4-Autopilot/build/px4_sitl_default
#
export GAZEBO_MODEL_PATH=/home/root/.gazebo/models:${GAZEBO_MODEL_PATH}
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:/home/root/PX4-Autopilot
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:/home/root/PX4-Autopilot/Tools/sitl_gazebo

# Запуск указанной команды
exec "/bin/bash"
