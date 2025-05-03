---
title: Quick and Easy Podman & Podman Desktop Setup on Windows 11 and Fedora
  (with GPU Support)
date: 2025-05-03 05:01:00
category: Containers
tags:
  - Podman
  - Podman Desktop
  - Windows
  - Fedora
  - GPU
slug: install-podman-desktop-windows-fedora-gpu
author: Jane Doe
summary: This guide explains how to quickly install Podman and Podman Desktop on
  Windows 11 (using Scoop) and Fedora Linux, and how to enable GPU acceleration
  for container workloads on both platforms.
---
## Introduction

Podman is a popular daemonless container engine (rootless by default) that’s compatible with Docker CLI commands and container images. Podman Desktop adds a convenient GUI for managing containers and Kubernetes, supporting both Podman and Docker under the hood. In this post, we’ll walk through the **fastest** way to install Podman and Podman Desktop on **Windows 11** and **Fedora Linux**, and then enable **GPU container access** for running GPU-accelerated workloads. Whether you prefer command-line or GUI, you’ll be up and running with containers (and even GPU support) in no time.

- - -

## Windows 11: Installing Podman & Podman Desktop (with Scoop)

**Prerequisites (Windows):** Ensure that virtualization is enabled (via BIOS) and that **WSL 2** is set up on Windows 10/11. Windows Subsystem for Linux 2 is required because Podman runs containers in a Linux environment under the hood (called a *Podman machine*, a WSL2 VM). Also make sure you have at least 6 GB of RAM available for the VM. You will need an internet connection and **administrative PowerShell** access to install software.

**Step 1: Install Scoop (if not already installed).** Scoop is a handy Windows command-line package manager. If you don’t have it, install it by running the following in PowerShell :

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

This will set the execution policy and download/run the Scoop installer script. After this, you can use the `scoop` command.

**Step 2: Add Scoop Buckets for Extras.** Podman Desktop is available in Scoop’s *extras* bucket. Enable it with: 

```powershell
scoop bucket add extras
```

You may also add the `main` bucket (usually added by default) if not already present.

**Step 3: Install Podman and Podman Desktop.** Now install both the Podman CLI and the Podman Desktop GUI using Scoop:

```powershell
scoop install podman
scoop install podman-desktop
```

This will download and install the Podman CLI and Podman Desktop applications. Scoop grabs the official Podman installer (an MSI/EXE) under the hood. Once complete, you should see confirmation that “`podman` was installed successfully” and similarly for Podman Desktop.

**Step 4: Initialize the Podman machine.** Podman needs a Linux virtual machine (WSL2 distro) to run containers on Windows. After installation, open a new PowerShell or Command Prompt and set up the default Podman machine:

```powershell
podman machine init
podman machine start
```

The `podman machine init` step will create a WSL2 VM (if WSL wasn’t already enabled, it may prompt to install it). The `podman machine start` will boot up this VM. After this, Podman is essentially ready to use. You can verify by running `podman info` or `podman ps` in PowerShell, which should communicate with the Podman VM.

Now you can launch **Podman Desktop** (there should be a Start menu shortcut or you can run `podman-desktop` from PowerShell). On first launch, Podman Desktop may guide you through any remaining setup. For example, it might prompt to initialize Podman (the machine) if you haven’t done so, or to enable WSL integration – which we already handled. Once the dashboard shows that Podman is running, you’re all set to use the GUI to manage containers. 🎉

## Windows 11: Enabling GPU Acceleration (WSL2/Podman Machine)

Running GPU-accelerated containers on Windows with Podman is now possible by leveraging NVIDIA’s WSL2 support. This allows containers to use the host’s NVIDIA GPU through the Podman machine VM. 

**Prerequisites (GPU on Windows):** You’ll need a relatively modern NVIDIA graphics card (Pascal architecture or newer) and the **latest NVIDIA GPU driver** installed on Windows. The newest drivers add WSL2 GPU support automatically, so no separate WSL-specific driver is needed. Ensure that your Podman machine (WSL2 VM) is running (`podman machine start`) and that you can SSH into it.

**Step 1: Install NVIDIA Container Toolkit inside the Podman machine.** To allow containers to access the GPU, you must install NVIDIA’s container runtime components in the Podman VM. Open a PowerShell terminal and SSH into the Podman machine with: 

```powershell
podman machine ssh
```

Once you get a shell inside the Podman machine (which is a Linux environment), run the following commands **in the Podman VM** to set up the NVIDIA Container Toolkit:

```bash
sudo curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
  -o /etc/yum.repos.d/nvidia-container-toolkit.repo

sudo yum install -y nvidia-container-toolkit

sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

These commands do the following: add the NVIDIA Container Toolkit YUM repository, install the toolkit packages, and then generate a Container Device Interface (CDI) file for the NVIDIA GPU. The generated `/etc/cdi/nvidia.yaml` tells Podman how to expose the GPU to containers. (The Podman machine is likely a Fedora-based image, hence using `yum`/RPM).

**Step 2: Verify GPU access from a container.** Back on your Windows host (you can exit the Podman machine SSH session), run a test container to ensure the GPU is recognized. For example, try running the official CUDA base image with `nvidia-smi`:

```powershell
podman run --rm --device nvidia.com/gpu=all \
  nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

