FROM quay.io/fedora/fedora-bootc:42

## Install ITGMania dependencies and base system package
RUN dnf install --setopt=install_weak_deps=False -y \
	lightdm xterm xorg-x11-xinit-session unclutter-xfixes \ 
	lightdm-autologin-greeter lightdm-gobject python3-gobject \
	xorg-x11-drv-amdgpu xorg-x11-drv-intel xorg-x11-drv-qxl \
	xorg-x11-drv-ati xorg-x11-server-Xorg xorg-x11-drv-amdgpu \
	mesa-dri-drivers mesa-vulkan-drivers \
	cockpit cockpit-files cockpit-networkmanager \
	cockpit-ostree cockpit-podman \
	alsa-utils alsa-lib \
	libusb1 gtk3 pulseaudio-libs \
	libogg libvorbis  \
	mesa-libGLU libglvnd libglvnd-glx

# Download and extract game
RUN curl https://github.com/itgmania/itgmania/releases/download/v1.1.0/ITGmania-1.1.0-Linux.tar.gz \
		-Lo /opt/game.tar.gz && \
	mkdir /opt/game && \
	mv /opt/game.tar.gz /opt/game && \
	cd /opt/game && \
	tar zxvf /opt/game/game.tar.gz && \
	rm -rf /opt/game/game.tar.gz && \
	mv /opt/game/ITGmania-1.1.0-Linux/itgmania /opt/game && \
	rm -rf /opt/game/ITGmania-1.1.0-Linux

# Set Lightdm configuration
RUN useradd stepmania && \
	chown -R stepmania /opt/game && \
	systemctl enable lightdm cockpit cockpit.socket
COPY config/lightdm.conf /etc/lightdm/lightdm.conf.d/0-autologin.conf 
COPY config/kernel-params.toml /usr/lib/bootc/kargs.d/00-kernel-params.toml

# Copy extra scripts
COPY --chmod=555 scripts/xsession /home/stepmania/.xsession
COPY --chmod=555 scripts/xsession /home/stepmania/.xinitrc
COPY --chmod=555 scripts/set_vol.sh /usr/bin/set_vol.sh

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
