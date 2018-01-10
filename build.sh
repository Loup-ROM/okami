#!/bin/bash
clear
echo "#########################################"
echo "##### LOUP Kernel - Build Script ########"
echo "#########################################"


# CCACHE configuration
# ====================
# If you want you can install ccache to speedup recompilation time.
# In ubuntu just run "sudo apt-get install ccache".
# By default CCACHE will use 2G, change the value of CCACHE_MAX_SIZE
# to meet your needs.
if [ -x "$(command -v ccache)" ]
then
  # If you want to clean the ccache
  # run this script with -clear-ccache
  if [[ "$*" == *"-clear-ccache"* ]]
  then
    echo -e "\n\033[0;31m> Cleaning ~/.ccache contents\033[0;0m" 
    rm -rf ~/.ccache
  fi
  # If you want to build *without* using ccache
  # run this script with -no-ccache flag
  if [[ "$*" != *"-no-ccache"* ]] 
  then
    export USE_CCACHE=1
    export CCACHE_DIR=~/.ccache
    export CCACHE_MAX_SIZE=2G
    echo -e "\n> $(ccache -M $CCACHE_MAX_SIZE)"
    echo -e "\n\033[0;32m> Using ccache, to disable it run this script with -no-ccache\033[0;0m\n"
  else
    echo -e "\n\033[0;31m> NOT Using ccache, to enable it run this script without -no-ccache\033[0;0m\n"
  fi
else
  echo -e "\n\033[0;33m> [Optional] ccache not installed. You can install it (in ubuntu) using 'sudo apt-get install ccache'\033[0;0m\n"
fi

# Want to use a different toolchain? (Linaro, UberTC, etc)
# ==================================
# point CROSS_COMPILE to the folder of the desired toolchain
# don't forget to specify the prefix. Mine is: aarch64-linux-android-
CROSS_COMPILE=../aarch64-linux-android-6.x/bin/aarch64-linux-android-

# Are we using ccache?
if [ -n "$USE_CCACHE" ] 
then
  CROSS_COMPILE="ccache $CROSS_COMPILE"  
fi

# Start menuconfig
echo -e "\n> Opening .config file..."
ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE make menuconfig

echo -e "> Starting kernel compilation using .config file...\n"
start=$SECONDS

# Want custom kernel flags?
# =========================
# KBUILD_LOUP_CFLAGS: Here you can set custom compilation 
# flags to turn off unwanted warnings, or even set a 
# different optimization level. 
# To see how it works, check the Makefile ... file, 
# line 625 to 628, located in the root dir of this kernel.
KBUILD_LOUP_CFLAGS="-Wno-misleading-indentation -Wno-bool-compare -mtune=cortex-a53 -march=armv8-a+crc+simd+crypto -mcpu=cortex-a53 -O2" 
KBUILD_LOUP_CFLAGS=$KBUILD_LOUP_CFLAGS ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE make -j5

# Get current kernel version
LOUP_VERSION=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')
echo -e "\n\n> Packing Loup Kernel v$LOUP_VERSION\n\n"
# Pack the kernel as a flashable TWRP zip. Nougat Edition
./../AnyKernel2/build.sh $LOUP_VERSION N

end=$SECONDS
duration=$(( end - start ))
printf "\n\033[0;33m> Completed in %dh:%dm:%ds\n" $(($duration/3600)) $(($duration%3600/60)) $(($duration%60))
echo -e "=====================================\n"