If everything was set up correctly, this command (run from Windows) will launch a Linux container that has access to the GPU, and `nvidia-smi` inside the container should output your GPU details. You should see a table of GPU information (name, driver version, CUDA version, etc.) instead of an error. For instance, you might see your GeForce RTX card listed along with its memory usage, similar to the output below:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 545.36   Driver Version: 546.33   CUDA Version: 12.3             |
|-----------------------------------------------------------------------------|
| GPU  Name        Persistence-M| Bus-Id       Disp.A | Volatile Uncorr. ECC  |
| 0    NVIDIA ...                                                Off   ...   |
|-----------------------------------------------------------------------------|
```

If you get a result from `nvidia-smi` inside the container, congratulations! Your Podman containers on Windows now have GPU acceleration enabled. (If you encounter errors like `Failed to initialize NVML`, it could mean a version mismatch; regenerating the CDI file and restarting the Podman machine can fix that.)

## Fedora Linux: Installing Podman & Podman Desktop

**Prerequisites (Fedora):** Ensure you have a Fedora Linux system with internet access and privileges to install packages (sudo). If you plan to use GPU, you’ll need an NVIDIA GPU and drivers installed on Fedora as well (more on that in the GPU section). On Fedora Workstation, Podman CLI is typically **pre-installed** by default, but we will verify and install Podman Desktop.

**Step 1: Install Podman CLI (if needed).** On Fedora 37/38 and newer, Podman is included out-of-the-box. You can check by running `podman --version`. If it’s not installed for some reason (for example on a minimal installation), install it via DNF:

```bash
sudo dnf install -y podman
```

This will fetch the latest stable Podman release from Fedora’s repositories. (If Podman was already present, this ensures it’s up-to-date.)

**Step 2: Install Podman Desktop GUI.** The easiest way on Fedora is to use **Flatpak** (Fedora supports Flatpak and this avoids manual downloading). Podman Desktop is available on Flathub, so enable Flathub if you haven’t already, then install the app:

```bash
# Enable Flathub (if not already enabled)
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Podman Desktop from Flathub
flatpak install --user -y flathub io.podman_desktop.PodmanDesktop
```

This will download the Podman Desktop Flatpak and install it for your user. Once complete, you can launch Podman Desktop from your application menu (it might appear after a logout/login if it’s the first flatpak app installed). You can also run it via command line: `flatpak run io.podman_desktop.PodmanDesktop`.

On first launch, Podman Desktop should detect your local Podman installation. Since Fedora’s Podman is already running on the host (no VM needed, as Linux can run containers natively), the Podman engine tile on the dashboard should show as running. You can now use the GUI to manage containers, images, pods, etc., on Fedora directly.

## Fedora Linux: Enabling GPU Acceleration for Containers

If you have an NVIDIA GPU on your Fedora system, you can enable your containers to use it for CUDA/OpenCL workloads. This requires installing the NVIDIA Container Toolkit on Fedora (similar to the Windows steps, but directly on the host).

**Prerequisites (GPU on Fedora):** Ensure you have installed the proprietary NVIDIA driver on Fedora (the open-source Nouveau driver likely won’t support CUDA). Typically this is done via RPM Fusion or the official NVIDIA package. Verify that `nvidia-smi` works on your host OS before proceeding.

**Step 1: Install NVIDIA Container Toolkit on Fedora.** NVIDIA provides a repository with the required packages. Run the following commands in a terminal:

```bash
# Add the NVIDIA Container Toolkit repository for RPM packages
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
  sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# Install the toolkit package
sudo dnf install -y nvidia-container-toolkit
```

This sets up the YUM/DNF repo and installs the `nvidia-container-toolkit` package which includes `nvidia-ctk` and configuration files.

**Step 2: Generate the GPU CDI configuration.** After installation, create the Container Device Interface spec for your GPU:

```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

This command generates `/etc/cdi/nvidia.yaml` describing the NVIDIA GPU resources. It’s a one-time setup (though you should re-run it if you update drivers or change GPU configuration).

**Step 3: Test a GPU-enabled container.** Similar to Windows, you can test on Fedora by running a GPU-utilizing container. For example:

```bash
podman run --rm --device nvidia.com/gpu=all \
  nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

Since you’re on Linux, this command can be run directly on the host. If configured correctly, you’ll see output from `nvidia-smi` showing your GPU inside the container. This means GPU acceleration is working. If you instead see an error (or no devices found), double-check that the `nvidia-container-toolkit` service/hook is active. You might need to reboot or at least log out/in to ensure Podman picks up the new CDI config. You can also list the CDI devices with `nvidia-ctk cdi list` to confirm it recognizes your GPU.

Now you’re ready to run AI/ML or other GPU-hungry workloads in Podman containers on Fedora!

## Conclusion

In this tutorial, we set up Podman and Podman Desktop on both Windows 11 and Fedora Linux in just a few steps. Using Scoop on Windows streamlines the installation of Podman CLI and the desktop GUI, while Flatpak makes it effortless on Fedora. We also enabled GPU support so that containerized applications can utilize your NVIDIA GPU on each platform, following official guidelines. 

With Podman Desktop, you now have a user-friendly interface to manage your containers, images, and pods across environments. On Windows, Podman Desktop will manage a Linux VM behind the scenes to give you a seamless container experience, and on Fedora it works natively with the host Podman. You can pull images, run containers (even with CUDA for ML tasks), and even deploy Kubernetes pods right from the dashboard. 

Enjoy your Docker-free container workflows! Podman’s daemonless design and Podman Desktop’s convenient GUI are ready to boost your productivity in container management. Happy container hacking! 🚀

## Reference Documentation

<li><a href="https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-yum-or-dnf">NVIDIA Container Toolkit Installation Guide</a></li>
<li><a href="https://podman-desktop.io/docs/podman/gpu?form=MG0AV3">Podman Desktop GPU Support Documentation</a></li>
