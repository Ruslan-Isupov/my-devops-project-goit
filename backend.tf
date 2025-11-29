# terraform {
#   backend "s3" {
#     bucket         = "gitops-state-risupov-lesson8"
#     key            = "lesson-8/terraform.tfstate"
#     region         = "eu-central-1"
#     dynamodb_table = "terraform-locks-8"
#     encrypt        = true
#   }
# }