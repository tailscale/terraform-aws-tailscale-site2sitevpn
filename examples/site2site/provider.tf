provider "aws" {
    alias = "west"
    region = "us-west-2"
}

provider "aws" {
    alias = "east"
    region = "us-east-1"
}
