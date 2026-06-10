variable "project_name"        { type = string }
variable "environment"         { type = string }
variable "instance_ids"        { type = list(string) }
variable "alarm_email"         { type = string }
variable "cpu_alarm_threshold" { 
    type = number 
    default = 75 
}