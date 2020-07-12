#!/bin/bash
clear
echo "#######################################"
echo "##### OKAMI Kernel - Build Script #####"
echo "#######################################"

# ENV configuration
# =================
if [ -z "$LOUP_WORKING_DIR" ]
then
  export LOUP_WORKING_DIR=$(dirname "$(pwd)")
fi

# Create "out" dir to avoid compilation issues
mkdir -p $(pwd)/out

start=$SECONDS

# Want custom kernel flags?
# =========================
# KBUILD_LOUP_CFLAGS: Here you can set custom compilation 
# flags to turn off unwanted warnings, or even set a 
# different optimization level. 
# To see how it works, check the Makefile ... file, 
# line 625 to 628, located in the root dir of this kernel.
KBUILD_OKAMI_CFLAGS="-mtune=cortex-a53 -march=armv8-a+crc+simd+crypto -mcpu=cortex-a53 -O2"

make menuconfig O=out ARCH=arm64
PATH="/home/wuff/projects/misc/proprietary_vendor_qcom_sdclang-8.0_linux-x86/bin:/home/wuff/projects/misc/aarch64_linux_gnu-gcc/bin:/home/wuff/projects/misc/arm_linux_gnueabi-gcc/bin:${PATH}" \
make -j8 O=out \
	ARCH=arm64 \
	SUBARCH=arm64 \
	CC=clang \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE=aarch64-linux-gnu- \
	CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	KBUILD_OKAMI_CFLAGS="$KBUILD_OKAMI_CFLAGS"

if [ $? -eq 0 ]
then
  # Get current kernel version
  LOUP_VERSION=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')
  echo -e "\n\n> Packing Ōkami Kernel v$LOUP_VERSION\n\n"
  # Pack the kernel as a flashable TWRP zip. Nougat Edition
  $LOUP_WORKING_DIR/AnyKernel3/build.sh $LOUP_VERSION 10 Ōkami

  end=$SECONDS
  duration=$(( end - start ))
  printf "\n\033[0;33m> Completed in %dh:%dm:%ds\n" $(($duration/3600)) $(($duration%3600/60)) $(($duration%60))
  echo -e "=====================================\033[0;0m\n"
else
  echo -e "\033[0;31m> Compilation failed, exiting...\033[0;0m\n"
  exit 1
fi
