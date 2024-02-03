variable "name_prefix" {
  description = "A prefix for the resource names"
  type        = string
  default     = "my-gitlab"
}
variable "aws_region" {
  description = "AWS region."
  type        = string
  default = "eu-central-1"
}

variable "instance_type" {
  description = "The instance type for the GitLab Runner"
  type        = string
  default     = "t2.micro"
}

variable "ebs_volume_size" {
  description = "The size of the EBS volume in gigabytes"
  type        = number
  default     = 30
}
variable "ssh_key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
  default     = "test"
}

variable "gitlab_url" {
  description = "The URL of the GitLab instance"
  type        = string
  default = "gitlab.com"
}

variable "registration_token" {
  description = "The GitLab Runner registration token"
  type        = string
  default = "$GITLAB_RUNNER_TOKEN"
}

variable "docker_image" {
  description = "The default Docker image for the GitLab Runner"
  type        = string
  default     = "alpine:latest"
}

variable "runner_tags" {
  description = "A comma-separated list of tags for the GitLab Runner"
  type        = string
  default     = "aws,ec2"
}

variable "tags" {
  description = "A map of tags to be applied to the resources"
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = "A list of availability zones for the Auto Scaling group"
  type        = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}


variable "desired_capacity" {
  description = "The desired number of instances for the Auto Scaling group"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "The minimum number of instances for the Auto Scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of instances for the Auto Scaling group"
  type        = number
  default     = 5
}

variable "max_spot_price" {
  description = "The maximum hourly price you're willing to pay for the Spot Instances."
  type        = string
  default     = "0.01"
}

variable "docker_machine_instance_metadata_options" {
  description = "Enable the docker machine instances metadata service. Requires you use GitLab maintained docker machines."
  type = object({
    http_tokens                 = string
    http_put_response_hop_limit = number
  })
  default = {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}
variable "docker_machine_instance_type" {
  description = "Instance type used for the instances hosting docker-machine."
  type        = string
  default     = "t2.micro"
}

variable "docker_machine_spot_price_bid" {
  description = "Spot price bid. The maximum price willing to pay. By default the price is limited by the current on demand price for the instance type chosen."
  type        = string
  default     = "on-demand-price"
}

variable "docker_machine_download_url" {
  description = "(Optional) By default the module will use `docker_machine_version` to download the GitLab mantained version of Docker Machine. Alternative you can set this property to download location of the distribution of for the OS. See also https://docs.gitlab.com/runner/executors/docker_machine.html#install"
  type        = string
  default     = ""
}

variable "docker_machine_version" {
  description = "By default docker_machine_download_url is used to set the docker machine version. Version of docker-machine. The version will be ingored once `docker_machine_download_url` is set."
  type        = string
  default     = "0.16.2-gitlab.15"
}

variable "gitlab_runner_registration_config" {
  description = "Configuration used to register the runner. See the README for an example, or reference the examples in the examples directory of this repo."
  type        = map(string)

  default = {
    registration_token = ""
    tag_list           = ""
    description        = ""
    locked_to_project  = ""
    run_untagged       = ""
    maximum_timeout    = ""
    access_level       = ""
  }
}
variable "runner_instance_metadata_options" {
  description = "Enable the Gitlab runner agent instance metadata service."
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }
}
variable "runner_description" {
  description = "The description for the GitLab Runner"
  type        = string
  default     = "EC2 Runner"
}
variable "runners_limit" {
  description = "Limit for the runners, will be used in the runner config.toml."
  type        = number
  default     = 0
}

variable "runners_concurrent" {
  description = "Concurrent value for the runners, will be used in the runner config.toml."
  type        = number
  default     = 10
}

variable "runners_idle_time" {
  description = "Idle time of the runners, will be used in the runner config.toml."
  type        = number
  default     = 600
}

variable "runners_idle_count" {
  description = "Idle count of the runners, will be used in the runner config.toml."
  type        = number
  default     = 0
}

variable "runners_max_builds" {
  description = "Max builds for each runner after which it will be removed, will be used in the runner config.toml. By default set to 0, no maxBuilds will be set in the configuration."
  type        = number
  default     = 0
}

variable "runners_image" {
  description = "Image to run builds, will be used in the runner config.toml"
  type        = string
  default     = "docker:18.03.1-ce"
}

variable "runners_privileged" {
  description = "Runners will run in privileged mode, will be used in the runner config.toml"
  type        = bool
  default     = true
}

variable "runners_disable_cache" {
  description = "Runners will not use local cache, will be used in the runner config.toml"
  type        = bool
  default     = false
}

variable "runners_add_dind_volumes" {
  description = "Add certificates and docker.sock to the volumes to support docker-in-docker (dind)"
  type        = bool
  default     = false
}

variable "runners_additional_volumes" {
  description = "Additional volumes that will be used in the runner config.toml, e.g Docker socket"
  type        = list(any)
  default     = []
}

variable "runners_extra_hosts" {
  description = "Extra hosts that will be used in the runner config.toml, e.g other-host:127.0.0.1"
  type        = list(any)
  default     = []
}

