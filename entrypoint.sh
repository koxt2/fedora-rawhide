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

# Main script execution
main() {
    remove_x1_lock
    start_xvfb
    start_openbox
    set_terminal_permissions
    start_x11vnc
    create_novnc_symlink
    start_websockify
}

# Call main
main

