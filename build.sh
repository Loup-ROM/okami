#!/bin/bash
echo "#########################################"
echo "##### LOUP Kernel - Build Script ########"
echo "#########################################"
echo ""
echo "> Opening .config file..."

# Want to use a different toolchain? (Linaro, UberTC, etc)
# ==================================
# point CROSS_COMPILE to the folder of the desired toolchain
# don't forget to specify the prefix. Mine is: aarch64-linux-android-
ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=../aarch64-linux-android-6.x/bin/aarch64-linux-android- make menuconfig

echo "> Starting kernel compilation using .config file..."
# Want custom kernel flags?
# =========================
# KBUILD_LOUP_CFLAGS: Here you can set custom compilation 
# flags to turn off unwanted warnings, or even set a 
# different optimization level. 
# To see how it works, check the Makefile ... file, 
# line 625 to 628, located in the root dir of this kernel.
KBUILD_LOUP_CFLAGS="-Wno-misleading-indentation -Wno-bool-compare -mtune=cortex-a53 -march=armv8-a+crc+simd+crypto -mcpu=cortex-a53 -O2" ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=../aarch64-linux-android-6.x/bin/aarch64-linux-android- make -j5
echo ""

# Pack the kernel as a flashable TWRP zip.
./../AnyKernel2/build.sh
echo "DONE!"
