output "sns_topic_arn"   { value = aws_sns_topic.alerts.arn }
output "alarm_names"     { value = aws_cloudwatch_metric_alarm.cpu_high[*].alarm_name }
