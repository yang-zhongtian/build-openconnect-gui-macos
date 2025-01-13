#!/usr/bin/env zsh
# this script constructs a universal build of OpenConnect-GUI for both Intel
# and Arm based Macs running at least macOS 12.

# create base for universal package using aarch64 package
mkdir -p ~/Downloads/build-openconnect-gui/openconnect-gui-macos12-universal/bin
cd ~/Downloads/build-openconnect-gui
cp -pR openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app openconnect-gui-macos12-universal/bin/

# create universal version of main binary
lipo -create openconnect-gui-macos12-x86_64/bin/OpenConnect-GUI.app/Contents/MacOS/OpenConnect-GUI openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app/Contents/MacOS/OpenConnect-GUI  -output openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app/Contents/MacOS/OpenConnect-GUI

# create universal versions of Qt frameworks included in package
lipo -create openconnect-gui-macos12-x86_64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtCore.framework/Versions/A/QtCore openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtCore.framework/Versions/A/QtCore -output openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app/Contents/Frameworks/QtCore.framework/Versions/A/QtCore
lipo -create openconnect-gui-macos12-x86_64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtDBus.framework/Versions/A/QtDBus openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtDBus.framework/Versions/A/QtDBus -output openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app/Contents/Frameworks/QtDBus.framework/Versions/A/QtDBus
lipo -create openconnect-gui-macos12-x86_64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtGui.framework/Versions/A/QtGui openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtGui.framework/Versions/A/QtGui -output openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app/Contents/Frameworks/QtGui.framework/Versions/A/QtGui
lipo -create openconnect-gui-macos12-x86_64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtNetwork.framework/Versions/A/QtNetwork openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtNetwork.framework/Versions/A/QtNetwork -output openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app/Contents/Frameworks/QtNetwork.framework/Versions/A/QtNetwork
lipo -create openconnect-gui-macos12-x86_64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtStateMachine.framework/Versions/A/QtStateMachine openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtStateMachine.framework/Versions/A/QtStateMachine -output openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app/Contents/Frameworks/QtStateMachine.framework/Versions/A/QtStateMachine
lipo -create openconnect-gui-macos12-x86_64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtWidgets.framework/Versions/A/QtWidgets openconnect-gui-macos12-aarch64/bin/OpenConnect-GUI.app/Contents/Frameworks/QtWidgets.framework/Versions/A/QtWidgets -output openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app/Contents/Frameworks/QtWidgets.framework/Versions/A/QtWidgets

# create universal versions of dynamic libraries included in package
cd ~/Downloads/build-openconnect-gui/openconnect-gui-macos12-universal/bin
find . -name \*\.dylib | xargs -I{} lipo -create ~/Downloads/build-openconnect-gui/openconnect-gui-macos12-x86_64/bin/{} ~/Downloads/build-openconnect-gui/openconnect-gui-macos12-aarch64/bin/{} -output {}
cd -

# re-sign code with adhoc signature
codesign --deep --force -s - openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app

# touch package to update date
touch ~/Downloads/build-openconnect-gui/openconnect-gui-macos12-universal/bin/OpenConnect-GUI.app
