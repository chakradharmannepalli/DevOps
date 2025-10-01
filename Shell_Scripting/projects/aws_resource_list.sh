#!/usr/bin/env bash

###############################################################################
# Author: Chakradhar
# Version: v1

# Script to automate the process of listing all the resources in an AWS account
#
# Below are the services that are supported by this script:
# 1. EC2
# 2. RDS
# 3. S3
# 4. CloudFront
# 5. VPC
# 6. IAM
# 7. Route53
# 8. CloudWatch
# 9. CloudFormation
# 10. Lambda
# 11. SNS
# 12. SQS
# 13. DynamoDB
# 14. VPC
# 15. EBS

# aws_resource_list.sh
# -------------------------------------------------------------------
# Purpose:  A safe, flexible utility to list AWS resources by service
#           and region. Supports explicit profile selection, output
#           formatting (json/table/jq), optional pagination control,
#           running across all regions with concurrency control, and
#           optional tee-to-file output.
#
# Usage: ./aws_resource_list_with_profile.sh [options] <aws_region> <aws_service>
#        or:  ./aws_resource_list_with_profile.sh [options] <aws_service>   (defaults region to us-east-1)
#
# Examples:
#   ./aws_resource_list_with_profile.sh us-east-1 ec2
#   ./aws_resource_list_with_profile.sh ec2                    # uses default region us-east-1
#   ./aws_resource_list_with_profile.sh -p myprofile -f jq lambda
#   ./aws_resource_list_with_profile.sh -a -c 4 -o inventory.txt ec2
#
# Notes:
#  - Use -a/--all-regions to run across all AWS regions. When used, the
#    positional region argument is ignored (you may supply only the service).
#  - jq mode prints compact TSV rows that are easy to read or pipe to `column -t`.
# -------------------------------------------------------------------

set -euo pipefail
IFS=$'
	'

# Exit code constants
EXIT_SUCCESS=0
EXIT_USAGE=1
EXIT_NO_AWS=2
EXIT_AWS_NOT_CONFIGURED=3
EXIT_INVALID_REGION=4
EXIT_PROFILE_NOT_FOUND=5
EXIT_CANNOT_WRITE_FILE=7

# Defaults
profile=""
format="json"
verbose=0
no_paginate=0
all_regions=0
concurrency=3
per_region_sleep=0.5
output_file=""

# ----------------------
# Logging helpers (define early so they're available during startup)
# ----------------------
log()  { if [[ ${verbose:-0} -eq 1 ]]; then printf '[LOG] %s
' "$*" >&2; fi; }
warn() { printf '[WARN] %s
' "$*" >&2; }
err()  { printf '[ERROR] %s
' "$*" >&2; }

# ----------------------
# Usage/help
# ----------------------
usage() {
    cat <<'EOF'
aws_resource_list_with_profile.sh [options] <aws_region> <aws_service>

Options:
  -p, --profile PROFILE        AWS CLI profile to use (overrides AWS_PROFILE)
  -f, --format FORMAT          json | table | jq (default json)
  -v, --verbose                verbose logging to stderr
  --no-paginate                pass --no-paginate to AWS CLI
  -a, --all-regions            run the listing across all AWS regions
  -c, --concurrency N          number of parallel region jobs (default 3)
  -s, --sleep FLOAT            seconds to sleep between starting region jobs (default 0.5)
  -o, --output-file FILE       append output to FILE (also prints to console)
  -h, --help                   show this help

Examples:
  ./aws_resource_list_with_profile.sh us-east-1 ec2
  ./aws_resource_list_with_profile.sh ec2                # defaults region to us-east-1
  ./aws_resource_list_with_profile.sh -p myprofile -f jq us-west-2 rds
  ./aws_resource_list_with_profile.sh -a -c 4 -o inventory.txt ec2
EOF
    exit $EXIT_USAGE
}

# ----------------------
# Parse CLI options
# ----------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--profile)
            if [[ -n "${2:-}" ]]; then profile="$2"; shift 2; else err "--profile requires an argument"; usage; fi
            ;;
        -f|--format)
            if [[ -n "${2:-}" ]]; then format="$2"; shift 2; else err "--format requires an argument"; usage; fi
            ;;
        -v|--verbose)
            verbose=1; shift
            ;;
        --no-paginate)
            no_paginate=1; shift
            ;;
        -a|--all-regions)
            all_regions=1; shift
            ;;
        -c|--concurrency)
            if [[ -n "${2:-}" ]]; then concurrency="$2"; shift 2; else err "--concurrency requires an argument"; usage; fi
            ;;
        -s|--sleep)
            if [[ -n "${2:-}" ]]; then per_region_sleep="$2"; shift 2; else err "--sleep requires an argument"; usage; fi
            ;;
        -o|--output-file)
            if [[ -n "${2:-}" ]]; then output_file="$2"; shift 2; else err "--output-file requires an argument"; usage; fi
            ;;
        -h|--help)
            usage
            ;;
        -* ) err "Unknown option: $1"; usage ;;
        * ) break ;;
    esac
