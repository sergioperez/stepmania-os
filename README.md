# StepMania-OS

Kiosk operating system image to run StepMania (ITGMania).

**Note:** Do not run this yet in a public cabinet. This is currently a proof of conect - The README will be updated once the environment got better testing.

## How to install

1. Download the latest `iso` image from the `Releases` section in the repository.

2. Use a tool to write this image to an USB drive (BalenaEtcher, Rufus, or a simple `dd if=./iso of=/dev/devicehere bs=8M`).

3. Boot your PC from this device. It will take the first found volume and install StepMania-OS on it.

4. After some time, you will see ITGMania running.

5. Access your system from a web browser over `http://your-machine-ip:9090`, and change the `admin` default password (from `1234`).

6. Add songs via Cockpit, or via an SFTP client as WinSCP/Dolphin, connect to the system and add the songs under `/home/stepmania/Songs`

## Features

### As an user

- ITGMania: Open source fork for StepMania development.

- Cockpit: Allows an admin to review the system, edit/upload files, apply updates and others.

- Updates: Updates are atomic, including the game and the operating system.

- Lightweight: It contains the minimum amount of software required to run the game.

### As a project maintainer

- Fully defined as code.

- Initial install images built in a pipeline.

- Automatic updates: Pushing an image to the container registry will update the systems.

## Supported hardware

Any `x86_64` system able to run mainline Linux should be compatible.

**Note:** There is currently no support for NVidia GPUs.

## Known issues

The systemd unit `systemd-remount-fs` will appear as `failed to start`. This is a known issue covered by https://github.com/bootc-dev/bootc/issues/971. This should not have an impact in your system.

## Future goals

- Raspberry Pi and other aarch64/riscv boards. It would be possible to download an `.img`, put it in your RPI, and play.

- Integration in Simply Love: Allow upgrades over `Options` in the game. If the game fails to boot N times, run an automatic rollback.

- Index of tools on the port 443.

- Maybe move the game to a different image.

- Community - This was written to show a PoC of ITGMania + bootc, while learning on the way. There are many possible improvements to do.

