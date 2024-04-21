resource "aws_s3_bucket" "s3-bucket" {
  bucket        = "my-tf-nic-bucket"
  force_destroy = true

  tags = {
    Name = "nic-bucket"
    # Environment = "Dev"
  }
}


resource "aws_dynamodb_table" "basic-dynamodb" {
  name           = "nic-FootballScores"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "dynamodb-table-1"
    # Environment = "production"
    #user defined; all argument values are user-defined
  }
}