data "aws_ami" "web-ami" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.web-ami-identifier]
  }
  owners = [var.web-ami-image-owner] 
}
data "aws_ami" "app-ami" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.app-ami-identifier]
  }
  owners = [var.app-ami-image-owner] 
}
data "aws_security_group" "web-tier-sg" {
  filter {
    name = "tag:Name"
    values = [var.web-tier-sg-name]
  }
}
data "aws_security_group" "app-tier-sg" {
  filter {
    name = "tag:Name"
    values = [var.app-tier-sg-name]
  }
}

data "aws_subnet" "web-public-subnet1"{
    filter {
      name = "tag:Name"
      values = [var.web-public-subnet1]
    }
}
data "aws_subnet" "web-public-subnet2"{
    filter {
      name = "tag:Name"
      values = [var.web-public-subnet2]
    }
}

data "aws_subnet" "app-private-subnet1" {
    filter {
      name = "tag:Name"
      values = [var.app-private-subnet1]
    }
} 
data "aws_subnet" "app-private-subnet2" {
    filter {
      name = "tag:Name"
      values = [var.app-private-subnet2]
    }
} 

data "aws_lb_target_group" "web-http-target-group" {
  tags= {
    Name = var.web-http-target-group-name
  }
}
data "aws_lb_target_group" "web-https-target-group" {
  tags= {
    Name = var.web-https-target-group-name
  }
}
data "aws_lb_target_group" "app-target-group" {
  tags= {
    Name = var.app-target-group-name
  }
}
# --------------------- Launch templates ---------------------
resource "aws_launch_template" "web-launch-template" {
  name = var.web-launch-template-name
  image_id = data.aws_ami.web-ami.image_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_security_group.web-tier-sg]

  tags = {
    Name = var.web-launch-template-name
  }
# The actual app, imo: - with packer create a custom image and then change aws_ami data source to reference it - using ansible
#   OR user_data = filebase64("./deployyourapp.sh")
}
resource "aws_launch_template" "app-launch-template" {
  name = var.app-launch-template-name
  image_id = data.aws_ami.app-ami.image_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_security_group.app-tier-sg]
# The actual app, imo: - with packer create a custom image and then change aws_ami data source to reference it - using ansible
#  OR  user_data = filebase64("./deployyourapp.sh")
  tags = {
    Name = var.app-launch-template-name
  }
}

# --------------------- Autoscaling groups ---------------------

resource "aws_autoscaling_group" "web-asg" {
  name = var.web-asg-name
  vpc_zone_identifier = [data.aws_subnet.web-public-subnet1.id,data.aws_subnet.web-public-subnet2.id]
  min_size = 2
  max_size = 4
  launch_template {
    id = aws_launch_template.web-launch-template.id
    version = aws_launch_template.web-launch-template.latest_version
  }
  health_check_type = "ELB"
  health_check_grace_period = 300
  target_group_arns = [data.aws_lb_target_group.web-http-target-group.arn,data.aws_lb_target_group.web-https-target-group.arn]
  force_delete = true
  tag {
    key = "Name"
    value = var.web-asg-name
    propagate_at_launch = true
  }
}



resource "aws_autoscaling_group" "app-asg" {
  name = var.app-asg-name
  vpc_zone_identifier = [data.aws_subnet.app-private-subnet1.id,data.aws_subnet.app-private-subnet2.id]
  min_size = 2
  max_size = 4
  launch_template {
    id = aws_launch_template.app-launch-template.id
    version = aws_launch_template.app-launch-template.latest_version
  }
  health_check_type = "ELB"
  health_check_grace_period = 300
  target_group_arns = [data.aws_lb_target_group.app-target-group.arn]
  force_delete = true
  tag {
    key = "Name"
    value = var.app-asg-name
    propagate_at_launch = true
  }
}


# --------------------- Autoscaling policies and alarms ---------------------
                # ----------- WEB -----------
resource "aws_autoscaling_policy" "web-cpu-policy-scaleup" {
  name = "web-scaleup"
  autoscaling_group_name = aws_autoscaling_group.web-asg.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1 #Add one
  cooldown = 60 # 60 seconds after scaling activity completes and before the next scaling activity can start
  policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "web-cpu-policy-scaleup-alarm" {
  alarm_name = "web-cpu-policy-scaleup-alarm"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  alarm_description = "Alarm when CPU usage increases"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold = 70
  evaluation_periods = 2 #number of periods over which data is compared to the threshold

  statistic = "Average"
  period = 120 #120s period over which statistic is applied

  dimensions = {
    "AutoScalingGroupName": aws_autoscaling_group.web-asg.name
  }

  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.web-cpu-policy-scaleup.arn] #execute when alarm transitions into ALARM state
}

resource "aws_autoscaling_policy" "web-cpu-policy-scaledown" {
  name = "web-scaledown"
  autoscaling_group_name = aws_autoscaling_group.web-asg.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1 #Remove one
  cooldown = 60 # 60 seconds after scaling activity completes and before the next scaling activity can start
  policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "web-cpu-policy-scaledown-alarm" {
  alarm_name = "web-cpu-policy-scaledown-alarm"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  alarm_description = "Alarm when CPU usage decreases"

  comparison_operator = "LessThanOrEqualToThreshold"
  threshold = 50
  evaluation_periods = 2 #number of periods over which data is compared to the threshold

  statistic = "Average"
  period = 120 #120s period over which statistic is applied

  dimensions = {
    "AutoScalingGroupName": aws_autoscaling_group.web-asg.name
  }

  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.web-cpu-policy-scaledown.arn] #execute when alarm transitions into ALARM state
}

                # ----------- APP -----------
resource "aws_autoscaling_policy" "app-cpu-policy-scaleup" {
  name = "app-scaleup"
  autoscaling_group_name = aws_autoscaling_group.app-asg.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1 #Add one
  cooldown = 60 # 60 seconds after scaling activity completes and before the next scaling activity can start
  policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "app-cpu-policy-scaleup-alarm" {
  alarm_name = "app-cpu-policy-scaleup-alarm"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  alarm_description = "Alarm when CPU usage increases"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold = 70
  evaluation_periods = 2 #number of periods over which data is compared to the threshold

  statistic = "Average"
  period = 120 #120s period over which statistic is applied

  dimensions = {
    "AutoScalingGroupName": aws_autoscaling_group.app-asg.name
  }

  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.app-cpu-policy-scaleup.arn] #execute when alarm transitions into ALARM state
}

resource "aws_autoscaling_policy" "app-cpu-policy-scaledown" {
  name = "app-scaledown"
  autoscaling_group_name = aws_autoscaling_group.app-asg.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1 #Remove one
  cooldown = 60 # 60 seconds after scaling activity completes and before the next scaling activity can start
  policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "app-cpu-policy-scaledown-alarm" {
  alarm_name = "app-cpu-policy-scaledown-alarm"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  alarm_description = "Alarm when CPU usage decreases"

  comparison_operator = "LessThanOrEqualToThreshold"
  threshold = 50
  evaluation_periods = 2 #number of periods over which data is compared to the threshold

  statistic = "Average"
  period = 120 #120s period over which statistic is applied

  dimensions = {
    "AutoScalingGroupName": aws_autoscaling_group.app-asg.name
  }

  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.app-cpu-policy-scaledown.arn] #execute when alarm transitions into ALARM state
}