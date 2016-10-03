#!/bin/sh

export CROSS_COMPILE=/home/anas/S7/sabermod/bin/aarch64-
export KCONFIG_NOTIMESTAMP=true
export ARCH=arm64
export SUBARCH=arm64

VER="\"-GoogyMax-S7_MM_v$1\""
cp -f /home/anas/S7/Kernel/arch/arm64/configs/googymax-s7_defconfig /home/anas/S7/googymax-s7_defconfig
sed "s#^CONFIG_LOCALVERSION=.*#CONFIG_LOCALVERSION=$VER#" /home/anas/S7/googymax-s7_defconfig > /home/anas/S7/Kernel/arch/arm64/configs/googymax-s7_defconfig

find -name '*.ko' -exec rm -rf {} \;

rm -f /home/anas/S7/Kernel/arch/arm64/boot/Image*.*
rm -f /home/anas/S7/Kernel/arch/arm64/boot/.Image*.*
make googymax-s7_defconfig || exit 1

make -j4 || exit 1

mkdir -p /home/anas/S7/Release/system/lib/modules
rm -rf /home/anas/S7/Release/system/lib/modules/*
find -name '*.ko' -exec cp -av {} /home/anas/S7/Release/system/lib/modules/ \;
${CROSS_COMPILE}strip --strip-unneeded /home/anas/S7/Release/system/lib/modules/*

./tools/dtbtool -o /home/anas/S7/Out/dt.img -s 4096 -p ./scripts/dtc/ arch/arm64/boot/dts/

cd /home/anas/S7/Out
./packimg.sh

cd /home/anas/S7/Release
zip -r ../GoogyMax-S7_Kernel_MM_${1}.zip .

adb push /home/anas/S7/GoogyMax-S7_Kernel_MM_${1}.zip /sdcard/GoogyMax-S7_Kernel_MM_${1}.zip

adb kill-server

echo "GoogyMax-S7_Kernel_${1}.zip READY !"
