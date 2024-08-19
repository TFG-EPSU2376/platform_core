resource "random_pet" "random_name" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "s3_portal_front" {
  bucket        = "${var.bucket_name}-${random_pet.random_name.id}"
  force_destroy = true
}


resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.s3_portal_front.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "s3_portal_front_cors" {
  bucket = aws_s3_bucket.s3_portal_front.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "s3_portal_front_acl" {
  bucket     = aws_s3_bucket.s3_portal_front.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3_portal_front.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.s3_portal_front_public_access_block]
}

resource "aws_s3_bucket_public_access_block" "s3_portal_front_public_access_block" {
  bucket = aws_s3_bucket.s3_portal_front.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_portal_front_policy" {
  bucket = aws_s3_bucket.s3_portal_front.id
  lifecycle {
    ignore_changes = [
      policy,
    ]
  }
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_portal_front.id}",
          "arn:aws:s3:::${aws_s3_bucket.s3_portal_front.id}/*"
        ]
      },
      {
        Sid       = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_portal_front.id}",
          "arn:aws:s3:::${aws_s3_bucket.s3_portal_front.id}/*"
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.s3_portal_front_public_access_block]
}


resource "null_resource" "generate_portal_env_and_build_resource" {

  provisioner "local-exec" {
    command = <<EOT
    pwd
    rm -rf ../front/build
    mkdir ../front/build
    cd ../../../of-portal-farmer
    rm -rf .env
    echo "VITE_API_HOST=${var.api_gateway_url}\nVITE_IDENTITY_POOL_ID=${var.identity_pool_id}\nVITE_USER_POOL_ID=${var.user_pool_id}\nVITE_USER_POOL_CLIENT_ID=${var.user_pool_client_id}\nVITE_COGNITO_DOMAIN_URL=${var.cognito_domain_url}" > .env
    cat .env
    npm install
    npm run build
    cp -r dist/* ../of-core/domains/front/build/
    cd ../of-core/utils
    EOT
  }
}



resource "aws_s3_object" "build_files" {
  for_each = fileset("${path.module}/build", "**/*")

  bucket = aws_s3_bucket.s3_portal_front.id
  key    = each.value
  source = "${path.module}/build/${each.value}"
  etag   = filemd5("${path.module}/build/${each.value}")
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
  }, substr(each.value, length(each.value) - length(split(".", each.value)[length(split(".", each.value)) - 1]), length(split(".", each.value)[length(split(".", each.value)) - 1])), "application/octet-stream")



  depends_on = [aws_s3_bucket.s3_portal_front, null_resource.generate_portal_env_and_build_resource]
}

