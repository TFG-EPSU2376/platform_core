output "s3_bucket_domain_name" {
  value = aws_s3_bucket.s3_portal_front.bucket_domain_name
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_portal_front_distribution.domain_name
}

