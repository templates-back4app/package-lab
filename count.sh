#!/usr/bin/env bash
# How much code does each version actually install, and how much of it runs
# during the install? Counted from the lockfile and the installed tree.
set -uo pipefail
cd "$(dirname "$0")"

measure() {
  local dir="$1" label="$2"
  rm -rf "$dir/node_modules" "$dir/package-lock.json"
  docker run --rm -v "$PWD/$dir":/app -w /app node:22-alpine \
    sh -c 'npm install --silent --no-audit --no-fund >/dev/null 2>&1' || true

  node -e "
    const { readFileSync, existsSync, readdirSync } = require('fs');
    const { join } = require('path');
    const dir = '$dir';
    const pkg = JSON.parse(readFileSync(join(dir, 'package.json'), 'utf8'));
    const direct = Object.keys(pkg.dependencies ?? {}).length;

    // the lockfile is the authoritative list of everything that got installed
    const lock = JSON.parse(readFileSync(join(dir, 'package-lock.json'), 'utf8'));
    const all = Object.keys(lock.packages ?? {}).filter((k) => k.startsWith('node_modules/'));

    // how many of them run code of their own during npm install
    let scripts = 0, named = [];
    for (const p of all) {
      const pj = join(dir, p, 'package.json');
      if (!existsSync(pj)) continue;
      try {
        const s = JSON.parse(readFileSync(pj, 'utf8')).scripts ?? {};
        if (s.install || s.preinstall || s.postinstall) { scripts++; named.push(p.replace(/^node_modules\//, '')); }
      } catch {}
    }
    const du = require('child_process').execSync('du -sh ' + JSON.stringify(join(dir,'node_modules')) + ' 2>/dev/null | cut -f1').toString().trim();
    console.log([
      '$label'.padEnd(28) + String(direct).padEnd(16) + String(all.length).padEnd(16) + du.padEnd(11) + scripts,
    ].join('\n'));
    if (named.length) console.log('      '.padEnd(6) + '↳ ' + named.join(', '));
  "
}

echo ""
echo "      " "$(printf '%-28s%-16s%-16s%-11s%s' '' 'you asked for' 'you installed' 'on disk' 'run code on install')"
echo "      $(printf '%-28s%-16s%-16s%-11s%s' '--------------------------' '-------------' '-------------' '---------' '-------------------')"
measure with-libraries "assembled from libraries" | sed 's/^/      /'
measure with-a-backend "the backend already has it" | sed 's/^/      /'
echo ""
