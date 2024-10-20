#!/bin/bash

# build_linapple_appimage.sh
# chmod +x build_linapple_appimage.sh
# ./build_linapple_appimage.sh

# Install necessary dependencies
sudo apt update
sudo apt install -y libzip-dev file appstream desktop-file-utils git fuse

# Create necessary directories
mkdir -p ~/apple

# Download linapple source code
cd ~/apple || exit
if [ ! -d "linapple" ]; then
    git clone https://github.com/linappleii/linapple.git
fi

# Build linapple
cd linapple || exit
make clean
make -j$(nproc)

# Prepare AppDir structure
mkdir -p ~/apple/appdir/usr/bin
mkdir -p ~/apple/appdir/usr/share/icons/hicolor/128x128/apps

# Copy necessary files
echo "Copying linapple binary..."
cp ~/apple/linapple/build/bin/linapple ~/apple/appdir/usr/bin/

# Create .desktop file in the correct location
echo "Creating desktop entry..."
cat > ~/apple/appdir/linapple.desktop <<EOL
[Desktop Entry]
Name=LinApple
Comment=Apple II Emulator
Exec=linapple
Icon=linapple
Terminal=false
Type=Application
Categories=Game;
EOL

# Download icon
echo "Downloading icon..."
wget -O ~/apple/appdir/usr/share/icons/hicolor/128x128/apps/linapple.png https://files.softicons.com/download/system-icons/apple-logo-icons-by-thvg/png/128/Apple%20logo%20icon%20-%20Classic.png

# Copy the icon to the root of AppDir
cp ~/apple/appdir/usr/share/icons/hicolor/128x128/apps/linapple.png ~/apple/appdir/linapple.png

# Validate desktop file
desktop-file-validate ~/apple/appdir/linapple.desktop

# Create AppStream metadata
desktop-file-validate ~/apple/appdir/linapple.desktop

# Create AppStream metadata
echo "Creating AppStream metadata..."
cat << EOF > ~/apple/appdir/usr/share/metainfo/linapple.appdata.xml
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop">
  <id>com.linapple.app</id>
  <name>LinApple</name>
  <summary>Apple II Emulator</summary>
  <description>LinApple is an emulator for the Apple II computer.</description>
  <launch>
    <executable>linapple</executable>
  </launch>
  <category>Games</category>
  <screenshots>
    <image type="snapshot">linapple.png</image>
  </screenshots>
  <license>MIT</license>
</component>
EOF

# Validate AppStream metadata
appstreamcli validate ~/apple/appdir/usr/share/metainfo/linapple.appdata.xml

# Download AppImage tool
if [ ! -f ~/apple/appimagetool-x86_64.AppImage ]; then
    echo "Downloading appimagetool..."
    wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O ~/apple/appimagetool-x86_64.AppImage
    chmod +x ~/apple/appimagetool-x86_64.AppImage
fi

# Create the AppImage
echo "Creating AppImage..."
ARCH=x86_64 ~/apple/appimagetool-x86_64.AppImage ~/apple/appdir

# Move the resulting AppImage to the same directory as the script
# mv ~/apple/linapple/LinApple-x86_64.AppImage "$(dirname "$0")/LinApple-x86_64.AppImage"

echo "LinApple-x86_64.AppImage creation complete, look for it in /apple/linapple/ dir"
