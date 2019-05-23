#!/bin/sh

# Build kernel module
mkdir -p /home/darling/build
cd /home/darling/build
cmake ..
cp /home/darling/src/startup/rtsig.h /home/darling/build/src/startup/
sudo make lkm -j"$(nproc)"
sudo make lkm_install
sudo xz -d /lib/modules/$(uname -r)/extra/darling-mach.ko.xz

# Try to unload any existing darling modules
sudo rmmod darling-mach.ko

# Load new module
sudo insmod /lib/modules/$(uname -r)/extra/darling-mach.ko

# Work around existing overlayfs
sudo mount -t tmpfs tmpfs /home/darling

# Setup darling env
darling shell < /usr/local/bin/darling-setup.sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	exec "$@"
fi
