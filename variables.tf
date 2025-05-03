variable "random_string_size" {
  type        = number
  description = "The size of the random string to generate"
  default     = 4
}

variable "working_dir" {
  type        = string
  description = "The working directory for the module"
  default     = null
}
