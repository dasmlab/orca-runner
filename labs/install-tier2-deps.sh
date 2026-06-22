#!/usr/bin/env bash
# One-time host packages for Tier 2 (Ubuntu/Debian). Requires sudo.
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  cmake git pkg-config \
  libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev \
  libgtest-dev libzmq3-dev \
  libboost-program-options-dev libboost-dev

echo "Done. Optional RF drivers (not needed for ZMQ lab): libuhd-dev libsoapysdr-dev"
echo "Next: ./labs/setup-tier2-ran-lab.sh build"
