variable "region" {
  description = "AWS region to deploy resources"
  default     = "ap-south-1"
}

variable "env" {
  description = "Environment name (dev/prod)"
  default     = "dev"
}
