---
title: "Raspberry Pi Open CV Camera Setup"
date: 2026-11-25
draft: false
categories:
  - raspberryPi
---

I needed another motion activated camera, so set one up from scratch using a Raspberry Pi 3B+ that was in my collection of old Raspberry Pi bits.

I based this on an existing Raspberry Pi 4 camera that has been happily collecting videos for nearly a year now. The code for this is here: [Raspberry Pi 4 Open CV Motion Camera Github Repo](https://github.com/codewrite/rpi4-cvstream1)

The Raspberry Pi 3B+ had a camera already connected and was in a case, so all I had to was add the software. I decided to give it a bit of an upgrade and use a 512GB SATA SSD that I had taken from an old laptop.

So the first step was to flash this with the latest version of Raspberry Pi OS which was Debian Trixie (64-bit). I used Raspberry Pi Imager to copy this to the SSD. When prompted, I added:

- A password for the pi account
- The wifi SSID and password
- SSH access

I then connected it up and started it running. I connected to an HDMI display because I have found that it can be a bit slow to start, and it's nice to see that it is actually working. I connected up via SSH once the desktop had started though. I then went into raspi-config and enabled VNC. I also copied the SSH keys from computers that I wanted to have access so that I didn't have to type in the password every time I logged in. This also made it easier for other tools such as filezilla and VS Code remote access:

To copy my public key to the Raspberry Pi I typed this on the client computer:

```bash
ssh-copy-id pi@rpi3pw
```

...and followed the instructions. I had already setup my hosts file and router to make sure that I could use an mDNS name rather than an IP address.

I used this (in a terminal window in a VNC client) to make sure the camera was working:

```bash
rpicam-still -o ~/Desktop/image.jpg
```

I then copied the files from [the repository above](https://github.com/codewrite/rpi4-cvstream1) to a folder in the Home directory. The only files I had to modify were:

- systemdata.py - changed the name from *rpi4* to *rpi3pw*
- static/rpi4-mask.png - renamed to rpi3pw-mask.png with an appropriate mask (all white for no mask)

Python was already installed, so all I needed to add was the dependencies for OpenCV and Flask:

```bash
sudo apt install python3-flask
sudo apt install -y v4l-utils ffmpeg python3-opencv
```

I didn't use ```pip3 install flask``` because this doesn't work with newer versions of the OS.

Then, in VNC in a terminal window, I typed:

```bash
cd ~/dev/rpi3pw-cvstream1/src
python3 ./app.py
```

The output from this was:

```
[4:51:27.698126406] [3826]  INFO Camera camera_manager.cpp:340 libcamera v0.8.0+rpt20261104
[4:51:27.741326142] [3829]  INFO RPI pipeline_base.cpp:1144 Using configuration file '/usr/share/libcamera/pipeline/rpi/vc4/rpi_apps.yaml'
[4:51:27.814725849] [3829]  INFO IPAProxy ipa_proxy.cpp:184 Using tuning file /usr/share/libcamera/ipa/rpi/vc4/imx219.json
[4:51:27.832861883] [3829]  INFO Camera camera_manager.cpp:223 Adding camera '/base/soc/i2c0mux/i2c@1/imx219@10' for pipeline handler rpi/vc4
[4:51:27.833056726] [3829]  INFO RPI vc4.cpp:445 Registered camera /base/soc/i2c0mux/i2c@1/imx219@10 to Unicam device /dev/media3 and ISP device /dev/media0
[4:51:27.848907618] [3826]  INFO Camera camera.cpp:1216 configuring streams: (0) 720x480-RGB888/SMPTE170M/Rec709/None/Full (1) 1920x1080-SRGGB10_CSI2P/RAW
[4:51:27.849789540] [3829]  INFO RPI vc4.cpp:620 Sensor: /base/soc/i2c0mux/i2c@1/imx219@10 - Selected sensor format: 1920x1080-SRGGB10_1X10/RAW - Selected unicam format: 1920x1080-pRAA/RAW
 * Serving Flask app 'webpage'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8000
 * Running on http://192.168.X.XXX:8000
Press CTRL+C to quit
```

I could then connect via a web browser on the local network. Any changes that were detected were written to disk in .AVI files.
