#!/bin/bash
sudo yum update -y

echo ECS_CLUSTER='${ecs_cluster_name}' > /etc/ecs/ecs.config

# Create and set correct permissions for Jenkins mount directory
jenkins_host_dir=/var/jenkins_home
mkdir -p $jenkins_host_dir
chmod -R 777 $jenkins_host_dir
