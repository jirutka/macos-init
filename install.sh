#!/usr/bin/env bash

set -e

# Same defaults as Makefile so executing install.sh directly has the same
# effect as executing it via `make install`.

: "${PKGNAME:="macos-init"}"
: "${LAUNCHD_DAEMON_NAME:="cz.jirutka.${PKGNAME}"}"

: "${prefix:="/usr/local"}"
: "${bindir:="${prefix}/bin"}"
: "${datadir:="${prefix}/share"}"
: "${sysconfdir:="${prefix}/etc"}"
: "${DATA_DIR:="${datadir}/${PKGNAME}"}"
: "${LAUNCHD_DAEMON_DIR:="/Library/LaunchDaemons"}"

: "${INSTALL:="install"}"

$INSTALL -d "${DESTDIR}${bindir}"
$INSTALL -v -m 755 bin/macos-init "${DESTDIR}${bindir}/macos-init"
$INSTALL -d "${DESTDIR}${sysconfdir}"
$INSTALL -v -m 644 etc/macos-init.conf "${DESTDIR}${sysconfdir}/macos-init.conf"
$INSTALL -d "${DESTDIR}${DATA_DIR}/platforms" "${DESTDIR}${DATA_DIR}/scripts"
$INSTALL -v -m 644 share/utils.sh "${DESTDIR}${DATA_DIR}/utils.sh"
$INSTALL -v -m 755 share/platforms/* "${DESTDIR}${DATA_DIR}/platforms/"
$INSTALL -v -m 755 share/scripts/* "${DESTDIR}${DATA_DIR}/scripts/"
$INSTALL -d "${DESTDIR}${LAUNCHD_DAEMON_DIR}"
$INSTALL -v -m 644 "LaunchDaemons/${LAUNCHD_DAEMON_NAME}.plist" "${DESTDIR}${LAUNCHD_DAEMON_DIR}/${LAUNCHD_DAEMON_NAME}.plist"
