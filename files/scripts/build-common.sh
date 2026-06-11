#!/usr/bin/env bash
set -oue pipefail

# 1. Configure default shell to Zsh for useradd
if [ -f /etc/default/useradd ]; then
    sed -i 's|^SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd
else
    mkdir -p /etc/default
    echo "SHELL=/bin/zsh" > /etc/default/useradd
fi

# 2. Download and install SDDM Catppuccin theme
git clone --depth 1 https://github.com/catppuccin/sddm.git /tmp/catppuccin-sddm
mkdir -p /usr/share/sddm/themes
cp -r /tmp/catppuccin-sddm/src /usr/share/sddm/themes/catppuccin-mocha
rm -rf /tmp/catppuccin-sddm

# 3. Download and install KDE Catppuccin color schemes
curl -Lo /tmp/Mocha-color-schemes.tar.gz https://github.com/catppuccin/kde/releases/download/v0.2.6/Mocha-color-schemes.tar.gz
mkdir -p /usr/share/color-schemes
tar -xzf /tmp/Mocha-color-schemes.tar.gz -C /usr/share/color-schemes/
rm -f /tmp/Mocha-color-schemes.tar.gz

# 4. Set Catppuccin Mocha Mauve color scheme as default in Aurora Look and Feel themes
for defaults_file in /usr/share/plasma/look-and-feel/dev.getaurora.aurora.desktop/contents/defaults \
                    /usr/share/plasma/look-and-feel/dev.getaurora.auroralight.desktop/contents/defaults; do
    if [ -f "$defaults_file" ]; then
        sed -i 's|ColorScheme=.*|ColorScheme=CatppuccinMochaMauve|' "$defaults_file"
    fi
done

# 5. Overwrite default system wallpaper files with Asgard wallpaper
if [ -f /usr/share/backgrounds/asgard/desktop.jpg ]; then
    # Overwrite the active Aurora wallpaper file
    mkdir -p /usr/share/backgrounds/aurora/aurora-wallpaper-12/contents/images
    cp /usr/share/backgrounds/asgard/desktop.jpg /usr/share/backgrounds/aurora/aurora-wallpaper-12/contents/images/3840x2160.jxl

    # Replace the main default.jxl and default-dark.jxl symlinks directly with our wallpaper
    rm -f /usr/share/backgrounds/default.jxl
    rm -f /usr/share/backgrounds/default-dark.jxl
    cp /usr/share/backgrounds/asgard/desktop.jpg /usr/share/backgrounds/default.jxl
    cp /usr/share/backgrounds/asgard/desktop.jpg /usr/share/backgrounds/default-dark.jxl
fi

# 6. Download and install Google Antigravity Suite (Hub, IDE, CLI) dynamically

# Resolve latest download URLs
echo "Fetching latest Antigravity component versions..."
HUB_URL=$(curl -sL https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/manifest/latest-x64-linux.yml | grep -o 'https://storage.googleapis.com/antigravity-public/antigravity-hub/[^/]\+/linux-x64/Antigravity.AppImage' | sed 's/Antigravity.AppImage/Antigravity.tar.gz/' | head -n 1)
IDE_URL=$(curl -sL https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update/linux-x64/stable/latest | jq -r '.url')
CLI_URL=$(curl -sL https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_amd64.json | jq -r '.url')

echo "Latest Hub URL: $HUB_URL"
echo "Latest IDE URL: $IDE_URL"
echo "Latest CLI URL: $CLI_URL"

# Antigravity Desktop App (Hub)
mkdir -p /opt/antigravity
curl -Lo /tmp/Antigravity.tar.gz "$HUB_URL"
tar -xzf /tmp/Antigravity.tar.gz -C /opt/antigravity --strip-components=1
ln -sf /opt/antigravity/antigravity /usr/bin/antigravity
rm -f /tmp/Antigravity.tar.gz

# Antigravity IDE
mkdir -p /opt/antigravity-ide
curl -Lo /tmp/AntigravityIDE.tar.gz "$IDE_URL"
tar -xzf /tmp/AntigravityIDE.tar.gz -C /opt/antigravity-ide --strip-components=1
ln -sf /opt/antigravity-ide/antigravity-ide /usr/bin/antigravity-ide
rm -f /tmp/AntigravityIDE.tar.gz

# Antigravity CLI
mkdir -p /tmp/antigravity-cli
curl -Lo /tmp/cli_linux_x64.tar.gz "$CLI_URL"
tar -xzf /tmp/cli_linux_x64.tar.gz -C /tmp/antigravity-cli
cp /tmp/antigravity-cli/antigravity /usr/bin/agy
chmod +x /usr/bin/agy
ln -sf /usr/bin/agy /usr/bin/antigravity-cli
# Run setup
/usr/bin/agy install || true
rm -rf /tmp/cli_linux_x64.tar.gz /tmp/antigravity-cli

# 7. Append custom Zsh configuration system-wide
if [ -f /etc/zshrc_append ]; then
    cat /etc/zshrc_append >> /etc/zshrc
    rm -f /etc/zshrc_append
fi
