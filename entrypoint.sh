#!/bin/bash

# Remove X1 lock file if it exists
remove_x1_lock() {
    if [ -f /tmp/.X1-lock ]; then 
        rm /tmp/.X1-lock 
    fi
}

# Start Xvfb
start_xvfb() {
    export DISPLAY=:1 
    Xvfb :1 -ac -screen 0 1920x1080x24 & 
    sleep 5 
}


# Start Openbox
start_openbox() {
    openbox-session &
    sleep 2
    # Start xterm
    xterm -maximized &
}

# Set permissions for /dev/pts/0
set_terminal_permissions() {
    chmod a+rw /dev/pts/0
}
# Start x11vnc with clipboard support
start_x11vnc() {
    x11vnc -display :1 -nopw -listen localhost -xkb -ncache_cr -forever -shared -cursor most &
}

# Start websockify/noVNC
start_websockify() {
    websockify --web=/usr/share/novnc 6080 localhost:5900
}

# Create symlink for noVNC
create_novnc_symlink() {
    if [ ! -e /usr/share/novnc/index.html ]; then 
        ln -s /usr/share/novnc/vnc_auto.html /usr/share/novnc/index.html 
    fi
}

# Start SSH server
start_sshd() {
    # Use persistent host keys from /home so fingerprint survives restarts
    mkdir -p /home/.ssh_host_keys
    if [ ! -f /home/.ssh_host_keys/ssh_host_ed25519_key ]; then
        ssh-keygen -A --sysconf /home/.ssh_host_keys
    fi
    for key in /home/.ssh_host_keys/ssh_host_*; do
        ln -sf "$key" /etc/ssh/"$(basename $key)"
    done
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    /usr/sbin/sshd &
}

# Main script execution
main() {
    remove_x1_lock
    start_sshd
    start_xvfb
    start_openbox
    set_terminal_permissions
    start_x11vnc
    create_novnc_symlink
    start_websockify
}

# Call main
main

