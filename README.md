# Ōkami :wolf:

Ōkami kernel is a custom project based on my [own source](https://github.com/bitrvmpd/msm-3.18) for the **Redmi 4X (santoni)**.

- CAF based.
- Up to date with linux stable 3.18 (EOL).
- Nougat and Oreo support.
- Include [patches for clang](https://github.com/bitrvmpd/okami/pull/1) and [gcc 4.9+ support](https://github.com/bitrvmpd/msm-3.18/pull/18).
- WireGuard support.
- F2FS / NTFS / [exFat](https://github.com/dorimanx/exfat-nofuse).
- Energy Aware Scheduler - EAS.
- Fingerprint boost driver.
- Undervolted.

## Want to compile it?

#### Execute:
`./build.sh` for using gcc **or** `./build.sh -clang` to compile it using clang.

#### Dependencies
- Any GCC toolchain.
- Clang (google clang, sdclang, etc).
- [AnyKernel2](https://github.com/bitrvmpd/AnyKernel2).
- [Setup](https://forum.xda-developers.com/chef-central/android/how-to-build-lineageos-14-1-t3551484) your env.

#### Remarks
If you want to use clang you need a gcc toolchain too. [More info](https://github.com/nathanchance/android-kernel-clang).
