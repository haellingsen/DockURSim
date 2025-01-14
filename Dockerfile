FROM lsiobase/guacgui:latest

# Set Version Information
ARG BUILD_DATE="03/06/21"
ARG VERSION="5.11.0.108249"
LABEL build_version="URSim Version: ${VERSION} Build Date: ${BUILD_DATE}"
LABEL maintainer="Harald Ellingsen"
LABEL MAINTAINER="Harald Ellingsen"
ENV APPNAME="URSim"

# Set Timezone
ARG TZ="Europe/London"
ENV TZ ${TZ}

# Setup Environment
ENV DEBIAN_FRONTEND noninteractive

# Set Home Directory
ENV HOME /ursim

# Set robot model - Can be UR3, UR5 or UR10
ENV ROBOT_MODEL UR5

RUN \
    echo "**** Installing Dependencies ****" && \
    apt-get update && \
    apt-get install -qy --no-install-recommends \
    openjdk-8-jre psmisc && \
    # Change java alternatives so we use openjdk8 (required by URSim) not openjdk11 that comes with guacgui
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java 10000

RUN \
    apt install -y iputils-ping net-tools

# Setup JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN \
    echo "**** Downloading URSim ****" && \
    # Make sure we are in the root
    cd / && \ 
    # Download URSim Linux tar.gz
    curl https://s3-eu-west-1.amazonaws.com/ur-support-site/115608/URSim_Linux-5.11.0.108249.tar -o URSim-Linux.tar && \
    # Extract tarball
    tar xvf URSim-Linux.tar && \
    #Remove the tarball
    rm URSim-Linux.tar && \
    # Rename the URSim folder to jus ursim 
    mv  /ursim* /ursim

RUN \
    echo "**** Installing URSim ****" && \
    # cd to ursim folder
    cd /ursim && \
    # Make URControl and all sh files executable
    chmod +x ./*.sh ./URControl && \
    #
    # Stop install of unnecessary packages and install required ones quietly
    sed -i 's|apt-get -y install|apt-get -qy install --no-install-recommends|g' ./install.sh && \
    # Skip xterm command. We dont have a desktop
    sed -i 's|tty -s|(exit 0)|g' install.sh && \
    # Skip Check of Java Version as we have the correct installed and the command will fail
    sed -i 's|needToInstallJava$|(exit 0)|g' install.sh && \
    # Skip install of desktop shortcuts - we dont have a desktop
    sed -i '/for TYPE in UR3 UR5 UR10/,$ d' ./install.sh  && \
    # Remove commands that are not relevant on docker as we are root user
    sed -i 's|pkexec ||g' ./install.sh && \ 
    sed -i 's|sudo ||g' ./install.sh && \
    #
    # Install URSim
    ./install.sh && \
    #
    echo "Installed URSim"


RUN \     
    echo "**** Clean Up ****" && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Copy ursim run service script
COPY ursim /etc/services.d/ursim

# Expose ports 
# Guacamole web browser viewer
EXPOSE 8080
# VNC viewer
EXPOSE 3389
# Modbus Port
EXPOSE 502
# Interface Ports
EXPOSE 29999
EXPOSE 30001-30004

# Mount Volumes
VOLUME /ursim

ENTRYPOINT ["/init"]
