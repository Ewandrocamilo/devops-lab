variable "site_bucket_name" {
  description = "Globally unique name for the private static-site bucket"
  type        = string

  validation {
    condition     = length(var.site_bucket_name) >= 3 && length(var.site_bucket_name) <= 63 && can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.site_bucket_name))
    error_message = "Use a globally unique S3 bucket name with 3-63 lowercase letters, numbers, dots, or hyphens."
  }
}

variable "github_actions_role_name" {
  description = "Existing IAM role assumed by the GitHub Actions OIDC workflow"
  type        = string
  default     = "devops-lab-github-actions-role"
}
