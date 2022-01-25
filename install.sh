#!/bin/bash
#
# Copyright (C) 2019 ScyllaDB
#

# SPDX-License-Identifier: AGPL-3.0-or-later

set -e

print_usage() {
    cat <<EOF
Usage: install.sh [options]

Options:
  --root /path/to/root     alternative install root (default /)
  --prefix /prefix         directory prefix (default /usr)
  --nonroot                shortcut of '--disttype nonroot'
  --help                   this helpful message
EOF
    exit 1
}

root=/
nonroot=false

while [ $# -gt 0 ]; do
    case "$1" in
        "--root")
            root="$2"
            shift 2
            ;;
        "--prefix")
            prefix="$2"
            shift 2
            ;;
        "--nonroot")
            nonroot=true
            shift 1
            ;;
        "--help")
            shift 1
	    print_usage
            ;;
        *)
            print_usage
            ;;
    esac
done

if [ -z "$prefix" ]; then
    if $nonroot; then
        prefix=~/scylladb
    else
        prefix=/opt/scylladb
    fi
fi

rprefix=$(realpath -m "$root/$prefix")

install -d -m755 "$rprefix"/python3/bin
cp -r ./bin/* "$rprefix"/python3/bin
install -d -m755 "$rprefix"/python3/lib64
cp -r ./lib64/* "$rprefix"/python3/lib64
install -d -m755 "$rprefix"/python3/libexec
cp -r ./libexec/* "$rprefix"/python3/libexec
install -d -m755 "$rprefix"/python3/licenses
cp -r ./licenses/* "$rprefix"/python3/licenses
