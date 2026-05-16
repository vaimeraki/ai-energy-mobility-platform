variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ai-energy-mobility"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-ai-energy-mobility-dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "francecentral"
}
