variable "billing_mode" {
  default     = "PROVISIONED"
  description = "DynamoDB billing mode"
}

variable "read_capacity" {
  default     = 5
  description = "DynamoDB read capacity units"
}

variable "write_capacity" {
  default     = 5
  description = "DynamoDB write capacity units"
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable"
  default     = false
}

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Enable DynamoDB point-in-time recovery"
  default     = true
}

variable "enable_server_side_encryption" {
  type        = bool
  description = "Enable DynamoDB server-side encryption"
  default     = true
}

variable "terraform_backend_config_file_name" {
  type        = string
  default     = "terraform.tf"
  description = "Name of terraform backend config file"
}

variable "terraform_backend_config_file_path" {
  type        = string
  default     = ""
  description = "Directory for the terraform backend config file, usually `.`. The default is to create no file."
}

variable "terraform_backend_config_template_file" {
  type        = string
  default     = ""
  description = "The path to the template used to generate the config file"
}

variable "terraform_state_file" {
  type        = string
  default     = "terraform.tfstate"
  description = "The path to the state file inside the bucket"
}

variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket name."
}

variable "bucket_enabled" {
  type        = bool
  default     = true
  description = "Whether to create the s3 bucket."
}

variable "dynamodb_enabled" {
  type        = bool
  default     = true
  description = "Whether to create the dynamodb table."
}

variable "dynamodb_table_name" {
  type        = string
  default     = null
  
}
