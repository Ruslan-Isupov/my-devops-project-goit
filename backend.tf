 terraform {
   backend "s3" {
     bucket         = "kubernetes-state-risupov-lesson7"
     key            = "lesson-7/terraform.tfstate"
     region         = "eu-central-1"
     dynamodb_table = "terraform-locks-v2"
     encrypt        = true
   }
 }