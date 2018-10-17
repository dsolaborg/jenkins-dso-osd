#!/bin/sh

sudo $(aws ecr get-login --region us-east-1 --no-include-email)

sudo docker build -t jenkins jenkins/
sudo docker tag jenkins:latest 757687274468.dkr.ecr.us-east-1.amazonaws.com/jenkins:latest
sudo docker push 757687274468.dkr.ecr.us-east-1.amazonaws.com/jenkins:latest


#sudo docker build -t nginx nginx/
#sudo docker tag nginx:latest 757687274468.dkr.ecr.us-east-1.amazonaws.com/nginx:latest
#sudo docker push 757687274468.dkr.ecr.us-east-1.amazonaws.com/nginx:latest


