provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "mikes-cognito-state"
    key            = var.states_file
    region         = var.region
    encrypt        = true
  }
}

resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "mikes-user-pool"
  username_attributes = ["cpf"]
  auto_verified_attributes = ["cpf"]
  lambda_config {
    pre_sign_up = "arn:aws:lambda:us-east-2:644237782704:function:pre-signup-mikes"
  }
  schema {
    name = "cpf"
    attribute_data_type = "String"
    required = true
  }
  password_policy {
    minimum_length = 6
    require_lowercase = false
    require_numbers = false
    require_symbols = false
    require_uppercase = false
  }
  mfa_configuration = "OFF"
}

resource "aws_cognito_user_pool_client" "mikes-app-client" {
  name = "mikes-cognito-app-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["openid", "profile"]
  callback_urls = ["https://example.com/callback"]
  logout_urls = ["https://example.com/logout"]
  supported_identity_providers = ["COGNITO"]
  explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
}