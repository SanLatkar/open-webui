terraform {
    backend "s3" {
        bucket = "open-webui-sanket-latkar"
        key = "openwebui/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "terraform-state-lock"
        encrypt        = true
    }
}