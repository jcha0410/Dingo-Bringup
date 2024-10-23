# Dingo Bringup #

This repository provides the containers necessary to run the Clearpath Dingo in the lab.

## Table of Contents ##

1. [Jetson Setup](#jetson-setup)
2. [Install Docker on the Jetson](#install-docker-on-the-jetson)
3. [Install Docker Compose on the Jetson](#install-docker-compose-on-the-jetson)
4. [Install Socat](#install-socat)
5. [Local Network Setup](#local-network-setup)
6. [ROS Setup](#ros-setup)
7. [Boot Setup](#boot-setup)
8. [Running](#running)
9. [Adding Additional Nodes](#adding-additional-nodes)

## Jetson Setup ##

You may need to set up a Jetson board to operate the robot, if a pre-configured one has not been provided. If you do
need to set it up install the OS according to the instructions on Jetson's website:
<https://developer.nvidia.com/embedded/learn/get-started-jetson-xavier-nx-devkit#write> Once complete, boot up the
Jetson with an attached mouse, keyboard, and monitor to complete the installation steps. **Make sure the account is set
to log in automatically!**

The physical board can be installed according to Clearpath's instructions:
<https://docs.clearpathrobotics.com/docs/robots/accessories/computers/jetson/jetson_hardware/jetson_xavier_agx_hardware/jetson_xavier_agx_hardware_dingo>.
There are other links for other types of Jetson boards as well.

## Install Docker on the Jetson ##

You need Docker on the Jetson to operate. You can check if Docker is available by running the below command and seeing
if it provides version information.

```bash
docker --version
```

If Docker is not present and needs installed, follow these steps.

1. On the Jetson, look up the codename for the installed Ubuntu version by running `lsb_release -c` in the terminal.
2. On an Internet connected computer, go to <https://download.docker.com/linux/ubuntu/dists/>.
3. Select the Ubuntu version that matches the codename in Step 1.
4. Go to *pool/stable/arm64*.
5. Download the following files to a portable hard drive. The versions do not have to match each other, but should
generally be as high as available.
    * containerd.io_<version>_arm64.deb
    * docker-ce_<version>_arm64.deb
    * docker-ce-cli_<version>_arm64.deb
    * docker-buildx-plugin_<version>_arm64.deb
    * docker-compose-plugin_<version>_arm64.deb
6. Plug the hard drive into the Jetson, open a terminal, and navigate to the files.
7. Run the following command in the terminal from the directory containing the .deb files to install them

    ```bash
    sudo dpkg -i containerd.io_<version>_arm64.deb \
    docker-ce_<version>_arm64.deb \
    docker-ce-cli_<version>_arm64.deb \
    docker-buildx-plugin_<version>_arm64.deb \
    docker-compose-plugin_<version>_arm64.deb
    ```

8. Run these commands to start Docker and make it so that you don't need sudo to run Docker commands any more.

    ```bash
    sudo service docker start
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```

9. Log out and log back in to the Jetson.

Docker should be installed. Run `docker --version` again to make sure.

*Note:* This only installs the engine, not the Docker Desktop GUI. All commands will need performed from the command
line. There is a way to install the GUI, but that hasn't been tested out yet.

## Install Docker Compose on the Jetson ##

You also need Docker Compose on the Jetson to facilitate running multiple containers at once. To test if it is already
installed, run these commands and see if they return version information. Only one needs to return results.

```bash
docker compose version
docker-compose version
```

If you need to install it, follow these steps.

1. On your Internet connected computer, go to the latest release on their Github
(<https://github.com/docker/compose/releases>) and download the file `docker-compose-linux-armv7` located under
"Assets".
2. Copy this file to a portable hard drive.
3. Plug the hard drive into the Jetson, open a terminal, and navigate to the directory containing the file.
4. Run this command to copy, rename the file to the correct location, and allow it to run.

    ```bash
    sudo cp <file_name> /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

Verify the installation worked by running `docker-compose version` again.

## Install Socat ##

There is a script that needs run to configure access to the CAN system via Ethernet. This script requires a utility
called `socat`, which is not typically available on Jetson. To download the deb file for it, run the following commands
on your Internet connected computer from the directory where you cloned this repository. (e.g. the directory containing
the *deb.Dockerfile* file). The file will be placed in this directory.

```bash
docker buildx build --platform linux/arm64 -t deb-download:latest -f debs.Dockerfile .
docker create --name deb deb-download:latest
docker cp deb:/socat.deb .
```

Then, copy the file `socat.deb` to the Jetson board and install with the following command. Run this command from a
terminal on the Jetson after navigating to the location of the file.

```bash
sudo dpkg -i socat.deb
```

## Local Network Setup ##

This setup uses both the Ethernet connection and Wi-Fi. Ethernet to connect to the controller, Wi-Fi to the rest of the
lab. To set this up, follow these steps for the Jetson:

* Ensure the Ethernet cable is connected to the board on the Dingo and that the Dingo is powered on.
* Set the wired connection to a static IP address of `192.168.131.1` and a netmask of `255.255.255.0`. Disconnect and
reconnect to ensure the settings take.
* Connect the Wi-Fi connection to the lab's network.
* Adjust the settings to have a static IP address of `192.168.240.4`, a netmask of `255.255.0.0`, and a gateway of
`192.168.1.1`. Disconnect and reconnect to ensure the settings take. If needed, you can pick a different IP address, but
note that later steps should be modified to use the new IP address.

## ROS Setup ##

Then, build this container or pull it from the container registry. When building the container, make sure you specify it
for an ARM architecture (assuming that is what you have). Run this command on your Internet connected computer.

```bash
docker buildx build --platform linux/arm64 -t dingo:noetic .
```

Save the image for exporting to the Dingo using this command.

```bash
docker save -o dingo-noetic.tar dingo:noetic
```

Copy the resulting `dingo.tar` file to the Dingo via hard drive or scp. Then import it on the Dingo.

```bash
docker load -i dingo.tar
```

## Boot Setup ##

There are two commands that need run every time. For convenience, they are combined into a single Bash script called
`run_dingo.sh`. There is also a compose file used to start the Docker container with the right settings, called
`docker-compose.yml`. Copy both of these files from this repository to the home directory of the Jetson. Make sure the
`ROS_MASTER_URI` and `ROS_IP` settings are correct for the given network in the compose file.

**Important:** Depending on how Docker Compose was installed, you might need to change the `run_dingo.sh` file. Try
running `docker compose version` and `docker-compose version`. Whichever one works is the format that the last line of
the script should follow.

## Running ##

To run the robot, ssh into it with `ssh dingo@192.168.240.4`. Then, just run the script:

```bash
sudo ./run_dingo.sh
```

## Adding Additional Nodes ##

If you have additional sensors to control via ROS, make separate images for them. Then, just add them to the compose
file as additional services. That way, the above start script will start those services too. If they are ROS1 nodes,
they will also need the `ROS_MASTER_URI` and `ROS_IP` variables set. They don't persist between services.
