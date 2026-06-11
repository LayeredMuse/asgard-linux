# Asgard Linux

Asgard Linux is a repository for building custom, bootable OCI container OS images using [BlueBuild](https://blue-build.org/) (built on top of [bootc](https://github.com/bootc-dev/bootc)), built on top of **Universal Blue's Aurora DX** (Fedora KDE). 

This operating system is designed to provide a premium, modern developer experience out-of-the-box, using the **Catppuccin Mocha Mauve** design system, custom wallpapers, robust hardware configurations, and built-in developer tools.

---

## Two Image Variants

We publish two distinct container image versions to support different hardware configurations:

1.  **`asgard-linux` (Nvidia + Gaming)**
    *   **Base**: `ghcr.io/ublue-os/aurora-dx-nvidia-open:stable`
    *   **Features**: Tailored for hybrid dGPU/iGPU laptops (like ASUS ROG/TUF). Includes open-source Nvidia kernel drivers, GPU switching utilities, steam client, and game launchers.
2.  **`asgard-linux-base` (General Intel/AMD)**
    *   **Base**: `ghcr.io/ublue-os/aurora-dx:stable`
    *   **Features**: A lighter, cleaner version for standard general laptops or desktops. Excludes GPU switcher, Nvidia drivers, and gaming launcher packages.

---

## Core Features

*   **Design System**: Styled system-wide with **Catppuccin Mocha Mauve** (automatically applied to KDE Plasma 6 desktop elements, native Qt apps, synced GTK widgets, SDDM login screen, and Starship prompt).
*   **Starship Shell Prompt**: Installs the custom Catppuccin Mauve-styled Starship prompt and integrates shell hooks natively into global Zsh.
*   **Google Antigravity Developer Suite**: 
    *   **Google Antigravity (Desktop App)**: Standalone desktop app (installed to `/opt/antigravity`).
    *   **Antigravity IDE**: Standalone IDE (installed to `/opt/antigravity-ide`).
    *   **Antigravity CLI**: Dynamically installed system-wide (`agy` / `antigravity-cli`).
*   **Native Applications**: 
    *   **Google Chrome** (RPM-native, replacing Floorp).
    *   **KeePassXC** (RPM-native, replacing Proton Pass).
*   **GPU Switching & Gaming (Nvidia variant only)**:
    *   **supergfxctl**: Native command-line dGPU/iGPU manager.
    *   **supergfxctl-plasmoid**: System applet widget built from source on Fedora 6.x Plasma libraries for visual graphics switching.
    *   **Game Launchers**: Steam, Lutris, Heroic Games Launcher, ProtonUp-Qt, gamescope, and gamemode.
    *   **ScopeBuddy**: Custom gaming session helper from Open Gaming Collective.
*   **Flatpak Preinstalls**: System-level preinstall definitions for Bazaar Store, OBS Studio, Discord, Plexamp, Feishin, Obsidian, Gnome Apostrophe, Nicotine+, Haruna Video Player, and Kamoso Camera.
*   **Hardware and Power Management**: Tailscale and Thermald services enabled by default. Custom lid-switch settings (suspend on lid close, lock if connected to external power), and disabled Wi-Fi power savings for network stability.

---

## Local Build and Development

The repository includes a `Justfile` to automate building, testing, and running your custom images locally using **Podman** and **QEMU**.

### Build Container Images Locally
*   Build the Nvidia image:
    ```bash
    just build
    ```
*   Build the non-Nvidia base image:
    ```bash
    just build-base
    ```

### Generate Installer ISOs Locally
To build a bootable installer ISO using `bootc-image-builder`:
*   Build Nvidia installer ISO:
    ```bash
    just build-iso
    ```
*   Build non-Nvidia base installer ISO:
    ```bash
    just build-iso-base
    ```
> [!NOTE]
> ISO build commands require root privileges (`sudo`) to mount loopback devices and construct the image. Output files are placed in `output/bootiso/install.iso`.

### Run and Test the ISO in a Local VM
Boot your locally compiled installer ISO inside a containerized QEMU instance to test the Anaconda installation screen:
*   Run the VM:
    ```bash
    just run-vm-iso
    ```
The VM display is routed to `http://localhost:8006` in your web browser.

---

## GitHub Actions CI/CD Pipeline

The repository includes two automated workflows under `.github/workflows/`:

1.  **`build.yml` (Container Images)**
    *   Runs on every git push to `main` and on pull requests.
    *   Builds both `asgard-linux` and `asgard-linux-base` container images in parallel matrix jobs, publishes them to GHCR, and signs them with your Cosign key.
2.  **`build-disk.yml` (Disk & ISO Images)**
    *   Manual dispatch or pull request trigger on config edits.
    *   Compiles bootable installation ISOs and virtual machine QCOW2 disks for both variants.
    *   Provides manual toggles (`build-qcow2` and `build-iso`) to skip build steps and save GitHub Action runtime minutes.
    *   Uploads output artifacts uniquely named as: `${{ matrix.disk-type }}-${{ matrix.image-variant }}-${{ inputs.platform }}`.
