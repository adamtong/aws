#
# variables.tf
#
variable "region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region"
}

variable "key_name" {
  type        = string
  default     = "solhem104-keypair"
  description = "The key name of an exiting key pair for Public Key Authentication"
}

