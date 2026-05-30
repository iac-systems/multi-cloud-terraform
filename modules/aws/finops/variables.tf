variable "bucket_name" {
  description = "Name of the S3 bucket to store CUR reports"
  type        = string
}

variable "report_name" {
  description = "Name of the CUR report"
  type        = string
  default     = "platform-cost-report"
}
