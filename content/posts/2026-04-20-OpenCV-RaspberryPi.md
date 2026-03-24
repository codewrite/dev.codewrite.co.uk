---
title: "Seting up OpenCV on Raspberry Pi"
date: 2026-04-20
draft: true
categories:
  - raspberryPi
---

In a Terminal, SSH into the Pi:

```bash
cd Documents    # or wherever
mkdir prj
cd prj
python3 -m venv opencv_venv  --system-site-packages
source opencv_venv/bin/activate
```

To deactivate:

```bash
deactivate
```

In Thonny (VNC):

```
Run -> Configure Interpreter
Interpreter Tab -> Python Executable:
    /home/pi/Documents/prj/opencv_venv/bin/python3
```

