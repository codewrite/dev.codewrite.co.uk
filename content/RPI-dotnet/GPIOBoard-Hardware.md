---
title: "GPIO Board Hardware"
draft: true
---

> Prev: [Dotnet Core on Raspberry Pi Main Page][RPI-dotnet-mainPage]
<hr/><br/>

The schematic for the board is:

![RPI LED Board](/images/RPI-dotnet/GpioBoard-Schematic.png)

Where the components are as shown here:

![RPI LED Board](/images/RPI-dotnet/GpioBoard-Legend.jpg)

Some points to note:

- The switch inputs (GPIO24 and GPIO23) would be set as pulled up inputs so that they would normally read HIGH and then go LOW when the button was pressed.
- The signal on GPIO4 to control the fan is a 3.3V signal whereas the fan needs a 5V supply to run at full speed.
- GPIO19 is one of the hardware PWM channels. The audio output also uses this so they can't be used at the same time.

<hr/>
Prev: [Dotnet Core on Raspberry Pi Main Page][RPI-dotnet-mainPage]

[RPI-dotnet-mainPage]: {% post_url raspberrypi/2020-04-15-RasperryPiAndDotnet %}

