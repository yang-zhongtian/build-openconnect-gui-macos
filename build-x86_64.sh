#!/usr/bin/env zsh
# this script builds OpenConnect-GUI for an Intel-based Mac running at least macOS 12

# get the current maximum amount of open file descriptors
export ULIMIT_SAVED=$(ulimit -n)

# temporarily set maximum amount of open file descriptors to 10000
ulimit -n 10000

# install homebrew for x86_84
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ensure Xcode path is set to /Applications/Xcode.app/Contents/Developer since
# Command Line Tools is installed, if it isn't already, by the Homebrew
# installation process.
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# set homebrew environment variables
eval "$(/usr/local/bin/brew shellenv)"

# force homebrew to use MacOSX13.1 SDK
export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.1.sdk

# create working directory
mkdir -p ~/Downloads/build-openconnect-gui

# adjust the gnutls homebrew formula so that it is not configured to look in a
# specific default trust store file. this should cause the macOS access
# keychain to be used instead.
mkdir -p ~/Downloads/build-openconnect-gui/rb-x86_64
brew install gnutls
cp /usr/local/opt/gnutls/.brew/gnutls.rb ~/Downloads/build-openconnect-gui/rb-x86_64/
sed -I '' -e '/--with-default-trust-store-file/d' ~/Downloads/build-openconnect-gui/rb-x86_64/gnutls.rb
brew uninstall gnutls

# install modified gnutls formula
brew install --build-from-source --formula ~/Downloads/build-openconnect-gui/rb-x86_64/gnutls.rb gnutls

# adjust qt@6 homebrew formula to force target to macOS 12.0
mkdir -p ~/Downloads/build-openconnect-gui/rb-x86_64
brew install qt@6
cp /usr/local/opt/qt/.brew/qt.rb ~/Downloads/build-openconnect-gui/rb-x86_64/
sed -I '' -e 's/-DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}.0/-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0/' ~/Downloads/build-openconnect-gui/rb-x86_64/qt.rb
brew uninstall qt@6

# install modified qt@6 formula
# note: this can take a really long time. on a VM it took around 16-18 hours.
brew install --build-from-source --formula ~/Downloads/build-openconnect-gui/rb-x86_64/qt.rb qt6

# install remaining dependencies
brew install cmake openconnect spdlog vulkan-headers pkgconfig

# get OpenConnect-GUI source code for v1.6.2
cd ~/Downloads/build-openconnect-gui
git clone https://gitlab.com/openconnect/openconnect-gui.git openconnect-gui-macos12-x86_64
cd openconnect-gui-macos12-x86_64
git tag
git checkout tags/v1.6.2

# modify deployment target from 10.12 to 12.0
sed -I '' -e 's/CMAKE_OSX_DEPLOYMENT_TARGET "10.12"/CMAKE_OSX_DEPLOYMENT_TARGET "12.0"/' ~/Downloads/build-openconnect-gui/openconnect-gui-macos12-x86_64/CMakeLists.txt

# configure and build
cmake .
cmake --build .

# deploy Qt frameworks and libraries to app bundle
macdeployqt ./bin/OpenConnect-GUI.app
curl -OL https://raw.githubusercontent.com/arl/macdeployqtfix/refs/heads/master/macdeployqtfix.py
python3 macdeployqtfix.py ./bin/OpenConnect-GUI.app /usr/local/Cellar/qt/6.7.3/
cp -R /usr/local/Cellar/qt/6.7.3/lib/QtDBus.framework ./bin/OpenConnect-GUI.app/Contents/Frameworks
cp /usr/local/opt/dbus/lib/libdbus-1.3.dylib ./bin/OpenConnect-GUI.app/Contents/Frameworks
arch -x86_64 install_name_tool -change /usr/local/opt/dbus/lib/libdbus-1.3.dylib @executable_path/../Frameworks/libdbus-1.3.dylib ./bin/OpenConnect-GUI.app/Contents/Frameworks/QtDBus.framework/Versions/A/QtDBus

# re-sign code with adhoc signature
arch -x86_64 codesign --deep --force -s - bin/OpenConnect-GUI.app

# restore saved ulimit configuration
ulimit -n $ULIMIT_SAVED

