#!/usr/bin/env bash
# What you install when you ask for four features, and what it is allowed to do.
#
#   ./run.sh
#
# Needs Docker and an internet connection (it talks to the npm registry).
set -uo pipefail
cd "$(dirname "$0")"
echo ""
echo "  [1/3] HOW MUCH CODE EACH VERSION INSTALLS"
./count.sh
echo "  [2/3] WHAT AN INSTALL IS ALLOWED TO DO BEFORE YOU READ ANYTHING"
./install-scripts.sh
echo "  [3/3] WHETHER A PLAUSIBLE NAME IS FREE TO TAKE"
./registry.sh
