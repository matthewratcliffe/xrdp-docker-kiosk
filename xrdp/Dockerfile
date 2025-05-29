FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV USERNAME=kiosk
ENV PASSWORD=kiosk

# Copy your run script and set permissions
COPY ./build/docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

# Create user
RUN useradd -m -s /bin/bash ${USERNAME} \
 && echo "${USERNAME}:${PASSWORD}" | chpasswd \
 && passwd -l root \
 && deluser ${USERNAME} sudo || true

# Copy kiosk launcher and desktop autostart entry
COPY ./build/kiosk-launcher.sh /home/${USERNAME}/kiosk-launcher.sh

RUN mkdir -p /home/${USERNAME}/.config/autostart && \
    printf "[Desktop Entry]\nType=Application\nName=Browser Kiosk\nExec=/home/%s/kiosk-launcher.sh\nX-GNOME-Autostart-enabled=true\n" "${USERNAME}" \
    > /home/${USERNAME}/.config/autostart/browser-kiosk.desktop
    
# Create xbindkeys config to allow Ctrl+Alt+Q to exit Firefox
RUN mkdir -p /home/${USERNAME}/.config/autostart && \
    echo "\"bash /home/${USERNAME}/kill.sh\"\n  Control+Alt + q " > /home/${USERNAME}/.xbindkeysrc && \
    chmod +x /home/${USERNAME}/kiosk-launcher.sh && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/

RUN printf '#!/bin/bash\npkill -f kiosk-launcher.sh\npkill -f firefox\n' > /home/${USERNAME}/kill.sh \
    && chmod +x /home/${USERNAME}/kill.sh 

# Create Desktop shortcut to start kiosk
RUN mkdir -p /home/${USERNAME}/Desktop && \
    printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Start Kiosk\nComment=Launch the Firefox Kiosk\nExec=/home/%s/kiosk-launcher.sh\nIcon=firefox\nTerminal=false\nCategories=Utility;\n' "${USERNAME}" > /home/${USERNAME}/Desktop/start-kiosk.desktop && \
    chmod +x /home/${USERNAME}/Desktop/start-kiosk.desktop && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/Desktop

RUN chmod +x /home/${USERNAME}/Desktop/start-kiosk.desktop && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/Desktop

# Install XFCE, Firefox, and supporting tools
RUN install -d -m 0755 /etc/apt/keyrings && \
    apt-get update &&  \
    apt-get install -y wget ca-certificates --no-install-recommends && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
    echo "deb [trusted=yes] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | tee /etc/apt/preferences.d/mozilla && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-taskmanager \
    xfce4-terminal \
    dbus-x11 \
    sudo \
    xorgxrdp \
    xrdp \
    xbindkeys \
    fonts-liberation \
    libappindicator3-1 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxss1 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-xcb1 \
    libxshmfence1 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libegl1 \
    libepoxy0 \
    libdbus-glib-1-2 \
    libfontconfig1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libatk1.0-0 \
    libdrm2 \
    libxfixes3 \
    nano \
    libpci-dev \
    libcanberra-gtk3-module \
    libgles2-mesa-dev \
    libnss3-tools \
    firefox && \
    apt-get clean && \
    apt remove -y light-locker xscreensaver && \
    apt autoremove -y && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

# Expose RDP port
EXPOSE 3389

# Set entrypoint
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]