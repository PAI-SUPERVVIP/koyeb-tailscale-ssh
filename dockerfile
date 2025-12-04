# Dockerfile
FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    ca-certificates curl gnupg lsb-release iproute2 iputils-ping \
    openssh-server sudo git procps \
  && rm -rf /var/lib/apt/lists/*

# Install Tailscale (official method: add apt repo)
RUN mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://pkgs.tailscale.com/stable/debian/$(lsb_release -cs).gpg | tee /etc/apt/keyrings/tailscale-archive-keyring.gpg > /dev/null \
 && echo "deb [signed-by=/etc/apt/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/debian $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/tailscale.list \
 && apt-get update \
 && apt-get install -y tailscale

# Create sshd config
RUN mkdir /var/run/sshd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
CMD ["/entrypoint.sh"]