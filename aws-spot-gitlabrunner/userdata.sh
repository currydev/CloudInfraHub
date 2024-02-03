#!/bin/bash
export GITLAB_RUNNER_TOKEN=${GITLAB_RUNNER_TOKEN}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# Install GitLab Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt-get install -y gitlab-runner

# Install Docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Machine
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
sudo chmod +x /usr/local/bin/docker-machine

# Set up GitLab Runner
sudo gitlab-runner register \
  --url ${var.gitlab_url} \
  --registration-token ${var.registration_token} \
  --executor docker \
  --description ${var.runner_description} \
  --docker-image ${var.docker_image} \
  --docker-privileged \
  --tag-list ${var.runner_tags} \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected" \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock

cat > etc/gitlab-runner/config.toml <<EOF
concurrent = 1
check_interval = 0
shutdown_timeout = 0

[session_server]
session_timeout = 1800

[[runners]]
  name = "gitlab-runner"
  limit = 2
  url = "https://gitlab.com"
  id = 23279617
  token = "$(GITLAB_RUNNER_TOKEN)"
  token_obtained_at = 2023-05-09T09:15:36Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker+machine"
  [runners.docker]
  tls_verify = false
  image = "alpine:latest"
  privileged = false
  disable_entrypoint_overwrite = false
  oom_kill_disable = false
  disable_cache = false
  volumes = ["/cache"]
  shm_size = 0
  [runners.machine]
  IdleCount = 0
  IdleScaleFactor = 0.0
  IdleCountMin = 0
  IdleTime = 1800
  MaxBuilds = 2
  MachineDriver = "amazonec2"
  MachineName = "gitlab-docker-machine-%s"
  MachineOptions = ["amazonec2-access-key=$(AWS_ACCESS_KEY_ID)", "amazonec2-secret-key=$(AWS_SECRET_ACCESS_KEY)", "amazonec2-region=eu-central-1", "amazonec2-vpc-id=vpc-23636848", "amazonec2-subnet-id=subnet-878ba5fa", "amazonec2-zone=b", "amazonec2-use-private-address=true", "amazonec2-tags=runner-manager-name,gitlab-aws-autoscaler,gitlab,true,gitlab-runner-autoscale,true", "amazonec2-security-group=launch-wizard-8", "amazonec2-instance-type=t2.micro","amazonec2-request-spot-instance=true", "amazonec2-spot-price=0.005"]

  [[runners.machine.autoscaling]]
  Periods = ["* * 9-17 * * mon-fri *"]
  Timezone = "UTC"
  IdleCount = 0
  IdleScaleFactor = 0.0
  IdleCountMin = 0
  IdleTime = 10

  [[runners.machine.autoscaling]]
  Periods = ["* * * * * sat,sun *"]
  Timezone = "UTC"
  IdleCount = 0
  IdleScaleFactor = 0.0
  IdleCountMin = 0
  IdleTime = 60
EOF
# Start the GitLab Runner
sudo gitlab-runner start