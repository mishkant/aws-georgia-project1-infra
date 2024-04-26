provider "aws" {
  region  = "us-east-1"
  profile = "aws-tests"
}

terraform {
  backend "s3" {
    profile        = "aws-tests"
    bucket         = "aws-todo-project1"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "us-east-1"
    dynamodb_table = "aws-todo-lock"
  }
}

data "aws_caller_identity" "current" {}