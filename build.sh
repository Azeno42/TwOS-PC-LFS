#!/bin/bash
# ----------------------------------------------------------------------
# TwOS PC ALPHA 0.1 BUILD SCRIPT
# This script automates all branding, application, and theming changes
# made for the Alpha 0.1 release of TwOS PC inside the Cubic chroot environment.
# ----------------------------------------------------------------------

echo "Starting TwOS PC Alpha 0.1 customization process..."

# 1. INSTALL ESSENTIAL UTILITIES
# Install Git for cloning themes and gnome-tweaks for configuration.
echo "Installing essential utilities (git, gnome-tweaks, kate)..."
apt update
apt install git gnome-tweaks kate -y
# The -y flag confirms installation without prompting the user.

# 2. BROWSER MANAGEMENT: REMOVE FIREFOX, INSTALL CHROME
echo "Removing Firefox and installing Google Chrome..."
apt remove --purge firefox firefox-locale-en firefox-locale-tr -y
apt autoremove -y

# Google Chrome (Stable Version) Installation:
# Download the .deb package
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install the package and resolve dependencies (Crucial Step!)
dpkg -i chrome.deb
apt install -f -y 

# Clean up the downloaded file
rm chrome.deb

# 3. VISUAL IDENTITY: THEMES, ICONS, AND CURSORS
# Create directories for custom assets (if they don't exist).
mkdir -p /usr/share/themes/
mkdir -p /usr/share/icons/

echo "Cloning and installing Win12X-Fantasy GTK Theme, Candy Icons, and Twilight Cursors..."

# A. Win12X-Fantasy (GTK Theme) Installation
git clone https://github.com/yeyushengfan258/Win12X-Fantasy-gtk-theme.git /tmp/Win12X
cp -r /tmp/Win12X/theme/* /usr/share/themes/
rm -rf /tmp/Win12X

# B. Candy-Icons Installation
git clone https://github.com/EliverLara/candy-icons.git /usr/share/icons/candy-icons

# C. Twilight-Cursors (Cursor Set) Installation
git clone https://github.com/yeyushengfan258/Twilight-Cursors.git /tmp/TwilightCursors
cp -r /tmp/TwilightCursors/* /usr/share/icons/
rm -rf /tmp/TwilightCursors

# 4. BRANDING: SYSTEM NAME CHANGE (GRUB, RELEASE FILES)
echo "Rebranding system identity from Ubuntu to TwOS PC..."

# a. GRUB Menu Name Change
echo 'GRUB_DISTRIBUTOR="TwOS PC"' > /etc/default/grub

# b. Release File (/etc/lsb-release)
echo 'DISTRIB_ID=TwOS-PC' > /etc/lsb-release
echo 'DISTRIB_RELEASE=0.1' >> /etc/lsb-release
echo 'DISTRIB_CODENAME=Alpha' >> /etc/lsb-release
echo 'DISTRIB_DESCRIPTION="TwOS PC Alpha 0.1 (Flower Project)"' >> /etc/lsb-release

# c. OS Release File (/etc/os-release)
# Note: We must replace the original os-release content entirely.
cat <<EOF > /etc/os-release
PRETTY_NAME="TwOS Alpha 0.1"
NAME="TwOS"
VERSION_ID="0.1"
VERSION="0.1 (Alpha)"
VERSION_CODENAME=shell
ID=twos
ID_LIKE=ubuntu
HOME_URL="https://github.com/Azeno42/TwOS-PC-LFS/tree/main"
SUPPORT_URL="https://github.com/Azeno42/TwOS-PC-LFS/tree/main"
BUG_REPORT_URL="https://github.com/Azeno42/TwOS-PC-LFS/tree/main"
LOGO=twos-logo # Updated to reflect TwOS branding
EOF

# d. Update GRUB (Note: This might fail in chroot but is necessary for documentation)
update-grub || echo "Warning: update-grub failed (expected in chroot)."

# 5. DEFAULT THEME APPLICATION (This documents the intended final state)
echo "Applying default themes (Note: This may output dconf errors in chroot)."
gsettings set org.gnome.desktop.interface gtk-theme "Win12X-Fantasy-gtk-theme"
gsettings set org.gnome.desktop.interface icon-theme "Candy-Icons"
gsettings set org.gnome.desktop.interface cursor-theme "Twilight-Cursors"

# 6. PLYMOUTH LOGO SETUP (Assuming logo is already copied to /tmp/twos-logo.png)
# This step is dependent on the manual copy but is included for completeness.
echo "Setting up Plymouth boot logo..."
if [ -f /tmp/twos-logo.png ]; then
    cp /tmp/twos-logo.png /usr/share/plymouth/themes/ubuntu-logo/ubuntu_logo.png
    # Update the script to ensure it uses the custom logo/animation settings
    sed -i 's/ubuntu_logo.png/twos_logo.png/g' /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.script
    echo "TwOS logo copied and script updated."
else
    echo "Warning: twos-logo.png not found in /tmp/. Manual logo placement needed."
fi

# 7. FINAL CLEANUP
echo "Performing final system cleanup to reduce ISO size..."
apt autoclean
apt clean
rm -rf /var/lib/apt/lists/*
rm -f /root/.bash_history
history -c
echo "Customization complete. TwOS PC Alpha 0.1 is ready for packaging."
# ----------------------------------------------------------------------
