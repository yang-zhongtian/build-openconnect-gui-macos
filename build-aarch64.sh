#!/usr/bin/env zsh
# this script builds OpenConnect-GUI for an Arm-based M-series Mac running at
# least macOS 12

# set build root directory
BUILD_ROOT=${BUILD_ROOT:-~/Downloads/build-openconnect-gui}

# get the current maximum amount of open file descriptors
export ULIMIT_SAVED=$(ulimit -n)

# temporarily set maximum amount of open file descriptors to 10000
ulimit -n 10000

# install homebrew for aarch64
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ensure Xcode path is set to /Applications/Xcode.app/Contents/Developer since
# Command Line Tools is installed, if it isn't already, by the Homebrew
# installation process.
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# set homebrew environment variables
eval "$(/opt/homebrew/bin/brew shellenv)"

# force homebrew to use MacOSX13.1 SDK
export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.1.sdk

# adjust the gnutls homebrew formula so that it is not configured to look in a
# specific default trust store file. this should cause the macOS access
# keychain to be used instead.
mkdir -p ${BUILD_ROOT}/rb-aarch64
brew install gnutls
cp /opt/homebrew/opt/gnutls/.brew/gnutls.rb ${BUILD_ROOT}/rb-aarch64/
sed -I '' -e '/--with-default-trust-store-file/d' ${BUILD_ROOT}/rb-aarch64/gnutls.rb
brew uninstall gnutls

# install modified gnutls formula
brew install --build-from-source --formula ${BUILD_ROOT}/rb-aarch64/gnutls.rb gnutls

# adjust qt@6 homebrew formula to force target to macOS 12.0
mkdir -p ${BUILD_ROOT}/rb-aarch64
brew install qt@6
cp /opt/homebrew/opt/qt/.brew/qt.rb ${BUILD_ROOT}/rb-aarch64/
sed -I '' -e 's/-DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}.0/-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0/' ${BUILD_ROOT}/rb-aarch64/qt.rb
brew uninstall qt@6

# install modified qt@6 formula
brew install --build-from-source --formula ${BUILD_ROOT}/rb-aarch64/qt.rb qt6

# install remaining dependencies
brew install cmake openconnect spdlog vulkan-headers pkgconfig

# get OpenConnect-GUI source code for v1.6.2
cd ${BUILD_ROOT}
git clone https://gitlab.com/openconnect/openconnect-gui.git openconnect-gui-macos12-aarch64
cd openconnect-gui-macos12-aarch64
git tag
git checkout tags/v1.6.2

# modify deployment target from 10.12 to 12.0
sed -I '' -e 's/CMAKE_OSX_DEPLOYMENT_TARGET "10.12"/CMAKE_OSX_DEPLOYMENT_TARGET "12.0"/' ${BUILD_ROOT}/openconnect-gui-macos12-aarch64/CMakeLists.txt

# configure and build
/opt/homebrew/bin/cmake .
/opt/homebrew/bin/cmake --build .

# deploy Qt frameworks and libraries to app bundle
/opt/homebrew/opt/qt/bin/macdeployqt ./bin/OpenConnect-GUI.app
curl -OL https://raw.githubusercontent.com/arl/macdeployqtfix/refs/heads/master/macdeployqtfix.py
python3 macdeployqtfix.py ./bin/OpenConnect-GUI.app /opt/homebrew/Cellar/qt/6.7.3/
cp -R /opt/homebrew/Cellar/qt/6.7.3/lib/QtDBus.framework ./bin/OpenConnect-GUI.app/Contents/Frameworks
cp /opt/homebrew/opt/dbus/lib/libdbus-1.3.dylib ./bin/OpenConnect-GUI.app/Contents/Frameworks
install_name_tool -change /opt/homebrew/opt/dbus/lib/libdbus-1.3.dylib @executable_path/../Frameworks/libdbus-1.3.dylib ./bin/OpenConnect-GUI.app/Contents/Frameworks/QtDBus.framework/Versions/A/QtDBus

# re-sign code with adhoc signature
codesign --deep --force -s - bin/OpenConnect-GUI.app

# restore saved ulimit configuration
ulimit -n $ULIMIT_SAVED
