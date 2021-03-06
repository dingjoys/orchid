#!/bin/bash
set -e
set -o pipefail

sysroot=$1
shift 1

rm -rf "${sysroot}"
mkdir -p "${sysroot}"
cd "${sysroot}"

function rpm() {
    curl -s http://vault.centos.org/6.0/os/x86_64/Packages/"$1".el6.x86_64.rpm | rpm2cpio - | cpio -i
    find . -type d ! -perm 755 -exec chmod 755 {} +
}

rpm filesystem-2.4.30-2.1
rpm kernel-headers-2.6.32-71
rpm glibc-2.12-1.7
rpm glibc-headers-2.12-1.7
rpm glibc-devel-2.12-1.7
rpm libgcc-4.4.4-13
rpm gcc-4.4.4-13
rpm libstdc++-devel-4.4.4-13

find . -lname '/*' -print0 | while read -r -d $'\0' link; do
    temp=(${link//\// })
    temp=${temp[@]//*/..}
    temp=${temp// /\/}
    temp=${temp#../../}
    temp=${temp}$(readlink "${link}")
    rm -f "${link}"
    ln -svf "${temp}" "${link}"
done
