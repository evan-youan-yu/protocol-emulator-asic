#!/usr/bin/env bash
set -euo pipefail

# Run this in the user's visible desktop terminal. sudo prompts only there.
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$root/reports/logs"
log="$root/reports/logs/install-host-docker.log"
exec > >(tee -a "$log") 2>&1

if [[ ! -f /etc/os-release ]] || ! grep -q '^ID=ubuntu$' /etc/os-release; then
  echo 'This installer is limited to Ubuntu; inspect host packages manually.' >&2
  exit 2
fi
installed_docker_now=0
if command -v docker >/dev/null 2>&1; then
  echo 'Docker is already installed; checking rootless daemon without replacing packages.'
else
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io uidmap slirp4netns fuse-overlayfs rootlesskit
  installed_docker_now=1
fi

if ! command -v rootlesskit >/dev/null 2>&1; then
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y rootlesskit
fi
export PATH="/usr/share/docker.io/contrib:$PATH"

for helper in newuidmap newgidmap slirp4netns; do
  command -v "$helper" >/dev/null || { echo "Missing $helper" >&2; exit 2; }
done
for file in /etc/subuid /etc/subgid; do
  awk -F: -v user="$(id -un)" '$1 == user && $3 >= 65536 { found=1 } END { exit !found }' "$file" || {
    echo "Missing 65,536 subordinate IDs for $(id -un) in $file" >&2
    exit 2
  }
done

if systemctl is-active --quiet docker.service || systemctl is-active --quiet docker.socket; then
  if [[ "$installed_docker_now" == 1 ]]; then
    # Keep only the daemon installed by this script stopped; preserve any
    # pre-existing Docker service on another machine.
    sudo systemctl disable --now docker.service docker.socket
  else
    echo 'An existing system Docker service is active; preserving it. Configure rootless Docker separately.' >&2
    exit 2
  fi
fi

if command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then
  setup_tool="$(command -v dockerd-rootless-setuptool.sh)"
elif [[ -x /usr/share/docker.io/contrib/dockerd-rootless-setuptool.sh ]]; then
  setup_tool=/usr/share/docker.io/contrib/dockerd-rootless-setuptool.sh
else
  echo 'Rootless Docker setup tool not included in installed package.' >&2
  exit 2
fi

socket="unix:///run/user/$(id -u)/docker.sock"
if ! docker --host "$socket" info >/dev/null 2>&1; then
  # Ubuntu's setup tool starts the daemon, but its final CLI probe may fail
  # because docker is in /usr/bin instead of the tool's own directory.
  "$setup_tool" install || true
fi
docker --host "$socket" info >/dev/null || {
  echo 'The rootless Docker daemon did not start.' >&2
  exit 2
}
systemctl --user enable docker.service
if ! docker context inspect rootless >/dev/null 2>&1; then
  docker context create rootless --docker "host=$socket"
fi
docker context use rootless
docker --host "$socket" info --format '{{json .SecurityOptions}}' | tee "$root/reports/logs/docker-security-options.json"
docker --host "$socket" info --format '{{json .SecurityOptions}}' | grep -q rootless || {
  echo 'Docker daemon is not rootless or not reachable.' >&2
  exit 2
}
echo 'Rootless Docker ready.'
