docker run --rm -it \
--name="dockursim" \
-e ROBOT_MODEL=UR5 \
-p 8080:8080 \
-p 29999:29999 \
-p 30001-30004:30001-30004 \
-p 3389:3389 \
-p 502:502 \
-v programs:/ursim/programs \
-v ursim:/ursim \
--privileged \
--cpus=1 \
dockursim:latest