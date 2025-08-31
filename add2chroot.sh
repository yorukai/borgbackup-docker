#!/bin/sh
# Add commands + libs to a Docker chroot

CHROOT=/chroot

for cmd in "$@"; do
    if [ ! -x "$cmd" ]; then
        echo "Command $cmd not found"
        continue
    fi

    dest="$CHROOT$cmd"
    destdir=$(dirname "$dest")

    mkdir -p "$destdir"
    cp -v "$cmd" "$dest"

    # copy libraries
    ldd "$cmd" | grep -E "=> /|/ld-linux" | awk '{print $3}' | while read lib; do
        if [ -f "$lib" ]; then
            libdest="$CHROOT$lib"
            mkdir -p "$(dirname "$libdest")"
            cp -v "$lib" "$libdest"
        fi
    done
done
