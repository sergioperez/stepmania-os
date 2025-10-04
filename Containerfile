# Build cage - Not available on repos
FROM quay.io/almalinuxorg/almalinux:10 AS dependencies

RUN dnf install --setopt=install_weak_deps=False -y epel-release
RUN dnf install --setopt=install_weak_deps=False -y cmake wlroots-devel wayland-protocols-devel scdoc git meson gcc
RUN cd /tmp && \
        git clone https://github.com/cage-kiosk/cage.git --single-branch --branch v0.2.0 && \
        cd cage && \
        meson setup build && \
        meson compile -C build

RUN cd /tmp && \
        git clone https://gitlab.freedesktop.org/emersion/wlr-randr.git --single-branch --branch v0.5.0 && \
        cd wlr-randr && \
        meson setup build && \
	ninja -C build

FROM quay.io/almalinuxorg/almalinux-bootc:10

# Copy cage
COPY --from=0 /tmp/cage/build/cage /usr/bin/cage
COPY --from=0 /tmp/wlr-randr/build/wlr-randr /usr/bin/wlr-randr

# Set kernel parameters
COPY config/kernel-params.toml /usr/lib/bootc/kargs.d/00-kernel-params.toml

# Enable EPEL and CRB
RUN dnf install --setopt=install_weak_deps=False -y epel-release && \
	dnf install --setopt=install_weak_deps=False dnf-plugins-core -y && \
	dnf config-manager --set-enabled crb

# Install ITGMania dependencies and base system package
RUN dnf install --setopt=install_weak_deps=False -y \
	mesa-libGLU libglvnd libglvnd-glx \
	libogg libvorbis gtk3 libusb1 \
	mesa-dri-drivers mesa-vulkan-drivers \
	xorg-x11-server-Xwayland \
	cockpit cockpit-files cockpit-networkmanager \
	cockpit-ostree cockpit-podman \
	alsa-firmware alsa-utils alsa-lib \
	wlroots bc \
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
COPY --chmod=555 scripts/check_new_screen.sh /opt/game/check_new_screen.sh
COPY --chmod=555 scripts/outputs_to_main_res.sh /opt/game/outputs_to_main_res.sh

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
