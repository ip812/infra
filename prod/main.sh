#!/bin/bash

AWS_REGION="eu-central-1"

while read -r instance_id; do
    aws ssm send-command \
        --region $AWS_REGION \
        --document-name "AWS-RunShellScript" \
        --targets "Key=instanceIds,Values=${instance_id}" \
        --parameters 'commands=["docker ps -a"]' > /dev/null
done < <(aws ec2 describe-instances \
    --region eu-central-1 \
    --filters "Name=tag:Environment,Values=prod" "Name=tag:Organization,Values=ip812" \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].InstanceId" \
    --output json | jq -r '.[]')

