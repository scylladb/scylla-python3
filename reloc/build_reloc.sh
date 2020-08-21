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
    echo "  --dest specify destination path"
    echo "  --clean clean build directory"
    echo "  --nodeps    skip installing dependencies"
    exit 1
}

CLEAN=
NODEPS=
DEST=build/scylla-python3-package.tar.gz
while [ $# -gt 0 ]; do
    case "$1" in
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
        *)
            print_usage
            ;;
    esac
done

if [ "$CLEAN" = "yes" ]; then
    rm -rf build
fi

if [ -z "$NODEPS" ]; then
    sudo ./install-dependencies.sh
fi

./SCYLLA-VERSION-GEN
mkdir -p build/python3
./dist/debian/debian_files_gen.py

PACKAGES="python3-pyyaml python3-urwid python3-pyparsing python3-requests python3-pyudev python3-setuptools python3-psutil python3-distro python3-cerberus"
./scripts/create-relocatable-package.py --output "$DEST" $PACKAGES
