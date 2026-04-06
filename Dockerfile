FROM registry.fedoraproject.org/fedora:rawhide

# Install minimal required packages - keep it slim!
RUN dnf install -y --setopt=install_weak_deps=False \
    git \
    openssh-clients \
    openssh-server \
    fedpkg \
    x11vnc \
    xorg-x11-server-Xvfb \
    novnc \
    openbox \
    firefox \
    websockify \
    xterm \
    vim \
    && dnf clean all

# Create non-root user
RUN useradd -m -s /bin/bash user && \
    echo 'user:pass' | chpasswd

# Expose noVNC web port (6080) and SSH (22)
EXPOSE 6080 22

# Create entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]

