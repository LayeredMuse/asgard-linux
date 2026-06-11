#!/usr/bin/env bash
set -oue pipefail

# 1. Download and install ScopeBuddy gaming helper
curl -Lo /usr/bin/scopebuddy https://raw.githubusercontent.com/OpenGamingCollective/ScopeBuddy/refs/heads/main/bin/scopebuddy
chmod +x /usr/bin/scopebuddy

# 2. Enable supergfxd GPU switching daemon service
systemctl enable supergfxd.service
