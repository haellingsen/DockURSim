   docker run \
    --name="dockursim" \
    -e ROBOT_MODEL=UR5 \
    -p 8080:8080 \
    -p 29999:29999 \
    -p 30001-30004:30001-30004 \
    -p 3389:3389 \
    -v programs:/ursim/programs \
    -v dockursim:/ursim \
    --privileged \
    --cpus=1 \
    765ec35658ca