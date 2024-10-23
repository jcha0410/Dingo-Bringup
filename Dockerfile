FROM ros:noetic-ros-base

# We need wget to download the apt repository location for later installs.
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set up access to Clearpath's code, download, and install.
RUN wget https://packages.clearpathrobotics.com/public.key -O - | apt-key add - \
    && sh -c 'echo "deb https://packages.clearpathrobotics.com/stable/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/clearpath-latest.list' \
    && wget -q https://raw.githubusercontent.com/clearpathrobotics/public-rosdistro/master/rosdep/50-clearpath.list -O /etc/ros/rosdep/sources.list.d/50-clearpath.list \
    && rosdep update \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends \
    ros-noetic-dingo-robot \
    && rm -rf /var/lib/apt/lists/*

# Since we have the omni version, export the appropriate variable.
ENV DINGO_OMNI=1

# There is already an ENTRYPOINT set in the base image that sources the ROS directory. So just run
# the correct roslaunch command.
CMD [ "roslaunch", "dingo_base", "base.launch" ]
