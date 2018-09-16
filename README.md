Jadeite
====

Jadeite is a graphical user interface/IDE for GemStone/S 64 Bit development. Jadeite is a Dolphin-based Smalltalk application that runs on Microsoft Windows. It allows login to a GemStone Smalltalk Repository in which the Rowan tools are loaded, to allow project and package management, code development, and debugging.

Jadeite is based on the Jade Smalltalk project developed by James Foster, built in (and inspired by) Dolphin Smalltalk from [Object-Arts](https://github.com/dolphinsmalltalk/Dolphin).

### Runtime Installation
To install Jadeite runtime, download the zip file with the executable and supporting libraries from [here](https://github.com/GemTalk/Jadeite/releases).  Once you have the environment, you can generally download just the latest jadeite.exe executable.

The runtime directory contains the jadeite.exe, README.md, and /bin and /icons directories. 

On Windows, create a directory for Jadeite, and copy the contents of the runtime directory to this directory. You can now execute jadeite.exe.  No updates to the OS path or %GEMSTONE% environment variable are required. 

Jadeite can only log into a GemStone/S 64 Bit GemStone repository that has Rowan installed. The GemStone server is not supported on Windows;  server platforms other than Linux have not been tested.
For GemStone installation, see [GemStone 3.2.x Installation instructions](https://downloads.gemtalksystems.com/docs/GemStone64/3.2.x/GS64-InstallGuide-Linux-3.2.6/GS64-InstallGuide-Linux-3.2.6.htm). 

Once you have installed base GemStone and started a NetLDI, you must install Rowan.
Rowan is provided [here](https://github.com/GemTalk/Rowan/releases).



