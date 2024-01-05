variable "cloudwatch_alarm_name" {
  description = "The name of the CloudWatch alarm"
  type        = string
}

variable "cloudwatch_alarm_description" {
  description = "The description of the alarm"
  type        = string
}

variable "cloudwatch_alarm_metric_name" {
  description = "The name of the metric to monitor"
  type        = string
}

variable "cloudwatch_alarm_namespace" {
  description = "The namespace of the metric"
  type        = string
}

variable "cloudwatch_alarm_period" {
  description = "The length of each period in seconds"
  type        = string
}

variable "cloudwatch_alarm_statistic" {
  description = "The statistic to apply to the metric"
  type        = string
}

variable "cloudwatch_alarm_threshold" {
  description = "The threshold value for the alarm"
  type        = string
}

variable "cloudwatch_alarm_comparison_operator" {
  description = "The comparison operator for the alarm"
  type        = string
}

variable "cloudwatch_alarm_evaluation_periods" {
  description = "The number of periods over which data is compared to the threshold"
  type        = string
}

variable "cloudwatch_alarm_alarm_actions" {
  description = "The list of ARNs of actions to take when the alarm state is triggered"
  type        = list(string)
}

variable "cloudwatch_alarm_dimensions" {
  description = "The dimensions for the alarm"
  type        = map(string)
}
