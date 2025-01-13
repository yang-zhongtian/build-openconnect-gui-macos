# Instructions for Building OpenConnect-GUI for macOS
## Introduction
The <a href="https://gui.openconnect-vpn.net" target="_blank">OpenConnect-GUI</a> client provides a graphical interface to the OpenConnect VPN client for both macOS and Windows.

Currently, a package for the latest release of macOS is not provided. Since I wanted to use the same package on both macOS and Windows and have the latest release I decided to build the macOS package myself. Unfortunately there aren't any instructions provided and searching the web did not surface instructions by others attempting build the macOS package from source so I had to come up with something that worked for me by reading what I could find and a lot of trail and error.

The following instructions are my solution for building a universal package for OpenConnect-GUI that runs on macOS 12 and newer. Some of the complexity in getting everything to build properly was due to my desire to have the package work on macOS 12. Yes, it is EOL now but just recently so and it indicates that it supports macOS 12 so it seemed like it would be good come up with a complmentary solution. I believe if instead the package was only built to support macOS 13 and newer that a standard brew install of qt6 would suffice instead of building it from source to have a target of macOS 12.

## Environment
The build process can be done on any current macOS but I didn't want to polute my machines working environment with unnecessary complexity so I elected to use a virtual machine for my environment running using <a href="https://mac.getutm.app/" target="_blank">UTM</a>.

Install UTM
Create VM using latest macOS ipsw from https://ipsw.me
Use 100GB for the disk size. (note: this could potentially be smaller)
Use 2 CPU cores.
In Settings:
* turn on "Prevent automatic sleeping when the display is off".
* set "Start Screen Saver when inactive" to Never.
* set "Turn display off when inactive" to Never.
* set "Require password after screen saver begins or display is turned off." to "Never" and turn off Lock Screen in the process.

Download and Install latest Xcode.
Note:	I had to download outside the App Store at https://developer.apple.com/download/all/ since for some reason the App Store would not allow me to sign in using my account.
In that case I extracted the .xip file by double-clicking and then moved the Xcode app package to the Applications folder.
This is a known issue.  See:
	•	https://forums.developer.apple.com/forums/thread/707682
	•	https://forum.parallels.com/threads/cant-sign-in-to-app-store-in-macos-guest.365180
	•	https://github.com/utmapp/UTM/issues/3617


Run Xcode and proceed through default setup process.
Note:	There is no need to install the “Predictive Code Completion Model” if the option is checked so you can uncheck it.

Give Terminal Permissions to Update and Delete Other Applications
===================================================
Open Settings.
Click on Privacy & Security.
Click on App Management.
Click +.
Navigate to Applications then Utilities and select Terminal. Click Open.
Exit Settings.

Install macOS 13.3 SDK
===================
# Download Xcode 14.2 (https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_14.2/Xcode_14.2.xip)
# Extract it double-clicking Xcode_14.2.xip
# Copy SDK 13.1 SDK to Xcode SDKs directory
sudo cp -RP ~/Downloads/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.1.sdk

# Delete Xcode.app from the Downloads folder to save space.
# Note:  If you are presented with the following:
#             "Terminal" would like to access files in your Downloads folder.
#         Click Allow.
rm -rf ~/Downloads/Xcode.app

Install Rosetta 2
============
softwareupdate --install-rosetta

