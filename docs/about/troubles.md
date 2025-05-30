# Решенные проблемы

- Установка ROS Noetic в Docker Container не выполнялась корректно. По итогу за базу был взят образ с ROS Noetic
- Dependency HELL: 
    - Не устанавливались корректно зависимости от PX4
    - Не работал корректно пакет `find-object-2d`, установленный через `apt`. Не отображались детекторы SURF/SIFT. По итогу пакет был собран с [репозитория git](https://github.com/introlab/find-object) для Noetic.
        - При компиляции возникала ошибка отсустствии заголовка `QElapedTimer`. В докерфайл перед сборкой была добавлена строка:
        ```dockerfile
        RUN sed -i '30i #include <QtCore/QElapsedTimer>' /home/root/catkin_ws/src/find-object/src/FindObject.cpp
        ```
    - `Vision_opencv` - пакет выкидывал ошибку `Segmentation Fault (code -11)`. Было решено собрать из [репозитория](https://github.com/ros-perception/vision_opencv) 
- Неработающий скрипт `teleop_node_pos` из исходного репозитория. Необходимо запускать через `teleop_node_pos.py`

- Неработающий CMakeLists.txt репозитория и выполнении `catkin_make`. По итогу принято решение удалить этот файл и инициализировать снова

- Не передавалась переменная окружения в `Dockerfile`. Из-за чего не запускались основные окна

