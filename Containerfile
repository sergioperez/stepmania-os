FROM quay.io/fedora/fedora-bootc:43

# Set kernel parameters
COPY config/kernel-params.toml /usr/lib/bootc/kargs.d/00-kernel-params.toml

# Workaround to allow hotplugging a monitor
COPY config/99-monitor-hotplug.rules /etc/udev/rules.d

# Install ITGMania dependencies and base system packages
RUN dnf install --setopt=install_weak_deps=False -y \
	mesa-libGLU libglvnd libglvnd-glx \
	libogg libvorbis gtk3 libusb1 \
	mesa-dri-drivers mesa-vulkan-drivers \
	xorg-x11-server-Xwayland \
	cage wlr-randr \
	cockpit cockpit-files cockpit-networkmanager \
	cockpit-ostree cockpit-podman \
	alsa-firmware alsa-utils alsa-lib \
	pulseaudio-libs \
	bc

# Download and extract game
RUN curl https://github.com/itgmania/itgmania/releases/download/v1.2.1/ITGmania-1.2.1-Linux-no-songs.tar.gz \
		-Lo /opt/game.tar.gz && \
	mkdir /opt/game && \
	mkdir /opt/game/scripts && \
	mv /opt/game.tar.gz /opt/game && \
	cd /opt/game && \
	tar zxvf /opt/game/game.tar.gz && \
	rm /opt/game/game.tar.gz && \
	mv /opt/game/ITGmania-1.2.1-Linux-no-songs/itgmania /opt/game && \
	rm -rf /opt/game/ITGmania-*

# Copy cockpit plugin
COPY --chown=0:0 --chmod=555 config/cockpit /usr/share/cockpit

# Copy launch-game and helper scripts
COPY --chmod=555 scripts/launch_game.sh /opt/game/launch_game.sh
COPY --chmod=555 scripts/video /opt/game/scripts/video
COPY --chmod=555 scripts/audio /opt/game/scripts/audio

# Set sudoer rules for cockpit
COPY --chmod=600 config/sudoers-extra /etc/sudoers.d/

# Setup cage to autostart itgmania
COPY config/pam /etc/pam.d/stepmania
COPY config/cage@.service /etc/systemd/system/cage@.service
RUN ln -s /etc/systemd/system/cage@.service /etc/systemd/system/graphical.target.wants/cage@tty1.service
RUN ln -s /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

# Create user - Make /home/stepmania rwX for admin
RUN useradd stepmania && \
	chown -R stepmania /opt/game

# Enable cockpit for network admin
RUN systemctl enable cockpit cockpit.socket

# Extra cockpit configuration
COPY --chmod=644 config/cockpit-disallowed /etc/cockpit/disallowed-users

# Set game configuration
USER stepmania
RUN mkdir -p /home/stepmania/.itgmania/Save && \
	mkdir /home/stepmania/Songs
COPY config/Preferences.ini /home/stepmania/.itgmania/Save/Preferences.ini

USER root

# Cleanup and check
RUN dnf clean all && \ 
	bootc container lint
