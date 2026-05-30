output "cur_bucket_arn" {
  value = aws_s3_bucket.cur.arn
}

output "cur_report_name" {
  value = aws_cur_report_definition.this.report_name
}
