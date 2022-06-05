#!/bin/bash -e
#
# Copyright (C) 2019 ScyllaDB
#

# SPDX-License-Identifier: Apache-2.0

print_usage() {
    echo "build_reloc.sh --dest build/scylla-python3-package.tar.gz"
    echo "  --packages specify python3 packages to be add on relocatable package"
    echo "  --pip-packages specify pip packages to be add on relocatable package"
    echo "  --pip-symlinks specify pip provided commands which need to install to /usr/bin"
    echo "  --dest specify destination path"
    echo "  --clean clean build directory"
    echo "  --nodeps    skip installing dependencies"
    echo "  --version V  product-version-release string (overriding SCYLLA-VERSION-GEN)"
    exit 1
}

PACKAGES=
PIP_PACKAGES=
PIP_SYMLINKS=
CLEAN=
NODEPS=
VERSION_OVERRIDE=
while [ $# -gt 0 ]; do
    case "$1" in
        "--packages")
            PACKAGES="$2"
            shift 2
            ;;
        "--pip-packages")
            PIP_PACKAGES="$2"
            shift 2
            ;;
        "--pip-symlinks")
            PIP_SYMLINKS="$2"
            shift 2
            ;;
        "--dest")
            DEST=$2
            shift 2
            ;;
        "--clean")
            CLEAN=yes
            shift 1
            ;;
        "--nodeps")
            NODEPS=yes
            shift 1
            ;;
        "--version")
            VERSION_OVERRIDE="$2"
            shift 2
            ;;
        *)
            print_usage
            ;;
    esac
done

VERSION=$(./SCYLLA-VERSION-GEN ${VERSION_OVERRIDE:+ --version "$VERSION_OVERRIDE"})
# the former command should generate build/SCYLLA-PRODUCT-FILE and some other version
# related files
PRODUCT=`cat build/SCYLLA-PRODUCT-FILE`
DEST=build/$PRODUCT-python3-$(arch)-package.tar.gz

if [ "$CLEAN" = "yes" ]; then
    rm -rf build
fi

if [ -z "$NODEPS" ]; then
    sudo ./install-dependencies.sh
fi

./SCYLLA-VERSION-GEN ${VERSION_OVERRIDE:+ --version "$VERSION_OVERRIDE"}
echo "$PIP_SYMLINKS" > build/SCYLLA-PYTHON3-PIP-SYMLINKS-FILE
mkdir -p build/python3
./dist/debian/debian_files_gen.py

./scripts/create-relocatable-package.py --output "$DEST" --modules $PACKAGES --pip-modules $PIP_PACKAGES
