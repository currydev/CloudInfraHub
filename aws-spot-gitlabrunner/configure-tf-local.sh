#!/usr/bin/env bash
set -e

CI_API_V4_URL="https://"
CI_PROJECT_ID=""
state_name="dev"
# Fetch this from your Gitlab profile
username="InsertYourGitlabUsernanme"
token="InsertYourGitlabToken"

while getopts u:t:s: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        t) token=${OPTARG};;
        s) state_name=${OPTARG};;
    esac
done

terraform init -reconfigure \
    -backend-config="address=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${state_name}" \
    -backend-config="lock_address=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${state_name}/lock" \
    -backend-config="unlock_address=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${state_name}/lock" \
    -backend-config="username=${username}" \
    -backend-config="password=${token}" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"