#!/bin/sh

#
# Copyright (C) 2026 ns8-rustdesk contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#

# Make the browser client connect through the HTTPS port.
#
# Upstream, a client opened from an HTTPS page connects to
# wss://<server>:21118 (ID) and wss://<server>:21119 (relay), but hbbs and
# hbbr speak plain websocket on those ports, so the connection fails.
# After this patch the client uses wss://<console host>/ws/id and
# wss://<console host>/ws/relay: Traefik terminates TLS with the console
# certificate and forwards to hbbs/hbbr (see configure-module/30traefik).
# On plain HTTP pages the original behaviour is kept.
#
# The anchor is matched with a regular expression on the minified bundle of
# the pinned rustdesk-api version; if it is not found exactly once, the
# build stops instead of shipping a client that cannot connect.

set -e
web="${1:?usage: patch-webclient.sh <web client dir>}"
js="${web}/js/dist/index.js"
sw="${web}/flutter_service_worker.js"

# function NAME(HOST,ISRELAY=!1,OFFSET=0){if(HOST.indexOf(":")>0)
anchor='function ([A-Za-z_$][A-Za-z0-9_$]*)\(([A-Za-z_$][A-Za-z0-9_$]*),([A-Za-z_$][A-Za-z0-9_$]*)=!1,([A-Za-z_$][A-Za-z0-9_$]*)=0\)\{if\(\2\.indexOf\(":"\)>0\)'

count=$(grep -oE "${anchor}" "${js}" | wc -l)
if [ "${count}" -ne 1 ]; then
    echo "patch-webclient: expected 1 match of the URL builder, found ${count}" >&2
    exit 1
fi

sed -i -E "s/${anchor}/function \\1(\\2,\\3=!1,\\4=0){if(location.protocol==\"https:\")return\"wss:\/\/\"+location.host+\"\/ws\/\"+(\\3?\"relay\":\"id\");if(\\2.indexOf(\":\")>0)/" "${js}"
grep -q 'location.host+"/ws/"' "${js}"

# Update the bundle hash in the Flutter service worker manifest, so
# browsers that cached the original client fetch the patched one
new_md5=$(md5sum "${js}" | cut -d' ' -f1)
if [ -f "${sw}" ]; then
    sed -i -E "s/\"js\/dist\/index.js\": \"[0-9a-f]+\"/\"js\/dist\/index.js\": \"${new_md5}\"/" "${sw}"
    grep -q "\"js/dist/index.js\": \"${new_md5}\"" "${sw}"
fi

echo "patch-webclient: ok"
