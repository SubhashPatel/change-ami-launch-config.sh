#!/bin/bash

#Define parameters
ASG_NAME="myapp"
NEW_LC="myapp-$(date +%Y-%m-%d_%H-%M)"
TIME=$(date +%Y-%m-%d_%H-%M)

echo "Selected Auto Scalling Group is ${ASG_NAME}"

# Get instance id from ASG_NAME
RANDOM_INST_ID="$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG_NAME} --query 'AutoScalingGroups[].Instances[?HealthStatus==`Healthy`].InstanceId' | head -3 | sed 1d | sed 1d | sed 's/ //g' | sed 's/"//g')";

# Get launch configuration name from ASG_NAME
LC_NAME=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG_NAME} --query 'AutoScalingGroups[].LaunchConfigurationName' | head -2 | sed 1d | sed 's/ //g' | sed 's/"//g')

# Create AMI
IMAGE=`aws ec2 create-image --instance-id ${RANDOM_INST_ID} --name NEW-IMAGE-${TIME} --no-reboot --output text`

echo "Create Image of instance ${RANDOM_INST_ID}"

# Create Launch Configuration
aws autoscaling create-launch-configuration --launch-configuration-name ${NEW_LC} --image-id ${IMAGE} --instance-type t2.micro --key myapp --associate-public-ip-address --security-groups sg-011d764abaaf05b58

echo "create new Launch Configuration ${NEW_LC}"

# Update Auto Scaling Group to use new Launch Configuration
aws autoscaling update-auto-scaling-group --auto-scaling-group-name ${ASG_NAME} --launch-configuration-name ${NEW_LC}

echo "New Launch Configuration is updated in ASG ${NEW_LC}"

# Delete old Auto Scaling Launch Configuration
aws autoscaling delete-launch-configuration --launch-configuration-name ${LC_NAME}

echo "Delete old Launch Configuration"

echo "SUCCESS!"
