---
title: "Dotnet Core on Raspberry Pi"
date: 2020-04-15
draft: false
categories:
  - raspberryPi
  - dotnet
---

> [Source Code on GitHub][gpio-board-github]
> 
> Next: [Creating the solution in Visual Studio Code...][RPI-dotnet-software]

This week's project has been writing the software for my GPIO board on my Raspberry Pi. I added this board to a case I bought for my Raspberry Pi 3+.
I designed the GPIO board with a few things in mind:

- I wanted a couple of buttons so I could do things like shutting the Pi down (it's not a good idea to just unplug the power)
- I wanted a couple of LEDs so I could display a simple status
- I wanted to control the fan so it wasn't on all the time, just when it was needed (like a laptop fan)
- The piezo sounder was added because there was space - so maybe I'd be able to get the Pi to do audible notifications

_\[This was mainly for when I was running the Raspberry Pi headless - so there wouldn't be a screen or keyboard connected.\]_

This is the case with the board in it:

![RPI LED Board](/images/RPI-dotnet/GpioBoard.jpg)


I followed a few articles from the internet, [this one from Scott Hanselman][hanselman-remote-debugging] was very useful to get me started.

Click [here for more information about the board including a schematic][RPI-dotnet-hardware].

<hr/><br/>
Next: [Creating the solution in Visual Studio Code...][RPI-dotnet-software]

[RPI-dotnet-hardware]: {% link pages/RPI-dotnet/GPIOBoard-Hardware.md %}
[RPI-dotnet-software]: {% link pages/RPI-dotnet/GPIOBoard-Software.md %}

[gpio-board-github]: https://github.com/codewrite/rPiLedButtonFanBoard
[hanselman-remote-debugging]: https://www.hanselman.com/blog/RemoteDebuggingWithVSCodeOnWindowsToARaspberryPiUsingNETCoreOnARM.aspx

