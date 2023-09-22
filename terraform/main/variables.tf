variable "github_token" {
  description = "token to access and modify github repo configuration"
  type        = string
  sensitive   = true
}

variable "repository_names" {
  type = set(string)
  default = [
    "repo1",
    "repo2",
  ]
}

variable "data_bucket" {
  type = string
}

variable "host_bucket" {
  type = string
}
