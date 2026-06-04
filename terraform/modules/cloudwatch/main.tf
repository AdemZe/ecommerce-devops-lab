# MODULE: CLOUDWATCH
# Creates: SNS Topic, CPU Alarm per instance



locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ── SNS TOPIC ────────────────────────────────────────────────
resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-cpu-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ── CPU ALARM per instance ───────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = length(var.instance_ids)

  alarm_name          = "${local.name_prefix}-cpu-high-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120   # 2 minutes
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "CPU > ${var.cpu_alarm_threshold}% for 2 consecutive periods"

  dimensions = {
    InstanceId = var.instance_ids[count.index]
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = { Name = "${local.name_prefix}-cpu-alarm-${count.index + 1}" }
}
