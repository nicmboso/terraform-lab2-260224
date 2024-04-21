# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
  # profile = "lead"
}

#the block giving terraform instructions on how to behave
terraform {
  backend "s3" {
    /*to store the state file i.e terraform.tfstate file in;
    remote s3 and dynamodb table created in remote-stores folder*/
    bucket = "my-tf-nic-bucket" #name of s3 bucket in remote-stores folder
    /*create infrastructure and terraformstate folders;
    and place the state file in this location
    this ensures the state file not to be stored locally in infras folder but
    in remote location specified below */
    key            = "infrastructure/terraformstate" #location to store the state file
    dynamodb_table = "nic-FootballScores"            #name of dynamodb in remote-stores folder
    region         = "eu-west-1"
    # profile = "lead"

  }
}