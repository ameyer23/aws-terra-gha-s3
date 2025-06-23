terraform {
  #Step 10
  # Run init/plan/apply with "backend" commented-out (ueses local backend) to provision Resources (Bucket, Table)
  # Then uncomment "backend" and run init, apply after Resources have been created (uses AWS)
  backend "s3" {
    bucket         = "cc-tf-state-backend-ci-cd-9283hf1c"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Step 8 and 9, added random resource to create globally unique buket name - removed
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

#Step 8 and 9
module "tfstate" {
  source      = "./modules/tfstate"
  #bucket_name = "cc-tf-state-backend-ci-cd-${random_id.bucket_suffix.hex}"
  bucket_name = "cc-tf-state-backend-ci-cd-9283hf1c"
}
