# Установка проекта через Docker

## Требования к хост-системе
- **Операционная система**: Linux (рекомендуется Ubuntu 20.04 LTS)
- **Установленные пакеты**:
    - [Docker](https://docs.docker.com/engine/install/). 
    - xhost.
    - [NVIDIA Container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) (опционально, для ускорения Gazebo).

## Подготовка на хост-системе
1. Убедитесь, что Docker установлен и работает:
   ```
   docker --version
   ```
2. Установите xhost для GUI:
   ```
   sudo apt install x11-xserver-utils
   ```
3. Разрешите доступ к X11:
   ```
   xhost +local:docker
   ```

## Установка и запуск проекта
1. Склонируйте репозиторий:
   ```
   git clone https://github.com/CBOPA/alud.git
   cd alud
   ```
2. Дайте разрешение на запуск всех `.sh` файлов.
   ```bash
   sudo chmod +x -R .
   ```

## [Запуск проекта](./start.md)
