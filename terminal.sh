#!/bin/bash

CONTAINER_NAME="alu"
COMMANDS="/home/root/entrypoint.sh"

docker exec -it "$CONTAINER_NAME" /bin/bash -c "$COMMANDS && exec /bin/bash"
