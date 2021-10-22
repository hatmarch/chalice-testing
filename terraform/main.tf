terraform {
  required_version = "~> 1.0"
}

provider "aws" {

  default_tags {
    tags = {
      service = "${var.resource_tag}"
    }
  }
}

resource "aws_sns_topic" "topic" {
  name              = "${var.demo_sns_topic_name}"
  kms_master_key_id = "alias/aws/sns"
}