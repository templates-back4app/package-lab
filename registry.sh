#!/usr/bin/env bash
# Is the name free? The precondition for this whole class of attack is that a
# plausible package name nobody has registered can be registered by anybody.
#
# These names are constructed here, by hand, from the shapes that get confused
# with real ones — a scope added or dropped, a plural, a hyphen. They are NOT
# harvested from a model's output, and the lab does not claim they were.
set -uo pipefail

NAMES=(
  "express-session"            # real, for comparison
  "expresssession"
  "express-sessions"
  "@express/session"
  "node-bcrypt"
  "bcrypt-js"
  "mongoose-client"
  "nodemailer-smtp"
)

echo ""
printf '      %-26s%-12s%s\n' "name" "registry" "what that means"
printf '      %-26s%-12s%s\n' "------------------------" "--------" "------------------------"
free=0; total=0
for n in "${NAMES[@]}"; do
  total=$((total+1))
  code=$(curl -s -o /dev/null -w '%{http_code}' "https://registry.npmjs.org/$(printf '%s' "$n" | sed 's|/|%2f|')")
  if [ "$code" = 200 ]; then
    printf '      %-26s%-12s%s\n' "$n" "200" "exists"
  else
    free=$((free+1))
    printf '      %-26s%-12s%s\n' "$n" "$code" "nobody owns this name"
  fi
done
echo ""
echo "      $free of $total are unregistered — each one is a name an attacker can take"
echo "      and publish anything under, including the install script above."
echo ""