done

# ----------------------
# Positional args: allow 1 or 2 args. If only service provided, default region to us-east-1
# ----------------------
if [[ $# -eq 1 ]]; then
    aws_region="us-east-1"
    aws_service=$(echo "$1" | tr '[:upper:]' '[:lower:]')
elif [[ $# -eq 2 ]]; then
    aws_region=$1
    aws_service=$(echo "$2" | tr '[:upper:]' '[:lower:]')
else
    usage
fi

# Validate simple typed options
if ! [[ "$format" =~ ^(json|table|jq)$ ]]; then err "Invalid format: $format"; usage; fi
if ! [[ "$concurrency" =~ ^[0-9]+$ ]]; then err "Concurrency must be a positive integer"; usage; fi
if ! [[ "$per_region_sleep" =~ ^[0-9]+([.][0-9]+)?$ ]]; then err "Sleep must be a number (seconds)"; usage; fi

# ----------------------
# Build AWS profile arg array
# ----------------------
aws_profile_arg=()
if [[ -n "$profile" ]]; then
    aws_profile_arg=(--profile "$profile")
elif [[ -n "${AWS_PROFILE:-}" ]]; then
    aws_profile_arg=(--profile "$AWS_PROFILE")
fi

# ----------------------
# Output file handling: ensure writable then tee stdout+stderr to it
# ----------------------
if [[ -n "$output_file" ]]; then
    if ! touch "$output_file" 2>/dev/null; then err "Cannot write to output file: $output_file"; exit $EXIT_CANNOT_WRITE_FILE; fi
    exec > >(tee -a "$output_file") 2>&1
fi

# ----------------------
# Pre-checks: aws CLI on PATH, detect version, optional profile existence, validate credentials
# ----------------------
if ! command -v aws >/dev/null 2>&1; then err "AWS CLI not installed"; exit $EXIT_NO_AWS; fi

aws_version_str=$(aws --version 2>&1 || true)
log "Detected AWS CLI: $aws_version_str"
if [[ "$aws_version_str" != *"aws-cli/2"* ]]; then warn "AWS CLI v2 not detected; some checks may behave differently"; fi

# If explicit profile provided, try to verify it (aws configure list-profiles exists in v2)
if [[ -n "$profile" ]]; then
    if aws configure list-profiles >/dev/null 2>&1; then
        if ! aws configure list-profiles | grep -qxF "$profile"; then err "AWS profile '$profile' not found"; exit $EXIT_PROFILE_NOT_FOUND; fi
    else
        warn "Cannot verify profile existence (aws configure list-profiles not available); proceeding"
    fi
fi

# Ensure credentials work by calling STS
if ! aws "${aws_profile_arg[@]:-}" sts get-caller-identity >/dev/null 2>&1; then
    err "AWS CLI credentials/configuration invalid or unable to call STS"
    err "Run 'aws configure --profile <profile>' or set AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY (and optionally AWS_SESSION_TOKEN/AWS_PROFILE)"
    exit $EXIT_AWS_NOT_CONFIGURED
fi

# ----------------------
# Pagination args
# ----------------------
_paginate_args=()
if [[ $no_paginate -eq 1 ]]; then _paginate_args+=(--no-paginate); fi

# ----------------------
# run_aws wrapper: retries + exponential backoff
# ----------------------
run_aws() {
    local attempt=0 max_attempts=5 delay=1 rc=0
    local logcmd
    printf -v logcmd '%q ' aws "${aws_profile_arg[@]:-}" "$@"
    while :; do
        log "Running: $logcmd"
        if aws "${aws_profile_arg[@]:-}" "$@"; then rc=0; break; else rc=$?; fi
        attempt=$((attempt+1))
        if (( attempt >= max_attempts )); then err "Command failed after $attempt attempts: aws $* (exit $rc)"; return $rc; fi
        warn "aws command failed (exit $rc). Retrying in ${delay}s... (attempt $((attempt+1))/$max_attempts)"
        sleep $delay
        delay=$((delay*2))
    done
    return $rc
}

# ----------------------
# validate_region: ensure user-provided region exists
# ----------------------
validate_region() {
    local region="$1" regions
    log "Validating region: $region"
    if ! regions=$(aws "${aws_profile_arg[@]:-}" ec2 describe-regions --query 'Regions[].RegionName' --output text 2>/dev/null); then
        warn "Unable to query region list. Skipping region validation"
        return 0
    fi
    if ! tr ' ' '
' <<<"$regions" | grep -qxF "$region"; then
        err "Invalid AWS region: '$region'"
        err "Available: $regions"
        exit $EXIT_INVALID_REGION
    fi
}

# ----------------------
# jq check
# ----------------------
if [[ "$format" == "jq" ]] && ! command -v jq >/dev/null 2>&1; then warn "jq not installed; falling back to json"; format="json"; fi

# Validate region unless using all-regions
if [[ $all_regions -eq 0 ]]; then validate_region "$aws_region"; fi

# Trap interrupts
trap 'err "Interrupted"; exit 130' INT TERM

# ----------------------
# Service listing functions
# ----------------------
list_ec2() {
    echo "=== EC2 Instances in region: $aws_region ==="
    if [[ "$format" == "jq" ]]; then
        run_aws ec2 describe-instances --region "$aws_region" "${_paginate_args[@]:-}" \
            | jq -r '.Reservations[].Instances[] | [.InstanceId, .InstanceType, .State.Name, .Placement.AvailabilityZone, (.PublicIpAddress // "-")] | @tsv'
    elif [[ "$format" == "table" ]]; then
        run_aws ec2 describe-instances --region "$aws_region" "${_paginate_args[@]:-}" --output table
    else
        run_aws ec2 describe-instances --region "$aws_region" "${_paginate_args[@]:-}"
    fi
}

list_rds() {
    echo "=== RDS Instances in region: $aws_region ==="
    if [[ "$format" == "jq" ]]; then
        run_aws rds describe-db-instances --region "$aws_region" "${_paginate_args[@]:-}" \
            | jq -r '.DBInstances[] | [.DBInstanceIdentifier, .DBInstanceClass, .Engine, .DBInstanceStatus, (.Endpoint.Address // "-")] | @tsv'
    elif [[ "$format" == "table" ]]; then
        run_aws rds describe-db-instances --region "$aws_region" "${_paginate_args[@]:-}" --output table
    else
        run_aws rds describe-db-instances --region "$aws_region" "${_paginate_args[@]:-}"
    fi
}

list_s3() {
    echo "=== S3 Buckets (global) ==="
    if [[ "$format" == "jq" ]]; then
        run_aws s3api list-buckets "${_paginate_args[@]:-}" | jq -r '.Buckets[] | [.Name, .CreationDate] | @tsv'
    elif [[ "$format" == "table" ]]; then
        run_aws s3api list-buckets "${_paginate_args[@]:-}" --output table
    else
        run_aws s3api list-buckets "${_paginate_args[@]:-}"
    fi
}

list_cloudfront()    { echo "=== CloudFront Distributions (global) ==="; run_aws cloudfront list-distributions "${_paginate_args[@]:-}"; }
list_vpc()           { echo "=== VPCs in region: $aws_region ==="; run_aws ec2 describe-vpcs --region "$aws_region" "${_paginate_args[@]:-}"; }
list_iam()           { echo "=== IAM Users (global) ==="; run_aws iam list-users "${_paginate_args[@]:-}"; }
list_route53()       { echo "=== Route53 Hosted Zones (global) ==="; run_aws route53 list-hosted-zones "${_paginate_args[@]:-}"; }
list_cloudwatch()    { echo "=== CloudWatch Alarms in region: $aws_region ==="; run_aws cloudwatch describe-alarms --region "$aws_region" "${_paginate_args[@]:-}"; }
list_cloudformation(){ echo "=== CloudFormation Stacks in region: $aws_region ==="; run_aws cloudformation describe-stacks --region "$aws_region" "${_paginate_args[@]:-}"; }
list_lambda()        { echo "=== Lambda Functions in region: $aws_region ==="; run_aws lambda list-functions --region "$aws_region" "${_paginate_args[@]:-}"; }
list_sns()           { echo "=== SNS Topics in region: $aws_region ==="; run_aws sns list-topics --region "$aws_region" "${_paginate_args[@]:-}"; }
list_sqs()           { echo "=== SQS Queues in region: $aws_region ==="; run_aws sqs list-queues --region "$aws_region" "${_paginate_args[@]:-}"; }
list_dynamodb()      { echo "=== DynamoDB Tables in region: $aws_region ==="; run_aws dynamodb list-tables --region "$aws_region" "${_paginate_args[@]:-}"; }
list_ebs()           { echo "=== EBS Volumes in region: $aws_region ==="; run_aws ec2 describe-volumes --region "$aws_region" "${_paginate_args[@]:-}"; }

# ----------------------
# Dispatch helper
# ----------------------
dispatch_for_service() {
    case "$aws_service" in
        ec2) list_ec2 ;;
        rds) list_rds ;;
        s3) list_s3 ;;
        cloudfront) list_cloudfront ;;
        vpc) list_vpc ;;
        iam) list_iam ;;
        route53|route-53) list_route53 ;;
        cloudwatch) list_cloudwatch ;;
        cloudformation) list_cloudformation ;;
        lambda) list_lambda ;;
        sns) list_sns ;;
        sqs) list_sqs ;;
        dynamodb) list_dynamodb ;;
        ebs) list_ebs ;;
        all)
            # Warning: 'all' invokes many APIs and can produce large output
            list_s3; list_iam; list_route53; list_cloudfront;
            list_ec2; list_rds; list_vpc; list_cloudwatch;
            list_cloudformation; list_lambda; list_sns; list_sqs; list_dynamodb; list_ebs
            ;;
        *) err "Invalid or unsupported service: $aws_service"; usage ;;
    esac
}

