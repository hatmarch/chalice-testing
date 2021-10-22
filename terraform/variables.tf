variable "demo_sns_topic_name" {
  type        = string
  description = "Name of the sns_topic to be used with demo"
}

variable "resource_tag" {
    type = string
    description = "The value of the 'service' tag that should be put on every resource created"
}