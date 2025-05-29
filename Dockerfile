FROM osrf/ros:noetic-desktop-full

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=noetic
ENV USER=root
ENV HOME=/home/${USER}


RUN apt-get update && apt-get install -y \
    wget \
    lsb-release \
    sudo \
    git \
    curl \
    build-essential \
    cmake \
    python3-pip \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# OpenCV 4.2.0 + contrib
RUN git clone --branch 4.2.0 https://github.com/opencv/opencv.git /opencv && \
    git clone --branch 4.2.0 https://github.com/opencv/opencv_contrib.git /opencv_contrib && \
    mkdir /opencv/build && cd /opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
          -D OPENCV_ENABLE_NONFREE=ON \
          -D BUILD_EXAMPLES=OFF \
          -D INSTALL_PYTHON_EXAMPLES=OFF \
          -D INSTALL_C_EXAMPLES=OFF \
          -D BUILD_opencv_python3=ON \
          .. && \
    make -j$(nproc) && make install && ldconfig && \
    rm -rf /opencv /opencv_contrib

# PX4-Autopilot
RUN git clone https://github.com/PX4/PX4-Autopilot.git ${HOME}/PX4-Autopilot
RUN cd ${HOME}/PX4-Autopilot && \
    git checkout cab477d71550558756509ad3a6ffcbebbbbf82b1 && \
    git submodule sync --recursive && \
    git submodule update --init --recursive

RUN touch /home/${USER}/.profile && \
    chown ${USER}:${USER} /home/${USER}/.profile
RUN bash ${HOME}/PX4-Autopilot/Tools/setup/ubuntu.sh

# GeographicLib для Mavros
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh && \
    chmod +x install_geographiclib_datasets.sh && \
    ./install_geographiclib_datasets.sh && rm install_geographiclib_datasets.sh

# ROS workspace
RUN mkdir -p ${HOME}/catkin_ws/src
RUN cd ${HOME}/catkin_ws/src && \
    git clone https://github.com/MikeS96/autonomous_landing_uav.git

RUN cd ${HOME}/catkin_ws && \
    /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && catkin_init_workspace" && \
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then rosdep init; fi && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y


RUN mkdir -p /home/root/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera && \
    cp -r /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/sdf/* \
          /home/root/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/ && \
    cp -r /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/urdf \
          /home/root/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/ && \
    cp -r /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/meshes \
          /home/root/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/ && \
    mkdir -p /home/root/PX4-Autopilot/Tools/sitl_gazebo/worlds && \
    cp /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/worlds/grass_pad.world \
          /home/root/PX4-Autopilot/Tools/sitl_gazebo/worlds/ && \
    cp /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/files/1076_quad_f450_camera \
          /home/root/PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/airframes/ && \
    mkdir -p /home/root/.gazebo/models && \
    cp -r /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/worlds/gazebo/* \
          /home/root/.gazebo/models/


RUN echo "px4_add_romfs_files(1076_quad_f450_camera)" >> \
    ${HOME}/PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/airframes/CMakeLists.txt

RUN sed -i '/set(models / s/)/ quad_f450_camera)/' \
    ${HOME}/PX4-Autopilot/platforms/posix/cmake/sitl_target.cmake && \
    sed -i '/set(worlds / s/)/ grass_pad)/' \
    ${HOME}/PX4-Autopilot/platforms/posix/cmake/sitl_target.cmake

# Сборка PX4 SITL
RUN cd ${HOME}/PX4-Autopilot && \
    make px4_sitl_default gazebo


RUN rm -f ${HOME}/catkin_ws/CMakeLists.txt
RUN mkdir -p ${HOME}/catkin_ws/src
RUN rm -rf ${HOME}/catkin_ws/src

RUN apt-get update && \
    apt-get install -y ros-${ROS_DISTRO}-find-object-2d && \
    apt-get clean
# Клонирование репозитория в src
RUN git clone https://github.com/MikeS96/autonomous_landing_uav.git ${HOME}/catkin_ws/src/autonomous_landing_uav



RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd ${HOME}/catkin_ws/src && \
    catkin_init_workspace"

RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd ${HOME}/catkin_ws && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y"

RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd ${HOME}/catkin_ws && \
    catkin_make"

RUN apt-get update && \
    apt-get install -y ros-noetic-mavros ros-noetic-mavros-extras ros-noetic-vision-opencv ros-noetic-teleop-twist-keyboard && \
    apt-get clean

RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh && \
    chmod +x install_geographiclib_datasets.sh && \
    ./install_geographiclib_datasets.sh

# Устанавливаем права на teleop_node_pos.py и модифицируем CMakeLists.txt
RUN if [ -f /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/scripts/teleop_node_pos.py ]; then \
        chmod +x /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/scripts/teleop_node_pos.py && \
        echo "catkin_install_python(PROGRAMS scripts/teleop_node_pos.py DESTINATION \${CATKIN_PACKAGE_BIN_DESTINATION})" >> \
        /home/root/catkin_ws/src/autonomous_landing_uav/mavros_off_board/CMakeLists.txt; \
    fi


RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd ${HOME}/catkin_ws && \
    catkin_make"

# Точка входа
COPY entrypoint.sh /home/root/entrypoint.sh
RUN chmod +x /home/root/entrypoint.sh



CMD ["bash"]
