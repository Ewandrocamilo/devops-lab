output "site_bucket_name" {
  description = "S3 bucket used by the GitHub Actions deployment"
  value       = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  description = "CloudFront distribution ID used by the GitHub Actions deployment"
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_domain_name" {
  description = "Public HTTPS URL hostname for the static site"
  value       = aws_cloudfront_distribution.site.domain_name
}
