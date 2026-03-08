---
title: "Check [micro] SD Cards using WSL2"
date: 2026-03-08
draft: false
categories:
  - ubuntu
  - wsl
---

I decided to check all my microSD cards and decided to use [f3 - Fight Flash Fraud](https://fight-flash-fraud.readthedocs.io/). I also decided to do this using my Windows PC. So I was going to need to use WSL2 and Ubuntu and set it up using [Connecting USB devices](https://learn.microsoft.com/en-us/windows/wsl/connect-usb). I managed it, but there was enough complexity for me to feel that I needed to write some notes about what I did.

So here it is...

First thing I did was open Ubuntu (WSL2) and follow the instructions on f3 - **Download and Compile**. I had to install the build tools first which I did with:

```bash
sudo apt update
sudo apt upgrade
sudo apt install usbutils
sudo apt install build-essential
sudo apt install libudev1 libudev-dev libparted-dev
make
make extra
```

I didn't do the install step.

Back in Windows, and from the Microsoft page, I downloaded the **Install USBIPD on WSL** msi file (x64 version) and ran it.

I then plugged in the microSD card (in an adapter). From the **Attach a USB device** section I just did each step. The USB device was listed as **USB Mass Storage Device**. On Ubuntu I used **sudo fdisk -l** to determine which device to use (in my case /dev/sde) and ran **sudo ./f3probe /dev/sde** to check the card. As it says on the f3 page this will wipe any data on the card, so don't do this on cards that have data you want to keep. Checking a card (most of them were 32GB) took just over 10 minutes. Most were either pass or fail, but one card came back with a **limbo** fail and said I could fix it with f3fix (a 64GB became a 16GB card).
