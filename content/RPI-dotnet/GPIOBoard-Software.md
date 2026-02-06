---
title: "GPIO Board Software"
draft: true
---

> Prev: [Dotnet Core on Raspberry Pi][RPI-dotnet-mainPage]
> 
> Next: [Building and running the App...][RPI-dotnet-build-and-run]
<hr/><br/>

<p style="float:left;margin-right:30px">

![VS Code Folders](/images/RPI-dotnet/VSCodeFolders.png)

</p>

This was the projects that I created for the solution. There are three projects *LEDButtonApp*, *LEDButtonLib* and *LEDButtonLibTests*.
The other files *tasks.json*, *launch.json* and *publish.ps1* are scripts to build, publish (to the Raspberry Pi), and run the code. The remaining items are *.gitignore* for git and *Doc* which is where I would store all the documentation for GitHub.

<div style="clear:both"></div>

# LedButtonApp
This is the main executable. I decided to do this as a console app.

# LedButtonLib
This is the library with the code that interfaces with the board.

# LedButtonLibTests
I decided to write a set of unit tests for the library.

<hr/>

You can find [the source here][gpio-board-github], but here are a few notes:

- The console app uses commandlineparser to make things easier. This project is pretty straightforward.
- The LedButtonLib uses the [.NET Core IoT Libraries][dotnet-iot] which seem very well written and maintained.
- I decided to have separate classes for the LEDs, buttons (and eventually fan and piezo) and it became apparent that I needed a base class (CustomController) which has all the construction and disposal code.
- The tests use mocking ([Moq][moq]). I couldn't mock the GpioController, so I mocked the GpioDevice instead. To do this I had to use the Protected method in Moq.

<hr/><br/>
Prev: [Main Page][RPI-dotnet-mainPage]<br/><br/>
Next: [Building and running the App...][RPI-dotnet-build-and-run]

[RPI-dotnet-build-and-run]: {% link pages/RPI-dotnet/GPIOBoard-BuildAndRun.md %}
[RPI-dotnet-mainPage]: {% post_url raspberrypi/2020-04-15-RasperryPiAndDotnet %}

[gpio-board-github]: https://github.com/codewrite/rPiLedButtonFanBoard
[dotnet-iot]: https://github.com/dotnet/iot
[moq]: https://github.com/Moq/moq4/wiki/Quickstart
