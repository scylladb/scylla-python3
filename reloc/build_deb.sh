#!/bin/bash -e

. /etc/os-release
print_usage() {
    echo "build_deb.sh --reloc-pkg build/scylla-python3-package.tar.gz"
    echo "  --reloc-pkg specify relocatable package path"
    echo "  --builddir specify debuild directory"
    exit 1
}

PRODUCT=$(cat build/SCYLLA-PRODUCT-FILE)
SCYLLA_VERSION=$(cat build/SCYLLA-VERSION-FILE)
SCYLLA_RELEASE=$(cat build/SCYLLA-RELEASE-FILE)

RELOC_PKG=build/$PRODUCT-python3-package.tar.gz
BUILDDIR=build/debian
while [ $# -gt 0 ]; do
    case "$1" in
        "--reloc-pkg")
            RELOC_PKG=$2
            shift 2
            ;;
        "--builddir")
            BUILDDIR="$2"
            shift 2
            ;;
        *)
            print_usage
            ;;
    esac
done

if [ ! -e $RELOC_PKG ]; then
    echo "$RELOC_PKG does not exist."
    echo "Run ./reloc/build_reloc.sh first."
    exit 1
fi
RELOC_PKG=$(readlink -f $RELOC_PKG)
BUILDDIR=$(readlink -f "$BUILDDIR")
rm -rf "$BUILDDIR"/scylla-python3-package
mkdir -p "$BUILDDIR"/scylla-python3-package
tar -C "$BUILDDIR"/scylla-python3-package -xpf "$RELOC_PKG"
cd "$BUILDDIR"/scylla-python3-package


RELOC_PKG_FULLPATH=$(readlink -f $RELOC_PKG)
RELOC_PKG_BASENAME=$(basename $RELOC_PKG)

ln -fv $RELOC_PKG_FULLPATH ../$PRODUCT-python3_$SCYLLA_VERSION-$SCYLLA_RELEASE.orig.tar.gz

mv scylla-python3/debian debian
debuild -rfakeroot -us -uc
