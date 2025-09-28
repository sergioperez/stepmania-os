FROM quay.io/almalinuxorg/almalinux-bootc:10

# Set kernel parameters
COPY config/kernel-params.toml /usr/lib/bootc/kargs.d/00-kernel-params.toml

# TEMP: Enable crb repo
RUN sed -i '0,/^enabled=/s/^enabled=.*/enabled=1/' /etc/yum.repos.d/almalinux-crb.repo

# Install ITGMania dependencies and base system package
RUN dnf install --setopt=install_weak_deps=False -y epel-release

RUN dnf install --setopt=install_weak_deps=False -y \
	mesa-libGLU libglvnd libglvnd-glx \
	libogg libvorbis gtk3 libusb1 \
	mesa-dri-drivers mesa-vulkan-drivers \
	xorg-x11-server-Xwayland \
	cockpit cockpit-files cockpit-networkmanager \
	cockpit-ostree cockpit-podman \
	alsa-firmware alsa-utils alsa-lib \
	sddm weston

# Download and extract game
RUN curl https://github.com/itgmania/itgmania/releases/download/v1.1.0/ITGmania-1.1.0-Linux-no-songs.tar.gz \
		-Lo /opt/game.tar.gz && \
	mkdir /opt/game && \
	mv /opt/game.tar.gz /opt/game && \
	cd /opt/game && \
	tar zxvf /opt/game/game.tar.gz && \
	rm -rf /opt/game/game.tar.gz && \
	mv /opt/game/ITGmania-1.1.0-Linux-no-songs/itgmania /opt/game && \
	rm -rf "/opt/game/ITGmania-*"

# Copy launch-game script
COPY --chmod=555 scripts/launch_game.sh /opt/game/launch_game.sh

# Copy sddm config and session
COPY config/sddm.conf /etc/sddm.conf.d/sddm.conf
COPY config/itg.desktop /usr/share/wayland-sessions/itg.desktop

# Create user
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
