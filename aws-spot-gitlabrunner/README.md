# AWS GitLab Runner

## Overview

This project demonstrates how to deploy a GitLab Runner on AWS EC2 as spot instances using Terraform. The setup allows you to leverage cost-saving benefits provided by EC2 Spot instances while running jobs on your GitLab CI/CD pipeline.

## Prerequisites

Before getting started, ensure that you have the following:

- An AWS account with sufficient permissions to create EC2 instances and related resources.
- A GitLab account with the necessary permissions to create runners.
- GitLab Runner installed and registered with the GitLab project you want to use for running jobs.

## Setup Instructions

1. Clone this repository to your local machine.
2. Install Terraform version 0.12 or higher.
3. Create a new GitLab Runner in your GitLab project.
4. Create a new IAM user in AWS with programmatic access and assign the following permissions:
   - AmazonEC2FullAccess
   - AmazonVPCFullAccess
   - AmazonS3FullAccess (only if using remote state storage)
   - AmazonSSMManagedInstanceCore (only if using SSM parameter store for secrets)
5. Create an access key for the IAM user and set the following GitLab CI/CD variables:
   - `AWS_ACCESS_KEY_ID`: Access key ID for the IAM user.
   - `AWS_SECRET_ACCESS_KEY`: Secret access key for the IAM user.
   - `AWS_DEFAULT_REGION`: Default region to use for resources.
   - `TF_VAR_runner_registration_token`: Runner registration token from GitLab.
6. Customize the `variables.tf` file to match your desired configuration.
7. Run `terraform init` to initialize the project.
8. Run `terraform apply` to create the required infrastructure.
9. Wait for the GitLab Runner to appear in the runners list of your project.
10. Start running jobs on your new GitLab Runner!

## Configuration

The `variables.tf` file contains configuration options that you can modify according to your needs. Some of the important variables include:

- `region`: The AWS region in which to create resources (default: "eu-central-1").
- `name_prefix`: A prefix to prepend to all resource names (default: "gitlab-runner").
- `instance_type`: The instance type for the GitLab Runner (default: "t3.micro").
- `min_size`: The minimum number of GitLab Runner instances (default: 1).
- `max_size`: The maximum number of GitLab Runner instances (default: 10).
- `spot_price`: The maximum price per hour that the GitLab Runner will bid for spot instances (default: 0.01).
- `gitlab_url`: The URL of the GitLab instance to register the runner with (no default).
- `registration_token`: The registration token for the GitLab runner (no default).
- `executor`: The type of executor for the GitLab runner (default: "docker").
- `docker_image`: The Docker image to use for the GitLab runner (default: "docker:latest").
- `tags`: A map of tags to apply to all resources created by the module (no default).
