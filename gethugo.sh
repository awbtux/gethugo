#!/bin/sh

# setup script for the hugo env

# function to ensure a command is available
has() {
    [ -n "$1" ] && {
        command -v "$1" >/dev/null 2>&1 && {
            return 0
        } || return 1
    } || return 2
}

# function to run a command as root if needed
authorize() {
    case "${EUID:-${UID:-$(id -u)}}" in
        0) eval "$@" ;;
        *) eval "$elev \"$@\"" ;;
    esac
}

# set the permission elevator
for i in "su -c" doas sudo; do
    has ${i%% *} && elev="$i"
done

# set the package install command
for i in "emerge --quiet --ask=n --color=n" "yum install" "dnf install" "zypper install" "apt install" "apk add" "pacman -S" "xbps-install"; do
    has ${i%% *} && pkgm="$i"
done

# install hugo if required
if ! has hugo; then
    authorize $pkgm hugo || exit 2
fi

# install git if required
if ! has git; then
    authorize $pkgm hugo || exit 2
fi

# clone submodules
git submodule update --init --recursive

# we're done
exit 0
