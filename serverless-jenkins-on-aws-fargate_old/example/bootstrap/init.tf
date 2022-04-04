provider "aws" {
  region  = "us-west-1"
  profile = "iamadmin-dev"
}

resource "random_id" "id" {
	  byte_length = 8
}