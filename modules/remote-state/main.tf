locals {
  bucket_enabled   =  var.bucket_enabled
  dynamodb_enabled =  var.dynamodb_enabled

  dynamodb_table_name = var.dynamodb_table_name


  
  terraform_backend_config_file = format(
    "%s/%s",
    var.terraform_backend_config_file_path,
    var.terraform_backend_config_file_name
  )

  terraform_backend_config_template_file = var.terraform_backend_config_template_file != "" ? var.terraform_backend_config_template_file : "${path.module}/templates/terraform.tf.tpl"

  terraform_backend_config_content = templatefile(local.terraform_backend_config_template_file, {
    region = data.aws_region.current.name
    bucket = join("", aws_s3_bucket.default.*.id)

    dynamodb_table = local.dynamodb_enabled ? element(
      coalescelist(
        aws_dynamodb_table.with_server_side_encryption.*.name,
      ),
      0
    ) : ""

    encrypt = var.enable_server_side_encryption ? "true" : "false"
    terraform_state_file = var.terraform_state_file
  
  })

  bucket_name = var.s3_bucket_name
  }
resource "aws_s3_bucket" "default" {
  count = local.bucket_enabled ? 1 : 0
  bucket        = substr(local.bucket_name, 0, 63)
  force_destroy = var.force_destroy
  
}



resource "aws_s3_bucket_versioning" "default" {
  count = local.bucket_enabled ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  versioning_configuration {
    status     = "Enabled"
  
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count = local.bucket_enabled ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      
    }
  }
}

resource "aws_dynamodb_table" "with_server_side_encryption" {
  count          = local.dynamodb_enabled ? 1 : 0
  name           = local.dynamodb_table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  hash_key = "LockID"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  
}
data "aws_region" "current" {}

resource "local_file" "terraform_backend_config" {
  count           = var.terraform_backend_config_file_path != "" ? 1 : 0
  content         = local.terraform_backend_config_content
  filename        = local.terraform_backend_config_file
  file_permission = "0644"
}
