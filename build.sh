#!/bin/bash
clear
echo "#########################################"
echo "##### LOUP Kernel - Build Script ########"
echo "#########################################"

# Make statement declaration
# ==========================
# If compilation uses menuconfig, make operation will use .config 
# instead of santoni_defconfig directly.
MAKE_STATEMENT=make

# ENV configuration
# =================
export LOUP_WORKING_DIR=$(dirname "$(pwd)")


# Menuconfig configuration
# ================
# If -no-menuconfig flag is present we will skip the kernel configuration step.
# Make operation will use santoni_defconfig directly.
if [[ "$*" == *"-no-menuconfig"* ]]
then
  NO_MENUCONFIG=1
  MAKE_STATEMENT="$MAKE_STATEMENT KCONFIG_CONFIG=./arch/arm64/configs/santoni_defconfig"
fi


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
    echo -e "\n\033[0;31m> Cleaning $LOUP_WORKING_DIR/.ccache contents\033[0;0m" 
    rm -rf "$LOUP_WORKING_DIR/.ccache"
  fi
  # If you want to build *without* using ccache
  # run this script with -no-ccache flag
  if [[ "$*" != *"-no-ccache"* ]] 
  then
    export USE_CCACHE=1
    export CCACHE_DIR="$LOUP_WORKING_DIR/.ccache"
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
CROSS_COMPILE=$LOUP_WORKING_DIR/aarch64-linux-android-7.x/bin/aarch64-linux-android-


# Want to use clang?
# ==================
# Use -clang flag to compile the kernel using clang instead of gcc
# Point CC to the folder of the desired clang binary
if [[ "$*" == *"-clang"* ]]
then
  USE_CLANG=1
  CC=$LOUP_WORKING_DIR/sdclang-4.0/bin/clang
  CLANG_TRIPLE=aarch64-linux-gnu-
  echo -e "\033[0;36m> Compiling kernel using CLANG\033[0;0m\n"
else
  echo -e "\033[0;34m> Compiling kernel using GCC\033[0;0m\n"
fi


# Are we using ccache?
if [ -n "$USE_CCACHE" ] 
then
  if [ -n "$USE_CLANG" ]
  then
  CC="ccache $CC"
  else
  CROSS_COMPILE="ccache $CROSS_COMPILE"  
  fi
fi

# Start menuconfig
# ================
# Use -no-menuconfig flag to skip the kernel configuration step.
# It will override any .config file present.
if [ -n "$NO_MENUCONFIG" ]
then
  echo -e "> Skipping menuconfig...\n"
  echo -e "> Starting kernel compilation using santoni_defconfig file directly...\n"
else
  if [ -f ".config" ]
  then    
    echo -e "\033[0;32m> Config file already exists\033[0;0m\n"
  else
    echo -e "\033[0;31m> Config file not found, copying santoni_defconfig as .config...\033[0;0m\n" 
    cp arch/arm64/configs/santoni_defconfig .config
  fi
  echo -e "> Opening .config file...\n"
  ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE make menuconfig
  echo -e "> Starting kernel compilation using .config file...\n"
fi

start=$SECONDS

# Want custom kernel flags?
# =========================
# KBUILD_LOUP_CFLAGS: Here you can set custom compilation 
# flags to turn off unwanted warnings, or even set a 
# different optimization level. 
# To see how it works, check the Makefile ... file, 
# line 645 to 648, located in the root dir of this kernel.
if [ -n "$USE_CLANG" ]
then
  KBUILD_LOUP_CFLAGS="-Wno-vectorizer-no-neon -Wno-pointer-sign -Wno-sometimes-uninitialized -Wno-tautological-constant-out-of-range-compare -mtune=cortex-a53 -march=armv8-a+crc+simd+crypto -mcpu=cortex-a53 -O2"
  make -j5 ARCH=arm64 CC="$CC" CLANG_TRIPLE="$CLANG_TRIPLE" CROSS_COMPILE="$CROSS_COMPILE" KBUILD_LOUP_CFLAGS="$KBUILD_LOUP_CFLAGS"
else
  KBUILD_LOUP_CFLAGS="-Wno-misleading-indentation -Wno-bool-compare -mtune=cortex-a53 -march=armv8-a+crc+simd+crypto -mcpu=cortex-a53 -O2"
  KBUILD_LOUP_CFLAGS=$KBUILD_LOUP_CFLAGS ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE $MAKE_STATEMENT -j5
fi

# Get current kernel version
LOUP_VERSION=$(cat .config | grep -P "^(CONFIG_LOCALVERSION)" | grep -oP "(\d+\.)?(\d+\.)?(\*|\d+)")
echo -e "\n\n> Packing Loup Kernel v$LOUP_VERSION\n\n"
# Pack the kernel as a flashable TWRP zip. Nougat Edition
$LOUP_WORKING_DIR/AnyKernel2/build.sh $LOUP_VERSION N Ōkami

end=$SECONDS
duration=$(( end - start ))
printf "\n\033[0;33m> Completed in %dh:%dm:%ds\n" $(($duration/3600)) $(($duration%3600/60)) $(($duration%60))
echo -e "=====================================\033[0;0m\n"
