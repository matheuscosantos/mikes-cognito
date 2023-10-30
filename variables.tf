variable "region" {
  description = "A região onde os recursos serão criados."
  type        = string
  default     = "us-east-2"
}

variable "states_file" {
  description = "Arquivo de estados."
  type        = string
  default     = "mikes-cognito.tfstate"
}