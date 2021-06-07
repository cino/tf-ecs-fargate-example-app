variable "project_name" {
  type        = string
  description = "Project name in kebab-case"
  default     = "terraform-test"
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
  default     = "eu-central-1"
}
