variable "aws_ou_tags" {
  type = map(object({
    values       = optional(list(string))
    enforced_for = optional(list(string))
  }))
  description = "Map of AWS OU names and their tag policies"
}

variable "tags" {
  type        = map(string)
  description = "Map of AWS resource tags"
  default     = {}
}

variable "target_id" {
  type        = string
  description = "The unique identifier (ID) organizational unit (OU) that you want to attach the policy to."
}

variable "ou_path" {
  type        = string
  description = "Path of the organizational unit (OU)"
}
