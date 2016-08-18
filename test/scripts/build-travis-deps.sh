#!/bin/sh

if test "x$TRAVIS_BUILD_DIR" = "x"; then
   echo "TRAVIS_BUILD_DIR must be defined"
   exit 1
fi

if test "x$PREFIX" = "x"; then
   echo "PREFIX must be defined in the environment"
   exit 1
fi

set -e

BUILDSH="$TRAVIS_BUILD_DIR/modular/build.sh --clone"

git clone git://anongit.freedesktop.org/git/xorg/util/modular

# modular insists that the directory already exist.
mkdir $PREFIX
$BUILDSH -o util/macros

# Build faster-moving proto packages here.  Wouldn't it be nice if
# we didn't have separate proto packages?  (or, even better, if we
# just used XCB protos)
$BUILDSH -o proto/compositeproto
$BUILDSH -o proto/dri2proto
$BUILDSH -o proto/dri3proto
$BUILDSH -o proto/presentproto
$BUILDSH -o proto/x11proto

# Always build XCB, which gets us a bunch of the latest protos/libs.
$BUILDSH -o xcb/proto
$BUILDSH -o xcb/libxcb
$BUILDSH -o xcb/util
$BUILDSH -o xcb/util-renderutil
$BUILDSH -o xcb/util-image

# pixman is a significant part of our implementation.  Always use master.
$BUILDSH -o pixman

# Add a couple of recently-released packages.
$BUILDSH -o lib/libxshmfence
$BUILDSH -o lib/libXfont

# bdftopcf (used by xtest) in the system is a victim of
# https://bugzilla.redhat.com/show_bug.cgi?id=1241939
(cd lib/libXfont && git checkout libXfont-1.5.2 && make install)
$BUILDSH -o app/bdftopcf

$BUILDSH -o app/rendercheck

# Build current Mesa.
$BUILDSH -o mesa/drm
MESACONF=""
MESACONF="$MESACONF --with-dri-drivers="
MESACONF="$MESACONF --with-gallium-drivers=swrast"
MESACONF="$MESACONF --with-egl-platforms=x11,drm"
MESACONF="$MESACONF --disable-gallium-llvm"
$BUILDSH -o mesa/mesa --confflags "$MESACONF"

# Build the X Test suite
git clone git://anongit.freedesktop.org/git/xorg/test/xts
(cd xts && ./autogen.sh && make)

# Clone the piglit test harness.  We'll use this for executing the
# xts tests.
git clone git://anongit.freedesktop.org/git/piglit
