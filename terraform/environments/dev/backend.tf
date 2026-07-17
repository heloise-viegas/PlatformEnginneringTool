terraform {
  backend "s3" {
    bucket         = "tf-hv-state-bucket"
    key            = "netanalyzer/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-lock-dynamodb-table"
    encrypt        = true
  }
}
