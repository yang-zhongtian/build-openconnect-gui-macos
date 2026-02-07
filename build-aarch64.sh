#!/usr/bin/env zsh
# this script builds OpenConnect-GUI for an Arm-based M-series Mac running at
# least macOS 12

# set build root directory
BUILD_ROOT=${BUILD_ROOT:-~/Downloads/build-openconnect-gui}

# get the current maximum amount of open file descriptors
export ULIMIT_SAVED=$(ulimit -n)

# temporarily set maximum amount of open file descriptors to 10000
ulimit -n 10000



# adjust the gnutls homebrew formula so that it is not configured to look in a
# specific default trust store file. this should cause the macOS access
# keychain to be used instead.
mkdir -p ${BUILD_ROOT}/rb-aarch64
# Ensure gnutls is installed to get the formula
if ! brew list gnutls &>/dev/null; then
    brew install gnutls
fi
cp /opt/homebrew/opt/gnutls/.brew/gnutls.rb ${BUILD_ROOT}/rb-aarch64/
sed -I '' -e '/--with-default-trust-store-file/d' ${BUILD_ROOT}/rb-aarch64/gnutls.rb

# uninstall gnutls ignoring dependencies to allow reinstallation from source
brew uninstall --ignore-dependencies gnutls

# Create a local tap to install modified formulae
brew tap-new local/taps 2>/dev/null || true
cp ${BUILD_ROOT}/rb-aarch64/gnutls.rb $(brew --repository local/taps)/Formula/gnutls.rb

# install modified gnutls formula from local tap
brew install --build-from-source local/taps/gnutls

# adjust qt@6 homebrew formula to force target to macOS 12.0
mkdir -p ${BUILD_ROOT}/rb-aarch64
if ! brew list qt@6 &>/dev/null; then
    brew install qt@6
fi
cp /opt/homebrew/opt/qt/.brew/qt.rb ${BUILD_ROOT}/rb-aarch64/
sed -I '' -e 's/-DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}.0/-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0/' ${BUILD_ROOT}/rb-aarch64/qt.rb

# uninstall qt@6 ignoring dependencies
brew uninstall --ignore-dependencies qt@6

# install modified qt formula from local tap
cp ${BUILD_ROOT}/rb-aarch64/qt.rb $(brew --repository local/taps)/Formula/qt.rb
brew install --build-from-source local/taps/qt

# Clean up tap
brew untap local/taps

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
