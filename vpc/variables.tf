variable "name" {
  default     = "gtp"
  description = "A name of terraform project"
}

variable "region" {
  default     = "ap-southeast-1"
  description = "default region for GTP"
}

variable "environment" {
  default     = "dev"
  description = "A name of environment"
}
