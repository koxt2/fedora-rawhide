FROM registry.fedoraproject.org/fedora:rawhide

# Install minimal required packages - keep it slim!
RUN dnf install -y --setopt=install_weak_deps=False \
    git \
    openssh-clients \
    openssh-server \
    fedpkg \
    gcc \
    x11vnc \
    xorg-x11-server-Xvfb \
    novnc \
    openbox \
    firefox \
    websockify \
    xterm \
    vim \
    dnf5 \
    dnf5-plugins \
    && dnf clean all

# Set root password and create non-root user
RUN echo 'root:pass' | chpasswd && \
    useradd -m -G wheel,mock -s /bin/bash user && \
    echo 'user:pass' | chpasswd

# Allow mock to run inside a container:
# - disable namespace isolation (use plain chroot)
# - bind-mount host /dev into chroot so /dev/null etc. are accessible
RUN printf "config_opts['isolation'] = 'simple'\n\
config_opts['plugin_conf']['bind_mount_enable'] = True\n\
config_opts['plugin_conf']['bind_mount_opts']['dirs'].append(('/dev', '/dev'))\n\
config_opts['plugin_conf']['bind_mount_opts']['dirs'].append(('/dev/shm', '/dev/shm'))\n" \
    >> /etc/mock/site-defaults.cfg

# Expose noVNC web port (6080) and SSH (22)
EXPOSE 6080 22

# Create entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]

