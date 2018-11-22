############## Input from the Deployer

variable "owner" {
  description = "Owner Name"
}
variable "owner_email" {
  description = "Owner Email"
}

variable "dso_domain" {
  default = "dsolab.net"
  description = "DSO Domain name"
}

variable "zone_id" {
 default = "/hostedzone/Z2KBAPVGPRZ50I"
 description = "Zone ID of the Domain"
}

variable "arn_acme" {
  default = "arn:aws:acm:us-east-1:757687274468:certificate/f5b34366-54c1-4814-bd9b-6a9a650238d9"
  description = "certificate arn"
}

############### Input from the LAB stack

variable "environment" {
  description = "The name of the environment"
  default = "development"
}

############### Input from the LAB stack


variable "short_env" {
  type = "map"

  default = {
    production = "jenkins"
    development = "jenkins"
  }
}

variable "key_name" {
  type = "map"

  default = {
    production = "dso-prod-10102018"
    development = "dso-dev-09102018"
  }
}


variable "sg_id" {
  type = "map"

  default = {
    production = "sg-0961c3da3977a5a7c"
    development = "sg-0fe342bca8e2bdbb3"
  }
}

variable "sg_id_alb" {
  type = "map"

  default = {
    production = "sg-04ae233d77045cf0b"
    development = "sg-09cb03ed55daebf67"
  }
}

variable "vpc_id" {
  type = "map"

  default = {
    production = "vpc-082f1b56314869494"
    development = "vpc-03b2e36bfe9a699f7"
  }
}

variable "public_subnets_prod" {
  type = "list"
  default =  ["subnet-07b0dc9a6cc857aa7", "subnet-004db3a8b97237878"]
}

variable "public_subnets_dev" {
  type = "list"
  default = ["subnet-0b4040784bfa89a64", "subnet-069fdaba976a5e0b0"]
}

variable "private_subnets_prod" {
  type = "list"
  default = ["subnet-0d26f005d88b4db98", "subnet-02e1f40ac58f5aa9d"]

}

variable "private_subnets_dev" {
  type = "list"
  default = ["subnet-0738b4febb89b26a4", "subnet-078cfa6f27205eaa9"]
}

variable "subnet_id" {
  description = "Subnet for jenkins"
  type = "map"

  default = {
    production =  "subnet-07b0dc9a6cc857aa7"
    development =  "subnet-069fdaba976a5e0b0"
  }
}


############## TODO

variable "ecs_instance_profile" {
  default = "iam_instance_profile_"
  description = "ECS Role Name"
}

##########################

variable "aws_region" {
  default = "us-east-1"
  description = "AWS region"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  type = "list"
  description = "AWS AZ"
}


############### Storage

variable "s3_bucket" {
  default = "dso-lab-2018appseco"
  description = "S3 bucket where remote state and Jenkins data will be stored."
}

variable "restore_backup" {
  default = false
  description = "Whether or not to restore Jenkins backup."
}

variable "repository_url_jenkins" {
  default = "757687274468.dkr.ecr.us-east-1.amazonaws.com/jenkins"
  description = "Repo URL image name."
}

variable "repository_url_nginx" {
  default = "757687274468.dkr.ecr.us-east-1.amazonaws.com/nginx"
  description = "Repo URL image name."
}


############### ECS

variable "image_name_jenkins" {
  default = "jenkins"
  description = "Jenkins image name."
}

variable "image_name_nginx" {
  default = "nginx"
  description = "Nginx image name."
}


variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
  default = {
    us-east-1 = "ami-0b9a214f40c38d5eb"
    us-east-2 = "ami-09a64272e7fe706b6"
  }
}

variable "instance_type" {
  default = "t2.medium"
  description = "Ec2 instance for the ECS"
}

################## Auto Scaling group
variable "min_size" {
  default = 1
  description = "Minimum number of EC2 instances."
}

variable "max_size" {
  default = 2
  description = "Maximum number of EC2 instances."
}

variable "desired_capacity" {
  default = 1
  description = "Desired number of EC2 instances."
}
