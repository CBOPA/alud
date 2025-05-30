# Установка и настройка окружения

Данная инструкция описывает процесс чистой установки проекта [autonomous_landing_uav](https://github.com/MikeS96/autonomous_landing_uav) для работы в симуляционной среде Gazebo с использованием ROS Noetic, PX4 SITL (Software In The Loop) и автопилота PX4. Инструкция основана на [инструкции по установке проекта](https://github.com/MikeS96/autonomous_landing_uav/blob/master/Installation.md) и адаптирована для операционной системы **Ubuntu 20.04 LTS (Focal Fossa)** с использованием **ROS Noetic** и **Gazebo 11**. Все шаги протестированы для версии репозитория PX4 с git hash `cab477d71550558756509ad3a6ffcbebbbbf82b1`.

### Требования
- Операционная система: **Ubuntu 20.04 LTS**.
- Установленные пакеты: `git`, `wget`, `cmake`, `python3`, `python3-pip`.
- Доступ к интернету для загрузки зависимостей.

### 1. Установка базового окружения

#### 1.1. Установка ROS Noetic
1. Следуйте официальной инструкции по установке ROS Noetic: [ROS Noetic Installation](https://wiki.ros.org/noetic/Installation/Ubuntu).
   - Убедитесь, что установлена полная версия (`ros-noetic-desktop-full`), которая включает Gazebo 11.
   ```bash
   sudo apt update
   sudo apt install ros-noetic-desktop-full
   ```
2. Инициализируйте `rosdep` для управления зависимостями:
   ```bash
   sudo rosdep init
   rosdep update
   ```
3. Настройте окружение ROS, добавив в `~/.bashrc`:
   ```bash
   echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
   source ~/.bashrc
   ```

#### 1.2. Установка PX4-Autopilot
1. Склонируйте репозиторий PX4-Autopilot в домашнюю директорию и переключитесь на нужный коммит:
   ```bash
   cd ~/ 
   git clone https://github.com/PX4/PX4-Autopilot.git --recursive
   cd PX4-Autopilot
   git checkout cab477d71550558756509ad3a6ffcbebbbbf82b1
   ```
2. Установите зависимости для разработки PX4 SITL:
   ```bash
   bash ./PX4-Autopilot/Tools/setup/ubuntu.sh
   ```
   Этот скрипт устанавливает Gazebo 11, симулятор jMAVSim и инструментарий для NuttX/Pixhawk, необходимые для SITL.
3. Установите дополнительные пакеты для устранения возможных ошибок:
   ```bash
   sudo apt install libgstreamer1.0-dev gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
   ```
4. Проверьте корректность установки инструментария:
   ```bash
   arm-none-eabi-gcc --version
   ```
   Ожидаемый результат:
   ```
   arm-none-eabi-gcc (GNU Arm Embedded Toolchain 9-2020-q2-update) 9.3.1 20200408 (release)
   ```

### 2. Установка MAVROS и GeographicLib
1. Установите пакеты MAVROS для взаимодействия с автопилотом PX4:
   ```bash
   sudo apt install ros-noetic-mavros ros-noetic-mavros-extras
   ```
2. Загрузите и установите датасеты GeographicLib:
   ```bash
   wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
   sudo bash ./install_geographiclib_datasets.sh
   ```

### 3. Установка зависимостей проекта
Проект использует ROS-пакеты `find_object_2d` и `vision_opencv` для компьютерного зрения, а также требует OpenCV с поддержкой алгоритмов SURF/SIFT.

#### 3.1. Установка OpenCV 4.2
> **Важно**: SURF/SIFT не поддерживаются в новых версиях OpenCV (4.x и выше) без дополнительных патчей. Рекомендуется установить OpenCV 4.2 из исходников с дополнительными модулями.

1. Загрузите и соберите OpenCV 4.2:
   ```bash
    git clone --branch 4.2.0 https://github.com/opencv/opencv.git /opencv && \
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
   make -j$(nproc) && make install && ldconfig
   ```
   Если возникнут ошибки с правами доступа, то запускайте сборку и установку от `root`
2. Проверьте версию OpenCV:
   ```bash
   pkg-config --modversion opencv
   ```
   Ожидаемый результат: `4.2.0`.

#### 3.2. Установка ROS-пакетов
Установите пакеты `find_object_2d` и `vision_opencv`:
```bash
sudo apt install ros-noetic-find-object-2d ros-noetic-vision-opencv
```

### 4. Настройка моделей и мира Gazebo
Для работы проекта необходимо настроить модель квадрокоптера DJI F450 и мир Gazebo.

1. **Создание модели `quad_f450_camera`**:
   - Создайте папку для модели в `PX4-Autopilot/Tools/sitl_gazebo/models`:
     ```bash
     mkdir -p ~/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera
     ```
   - Скопируйте файлы `model.config` и `quad_f450_camera.sdf` из репозитория:
     ```bash
     cp ~/autonomous_landing_uav/mavros_off_board/sdf/* ~/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/
     ```
   - Создайте папки `meshes` и `urdf` внутри `quad_f450_camera` и скопируйте соответствующие файлы:
     ```bash
     mkdir -p ~/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/meshes
     mkdir -p ~/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/urdf
     cp ~/autonomous_landing_uav/mavros_off_board/meshes/* ~/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/meshes/
     cp ~/autonomous_landing_uav/mavros_off_board/urdf/* ~/PX4-Autopilot/Tools/sitl_gazebo/models/quad_f450_camera/urdf/
     ```

2. **Создание мира `grass_pad`**:
   - Скопируйте файл `grass_pad.world` в `PX4-Autopilot/Tools/sitl_gazebo/worlds`:
     ```bash
     cp ~/autonomous_landing_uav/mavros_off_board/worlds/grass_pad.world ~/PX4-Autopilot/Tools/sitl_gazebo/worlds/
     ```

3. **Настройка airframe**:
   - Создайте файл airframe `1076_quad_f450_camera` в `PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/airframes`:
     ```bash
     cp ~/autonomous_landing_uav/mavros_off_board/files/1076_quad_f450_camera ~/PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/airframes/
     ```
   - Добавьте airframe в `PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/airframes/CMakeLists.txt`, добавив строку в список `px4_add_romfs_files`:
     ```
     1076_quad_f450_camera
     ```
   - Добавьте модель `quad_f450_camera` и мир `grass_pad` в `PX4-Autopilot/platforms/posix/cmake/sitl_target.cmake`:
     - В секции `set(models ...)` добавьте `quad_f450_camera`.
     - В секции `set(worlds ...)` добавьте `grass_pad`.

4. **Копирование моделей Gazebo**:
   - Создайте папку `~/.gazebo/models`, если она не существует:
     ```bash
     mkdir -p ~/.gazebo/models
     ```
   - Скопируйте модели из репозитория:
     ```bash
     cp -r ~/autonomous_landing_uav/mavros_off_board/worlds/gazebo/* ~/.gazebo/models/
     ```

### 5. Установка и компиляция ROS-пакетов проекта
1. Склонируйте репозиторий проекта в вашу рабочую область Catkin:
   ```bash
   cd ~/catkin_ws/src
   git clone https://github.com/MikeS96/autonomous_landing_uav.git
   ```
2. Скомпилируйте проект:
   ```bash
   cd ~/catkin_ws
   catkin_make
   ```
3. Настройте окружение Catkin:
   ```bash
   echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
   source ~/.bashrc
   ```
   
### 4. [Запуск проекта](./start.md)
