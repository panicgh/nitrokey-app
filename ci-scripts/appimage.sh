#!/bin/bash
set -exuo pipefail
. ./nitrokey-app-source-metadata/metadata

tar xf ./artifacts/${NITROKEY_APP_BUILD_ARTIFACT_VERSION}.tar.gz

mkdir -p artifacts
OUTDIR="$(realpath artifacts)"

OUTNAME="Nitrokey_App-x86_64-${NITROKEY_APP_BUILD_ARTIFACT_VERSION}.AppImage"
ls
echo $NITROKEY_APP_BUILD_ARTIFACT_VERSION
pushd ${NITROKEY_APP_BUILD_ARTIFACT_VERSION}

## compile
APPDIR="$(readlink -f .)/nitrokey-app.AppImage"
mkdir -p build/
mkdir -p ${APPDIR}
pushd build
qmake .. PREFIX=${APPDIR}/usr/
make -j2 install
popd

## prepare image
EXTRAPLUGS=imageformats,iconengines,platforms,platformthemes
/linuxdeployqt-x86_64.AppImage --appimage-extract-and-run ${APPDIR}/usr/share/applications/nitrokey-app.desktop -bundle-non-qt-libs -extra-plugins=${EXTRAPLUGS}

## Manually invoke appimagetool so that libstdc++ gets bundled and the modified AppRun stays intact
/appimagetool-x86_64.AppImage --appimage-extract-and-run -g ${APPDIR} ${OUTDIR}/${OUTNAME}

popd

pushd ${OUTDIR}
sha256sum *.AppImage > SHA256SUMS
popd