# ----------------------
# all-regions mode
# ----------------------
if [[ $all_regions -eq 1 ]]; then
    log "Running in all-regions mode (concurrency=$concurrency, sleep=$per_region_sleep)"
    regions=$(aws "${aws_profile_arg[@]:-}" ec2 describe-regions --query 'Regions[].RegionName' --output text)
    regions=$(tr ' ' '
' <<<"$regions")

    pids=()
    for r in $regions; do
        # Purge finished PIDs
        newpids=()
        for pid in "${pids[@]:-}"; do
            if kill -0 "$pid" 2>/dev/null; then newpids+=("$pid"); fi
        done
        pids=("${newpids[@]:-}")

        # Wait until there's a free slot
        while (( ${#pids[@]} >= concurrency )); do
            sleep 0.5
            newpids=()
            for pid in "${pids[@]:-}"; do
                if kill -0 "$pid" 2>/dev/null; then newpids+=("$pid"); fi
            done
            pids=("${newpids[@]:-}")
        done

        # Launch subshell job for the region
        (
            aws_region="$r"
            printf '
### REGION: %s ###
' "$r"
            dispatch_for_service
        ) &
        pids+=("$!")

        sleep "$per_region_sleep"
    done

    # wait for background jobs
    for pid in "${pids[@]:-}"; do
        wait "$pid" || true
    done
else
    dispatch_for_service
fi

exit $EXIT_SUCCESS
