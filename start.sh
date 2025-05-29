#!/bin/bash
xhost +local:docker

echo $DISPLAY
docker run --name alu -it --rm \
        --net=host \
        --gpus=all \
        --env "DISPLAY=$DISPLAY" \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --privileged \
        autonomous_landing_uav \
        /bin/bash -c "/home/root/entrypoint.sh"
