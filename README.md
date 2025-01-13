# Instructions for Building OpenConnect-GUI for macOS
## Introduction
The [OpenConnect-GUI](https://gui.openconnect-vpn.net) client provides a graphical interface to the OpenConnect VPN client for both macOS and Windows.

Currently, a package for the latest release of macOS is not provided. Since I wanted to use the same package on both macOS and Windows and have the latest release I decided to build the macOS package myself. Unfortunately there aren't any instructions provided and searching the web did not surface instructions by others attempting build the macOS package from source so I had to come up with something that worked for me by reading what I could find and a lot of trail and error.

The following instructions are my solution for building a universal package for OpenConnect-GUI that runs on macOS 12 and newer. Some of the complexity in getting everything to build properly was due to my desire to have the package work on macOS 12. Yes, it is EOL now but just recently so and it indicates that it supports macOS 12 so it seemed like it would be good come up with a complmentary solution. I believe if instead the package was only built to support macOS 13 and newer that a standard brew install of qt6 would suffice instead of building it from source to have a target of macOS 12.

## Environment
The build process can be done on any current macOS but I didn't want to polute my machines working environment with unnecessary complexity so I elected to use a virtual machine for my environment running using [UTM](https://mac.getutm.app).

## Install UTM and Create Virtual Machine
### Download and Install UTM
Navigate to https://mac.getutm.app to download UTM and install.

### Download IPSW File for latest macOS
Navigate to https://ipsw.me and download the latest ipsw file for macOS.

### Create VM
Create a new VM using the ipsw file that you downloaded.
Use a 100 GB size for the disk and 2 CPU cores.

### Initial VM Configuration
Once the installation of the VM is complete you will want to perform a few additional configuration steps to prepare for the build process.
#### Turn Off Screen Locks and Power Saving Features
In order to reduce things that might slow down the VM it is helpful to disable screensavers, screen locking and power saving features.

Open **Settings** and do the following:
1. Click **Battery** on the sidebar.
1. Click **Options...**.
1. Turn **On** "Prevent automatic sleeping when the display is off".
1. Click **Done**.
1. Click **Screen Saver** on the sidebar.
1. Click **Lock Screen Settings...**.
1. Set "Start Screen Saver when inactive" to Never.
1. Set "Turn display off when inactive" to Never.
1. Set "Turn display off on power adapter when inactive" to Never.
1. Set "Require password after screen saver begins or display is turned off" to Never.
1. Enter password when prompted and click **Modify Settings**.
1. Click **Turn Off Screen Lock**.

#### Give Terminal Permission to Update and Delete Other Applications
Open **Settings** and do the following:
1. Click on **Privacy & Security** on the sidebar.
1. Click on **App Management**.
1. Click **+**.
1. Navigate to _Applications_ then _Utilities_ and select _Terminal_.
1. Click **Open**.

#### Download and Install The Latest Xcode.
Note: There is a known issue that has existed for the past few years that prevents signing into the App Store from a macOS VM. Therefore, it is necessary to download Xcode directly. See:
* https://forums.developer.apple.com/forums/thread/707682
* https://forum.parallels.com/threads/cant-sign-in-to-app-store-in-macos-guest.365180
* https://github.com/utmapp/UTM/issues/3617



1. Navigate to https://xcodereleases.com.
1. Click the **Releases** radio button.
1. Click the Download link for the latest release. If prompted, log in using your Apple ID.
1. Extract downloaded .xip file by double-clicking it in Finder.
1. Move the extracted Xcode package to the _Applications_ folder.
1. Run Xcode and proceed through default setup process. (Note: There is no need to install the “Predictive Code Completion Model” if the option is checked so you can uncheck it.)

#### Download and Install macOS 13.3 SDK
1. Download Xcode 14.2 (https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_14.2/Xcode_14.2.xip)
1. Extract it by double-clicking **Xcode_14.2.xip** in the **Downloads** folder.
1. Copy SDK 13.1 SDK to Xcode SDKs directory by copying and pasting the following command into Terminal:
```
sudo cp -RP ~/Downloads/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.1.sdk
```

##### Delete Xcode.app from the Downloads folder to save space.
Note:&nbsp;&nbsp;If you are presented with the following:<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"Terminal" would like to access files in your Downloads folder.<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Click **Allow**.

Copy and paste the following command into Termina:
```
rm -rf ~/Downloads/Xcode.app
```

#### Install Rosetta 2
Copy and paste the following command into Terminal:
```
softwareupdate --install-rosetta
```

## Build Package
Keep in mind the whole process will likely take more than a day because of the amount of time it takes to build qt6 from source and the fact it needs to be done twice.

Download and run the following scripts in Terminal:
```
./build-x86_64.sh
./build-aarch64.sh
./build-universal.sh
```