variable "runners_shm_size" {
  description = "shm_size for the runners, will be used in the runner config.toml"
  type        = number
  default     = 0
}

variable "runners_docker_runtime" {
  description = "docker runtime for runners, will be used in the runner config.toml"
  type        = string
  default     = ""
}

variable "runners_helper_image" {
  description = "Overrides the default helper image used to clone repos and upload artifacts, will be used in the runner config.toml"
  type        = string
  default     = ""
}

variable "runners_pull_policy" {
  description = "Deprecated! Use runners_pull_policies instead. pull_policy for the runners, will be used in the runner config.toml"
  type        = string
  default     = ""
}

variable "runners_pull_policies" {
  description = "pull policies for the runners, will be used in the runner config.toml, for Gitlab Runner >= 13.8, see https://docs.gitlab.com/runner/executors/docker.html#using-multiple-pull-policies "
  type        = list(string)
  default     = ["always"]
}

variable "runners_monitoring" {
  description = "Enable detailed cloudwatch monitoring for spot instances."
  type        = bool
  default     = false
}

variable "runner_instance_ebs_optimized" {
  description = "Enable the GitLab runner instance to be EBS-optimized."
  type        = bool
  default     = true
}

variable "runners_machine_autoscaling" {
  description = "Set autoscaling parameters based on periods, see https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachine-section"
  type = list(object({
    periods    = list(string)
    idle_count = number
    idle_time  = number
    timezone   = string
  }))
  default = []
}

variable "runners_root_size" {
  description = "Runner instance root size in GB."
  type        = number
  default     = 16
}

variable "runners_volume_type" {
  description = "Runner instance volume type"
  type        = string
  default     = "gp2"
}

variable "runner_instance_enable_monitoring" {
  description = "Enable the GitLab runner instance to have detailed monitoring."
  type        = bool
  default     = true
}

variable "runner_instance_spot_price" {
  description = "By setting a spot price bid price the runner agent will be created via a spot request. Be aware that spot instances can be stopped by AWS. Choose \"on-demand-price\" to pay up to the current on demand price for the instance type chosen."
  type        = string
  default     = null
}
variable "runners_iam_instance_profile_name" {
  description = "IAM instance profile name of the runners, will be used in the runner config.toml"
  type        = string
  default     = ""
}

variable "runners_docker_registry_mirror" {
  description = "The docker registry mirror to use to avoid rate limiting by hub.docker.com"
  type        = string
  default     = ""
}

variable "runners_environment_vars" {
  description = "Environment variables during build execution, e.g. KEY=Value, see runner-public example. Will be used in the runner config.toml"
  type        = list(string)
  default     = []
}

variable "runners_pre_build_script" {
  description = "Script to execute in the pipeline just before the build, will be used in the runner config.toml"
  type        = string
  default     = "\"\""
}

variable "runners_post_build_script" {
  description = "Commands to be executed on the Runner just after executing the build, but before executing after_script. "
  type        = string
  default     = "\"\""
}

variable "runners_pre_clone_script" {
  description = "Commands to be executed on the Runner before cloning the Git repository. this can be used to adjust the Git client configuration first, for example. "
  type        = string
  default     = "\"\""
}

variable "runners_request_concurrency" {
  description = "Limit number of concurrent requests for new jobs from GitLab (default 1)."
  type        = number
  default     = 1
}

variable "runners_output_limit" {
  description = "Sets the maximum build log size in kilobytes, by default set to 4096 (4MB)."
  type        = number
  default     = 4096
}

variable "userdata_pre_install" {
  description = "User-data script snippet to insert before GitLab runner install"
  type        = string
  default     = ""
}

variable "userdata_post_install" {
  description = "User-data script snippet to insert after GitLab runner install"
  type        = string
  default     = ""
}

variable "runners_use_private_address" {
  description = "Restrict runners to the use of a private IP address. If `runner_agent_uses_private_address` is set to `true`(default), `runners_use_private_address` will also apply for the agent."
  type        = bool
  default     = true
}

variable "runner_agent_uses_private_address" {
  description = "Restrict the runner agent to the use of a private IP address. If `runner_agent_uses_private_address` is set to `false` it will override the `runners_use_private_address` for the agent."
  type        = bool
  default     = true
}

variable "runners_request_spot_instance" {
  description = "Whether or not to request spot instances via docker-machine"
  type        = bool
  default     = true
}

variable "runners_check_interval" {
  description = "defines the interval length, in seconds, between new jobs check."
  type        = number
  default     = 3
}
variable "metrics_autoscaling" {
  description = "A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances."
  type        = list(string)
  default     = null
}
variable "extra_security_group_ids_runner_agent" {
  description = "Optional IDs of extra security groups to apply to the runner agent. This will not apply to the runners spun up when using the docker+machine executor, which is the default."
  type        = list(string)
  default     = []
}
variable "runners_executor" {
  description = "The executor to use. Currently supports `docker+machine` or `docker`."
  type        = string
  default     = "docker+machine"
}
