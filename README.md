# Stream Setup Instructions

## Hardware Requirements

Following are the hardware requirements for the streaming setup

- Raspberry Pi 5 (4GB) for the streaming multiplexer, where restreamer would be installed
- Raspberry Pi 4 (2/4GB) for the client for each TV to receive the stream
- A class 10 (A1) SD Card of 23GB or more capacity for each Raspberry Pi
- One USB Type C PD (Power Delivery) compliant adapter for each Pi
- One USB Type C to C power cable for each Raspberry Pi
- One micro to full HDMI cable for each Raspberry Pi
- One SD card reader


## Prepare OS Image and software

Download and install software to flash OS image to SD card [Raspberry Pi Imager](https://www.raspberrypi.com/software/). Another option is [Balena Etcher](https://etcher.balena.io/)

Follow these steps to flash the OS image to SD card

- Insert SD card into card reader plugged to USB port, start Raspberry Pi imager
- Raspberry Pi imager: Choose Device - Select Raspberry Pi version 4/5
- Raspberry Pi imager: Choose OS - Raspberry Pi OS(64 Bit)
- Raspberry Pi imager: Choose Storage - Select the SD Card Reader
- Remove the SD card and install in Raspberry Pi

Follow these steps to install required software. At this stage the board would need to be connected to a network which does not block internet access.

- Connect a network cable, keyboard, mouse, monitor and power up the raspberry pi
- wait for 2 minutes for the first boot
- Update password using `passwd` command, default user name is "pi" and password is "raspberry"
- create a new user, set passwd, and set it to 'linger', using instructions below

```bash
sudo adduser tw
sudo passwd tw
sudo loginctl enable-linger tw
# confirm that linger has been enabled
sudo loginctl show-user tw | grep ^Linger
```

Run following commands to update OS and install required software "podman", which is a OpenSource drop-in replacement for Docker.

```bash
sudo apt update && sudo apt upgrade
sudo apt install podman
```

## Installing Restreamer

Logout of the default "pi" user and login to the newly creater "tw" user

Create configuration and data folders in the home folder to be used by the re-streamer container

```bash
mkdir -p restreamer/config
mkdir -p restreamer/data
```

Fetch the re-streamer image 

```bash
podman pull docker.io/datarhei/restreamer:rpi-latest
```

Copy the image ID as listed by the command `podman images`
Run the below command to run the container based on the downloaded image

```bash
podman run -d --rm --name restreamer -v ~/restreamer/config:/core/config -v ~/restreamer/data:/core/data -p 8080:8080 -p 8181:8181 -p 1935:1935 -p 1936:1936 -p 6000:6000/udp <image-id>
```

## Setup Restreamer container to auto start

Run following commands to creates a systemd service unit file and enable the service

```bash
podman generate systemd --new --name restreamer > ~/.config/systemd/user/restreamer.service
podman stop restreamer && podman rm restreamer && podman volume prune restreamer
systemctl --user daemon-reload
systemctl --user enable restreamer.service
systemctl --user start restreamer.service
```

Now shutdown the Raspberry Pi and connect to the network where streaming is required.

## Configure Restreamer 

Check the IP address of the Raspberry Pi using the `ifconfig` command
Now open a browser of a machine connected to the same network and open the URL "<url>:8080/ui"
In the interface that opens, set the Admin password

Go to Menu (Top right corner icon) --> System, to go RTMP tab, check the "RTMP" option, click restart when asked. 
Go to Menu (Top right corner icon) --> System, to go Network tab, enter IP Address to the "Address" field

Click on video setup (Green Button), select video source "RTMP server", copy the generated URL, this would be used in OBS to send stream to.

Now, back to Restreamer, click Next, select video resolution 1080 etc., select Audio settings in the next screen, add meta data in the next screen, finally channel dashboard would be displayed, copy the content address, to be used in the browser to view.

## Configure Receiver 

The following steps are used to configure the SBC receiving the stream. 
The browser needs to open at startup in "Kiosk" mode and open the default URL.

```bash
mkdir -p ~/.config/autostart
nano ~/.config/autostart/open_browser.desktop
```

Add the following content to the file 

```
[Desktop Entry]
Type=Application
Name=OpenBrowser
Exec=chromium-browser --kiosk <IP Address>
X-GNOME-Autostart-enabled=true
```
