#!/bin/bash -e
#
# Copyright (C) 2019 ScyllaDB
#

#
# This file is part of Scylla.
#
# Scylla is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Scylla is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scylla.  If not, see <http://www.gnu.org/licenses/>.
#

print_usage() {
    echo "build_reloc.sh --dest build/scylla-python3-package.tar.gz"
    echo "  --packages specify python3 packages to be add on relocatable package"
    echo "  --pip-packages specify pip packages to be add on relocatable package"
    echo "  --dest specify destination path"
    echo "  --clean clean build directory"
    echo "  --nodeps    skip installing dependencies"
    echo "  --version V  product-version-release string (overriding SCYLLA-VERSION-GEN)"
    exit 1
}

PACKAGES=
PIP_PACKAGES=
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
mkdir -p build/python3
./dist/debian/debian_files_gen.py

./scripts/create-relocatable-package.py --output "$DEST" --modules $PACKAGES --pip-modules $PIP_PACKAGES
