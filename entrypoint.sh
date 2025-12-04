#!/bin/bash
set -e

# Required env:
# TAILSCALE_AUTHKEY  -> ต้องสร้างจาก https://login.tailscale.com/admin/settings/keys
# SSH_PUBKEY         -> (optional) public key string for root login
# HOSTNAME           -> (optional) friendly hostname for tailscale

TAILSCALE_STATE_DIR="/var/lib/tailscale"

mkdir -p $TAILSCALE_STATE_DIR
chown -R root:root $TAILSCALE_STATE_DIR

# Start tailscaled (background)
echo "[entrypoint] starting tailscaled..."
/usr/sbin/tailscaled --state=$TAILSCALE_STATE_DIR/tailscaled.state --tun=userspace-networking > /var/log/tailscaled.log 2>&1 &

# wait for tailscaled socket
for i in {1..15}; do
  if tailscale status &>/dev/null; then break; fi
  sleep 0.6
done

if [ -z "$TAILSCALE_AUTHKEY" ]; then
  echo "[entrypoint] ERROR: TAILSCALE_AUTHKEY not set"
  tail -n +1 /var/log/tailscaled.log || true
  exit 1
fi

TS_HOSTNAME_OPT=""
if [ ! -z "$HOSTNAME" ]; then
  TS_HOSTNAME_OPT="--hostname=${HOSTNAME}"
fi

echo "[entrypoint] running 'tailscale up'..."
/usr/bin/tailscale up --authkey="${TAILSCALE_AUTHKEY}" ${TS_HOSTNAME_OPT} --accept-routes --accept-dns > /var/log/tailscale-up.log 2>&1 || { tail -n 200 /var/log/tailscale-up.log; exit 1; }

echo "[entrypoint] tailscale up done. status:"
tailscale status
tailscale ip -4 || true

# Setup SSH key if provided
if [ ! -z "$SSH_PUBKEY" ]; then
  mkdir -p /root/.ssh
  echo "$SSH_PUBKEY" > /root/.ssh/authorized_keys
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
  echo "[entrypoint] installed provided SSH public key for root"
else
  echo "[entrypoint] WARNING: SSH_PUBKEY not provided. SSH access will be disabled (no password auth)."
fi

# Start sshd
echo "[entrypoint] starting sshd..."
/usr/sbin/sshd -D