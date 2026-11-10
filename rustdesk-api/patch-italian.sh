#!/bin/sh

#
# Copyright (C) 2026 ns8-rustdesk contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#

# Add the Italian language to the rustdesk-api-web sources and make it the
# default. Every edit checks its anchor first: if upstream changes the code,
# the build stops here instead of silently producing an untranslated console.

set -e
cd "${1:?usage: patch-italian.sh <rustdesk-api-web source dir>}"

require() {
    grep -qF "$2" "$1" || { echo "patch-italian: anchor not found in $1: $2" >&2; exit 1; }
}

# 1. Register the translation file
f=src/utils/i18n.js
require "$f" "import en from '@/utils/i18n/en.json'"
require "$f" "  'en': en,"
sed -i "s#^import en from '@/utils/i18n/en.json'#&\nimport it from '@/utils/i18n/it.json'#" "$f"
sed -i "s#^  'en': en,#&\n  'it': it,#" "$f"

# 2. Add Italian to the language menu, with the Element Plus locale
f=src/store/app.js
require "$f" "import en from 'element-plus/es/locale/lang/en'"
require "$f" "  'en': { name: 'English'"
require "$f" "const defaultLang = localStorage.getItem('lang') || navigator.language || 'zh-CN'"
sed -i "s#^import en from 'element-plus/es/locale/lang/en'#&\nimport itLocale from 'element-plus/es/locale/lang/it'#" "$f"
sed -i "s#^  'en': { name: 'English'#  'it': { name: 'Italiano', value: itLocale, sideBarWidth: '250px' },\n&#" "$f"

# 3. Italian by default; each user can still switch from the menu
sed -i "s#^const defaultLang = localStorage.getItem('lang') || navigator.language || 'zh-CN'#const defaultLang = localStorage.getItem('lang') || 'it'#" "$f"

grep -q "'it': it," src/utils/i18n.js
grep -q "'it': { name: 'Italiano'" src/store/app.js
grep -q "|| 'it'$" src/store/app.js
echo "patch-italian: ok"
