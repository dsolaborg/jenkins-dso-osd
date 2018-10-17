###################### Jenkins Docker
provider "aws" {
  version = "~> 1.0"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0"
}

# Generate random UUID
resource "random_uuid" "stack_id" {}


################### create aws launch configuration for jenkins

data "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"

  vars {
    s3_bucket = "${var.s3_bucket}"
    ecs_cluster_name = "${var.environment}"
  }
}

resource "aws_launch_configuration" "lc_ecs" {
  name_prefix = "lc_${var.image_name_jenkins}_${var.environment}_${var.owner}"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  security_groups = ["${lookup(var.sg_id, var.environment)}"]
  iam_instance_profile = "${var.ecs_instance_profile}${var.environment}"
  key_name = "${lookup(var.key_name, var.environment)}"
  associate_public_ip_address = true
  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_ecs" {
  name = "asg_${var.environment}_${var.owner}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_capacity}"
  health_check_type = "EC2"
  health_check_grace_period = 300
  launch_configuration = "${aws_launch_configuration.lc_ecs.name}"
  vpc_zone_identifier = "${var.public_subnets_prod}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "jenkins_${var.environment}_${var.owner}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Email"
    value               = "${var.owner_email}"
    propagate_at_launch = true
  }



}

################### create ECS Task for jenkins

data "template_file" "jenkins_task_template" {
  template = "${file("templates/jenkins.json")}"
  vars {
    repository_url = "${var.repository_url_jenkins}"
    log_group_region = "${var.aws_region}"
    log_group_name = "${aws_cloudwatch_log_group.app.name}"
  }
}

####################


############## jenkins
resource "aws_ecs_task_definition" "jenkins" {
  family = "jenkins"
  network_mode = "bridge"
  container_definitions = "${data.template_file.jenkins_task_template.rendered}"

  volume {
    name = "jenkins-home"
    host_path = "/var/jenkins_home"
 }
}

resource "aws_ecs_service" "jenkins" {
  name = "jenkins_${var.environment}_${var.owner}"
  cluster = "${var.environment}"
  task_definition = "${aws_ecs_task_definition.jenkins.arn}"
  desired_count = 1
#  iam_role = "${var.ecs_instance_profile}${var.environment}"

    load_balancer {
      target_group_arn  = "${aws_lb_target_group.front_end.arn}"
      container_name = "${var.image_name_jenkins}"
      container_port = "8080"
    }

 depends_on = ["aws_autoscaling_group.asg_ecs"]
}
########################


########################################################################


resource "aws_lb" "front_end" {
  name               = "alb-${var.environment}-${var.owner}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${lookup(var.sg_id, var.environment)}"]
  subnets            = ["${var.public_subnets_prod}"]

  enable_deletion_protection = false

  tags {
    Name = "cloudwatchloggroup_${random_uuid.stack_id.result}"
    Owner = "${var.owner}"
    Email = "${var.owner_email}"
    Environment = "${var.environment}"
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "tg-${var.environment}${var.owner}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${lookup(var.vpc_id, var.environment)}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path              = "/login"
    interval            = 30
    port                = "8080"
  }
  depends_on = ["aws_lb.front_end"]

}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = "${aws_lb.front_end.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.arn_acme}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.front_end.arn}"
  }
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = "${aws_lb.front_end.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.front_end.arn}"
  }
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = "${aws_lb_listener.front_end_http.arn}"

  action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}


#resource "aws_lb_cookie_stickiness_policy" "foo" {
#  name                     = "awslbcookie${var.owner}"
#  load_balancer            = "${aws_lb.jenkins.id}"
#  lb_port                  = 443
#  cookie_expiration_period = 3600
#}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg_ecs.id}"
  alb_target_group_arn   = "${aws_lb_target_group.front_end.arn}"
}


################### route53

resource "aws_route53_record" "www" {
  zone_id = "${var.zone_id}"
  name    = "${var.owner}-${lookup(var.short_env, var.environment)}.${var.dso_domain}"
  type    = "A"

  alias {
    name                   = "${aws_lb.front_end.dns_name}"
    zone_id                = "${aws_lb.front_end.zone_id}"
    evaluate_target_health = true
  }
}

#################### Cloud Watchlog jenkins

resource "aws_cloudwatch_log_group" "app" {
  name = "app/${var.image_name_jenkins}_${var.environment}_${var.owner}"

  tags {
    Name = "cloudwatchloggroup_${random_uuid.stack_id.result}"
    Owner = "${var.owner}"
    Email = "${var.owner_email}"
    Environment = "${var.environment}"
  }
}
