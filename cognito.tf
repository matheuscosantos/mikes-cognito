provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket  = "mikes-terraform-state"
    key     = "mikes-cognito.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

data "aws_lambda_function" "mikes_lambda_pre_sign_up" {
  function_name = "mikes_lambda_pre_sign_up"
}

resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "mikes-user-pool"

  lambda_config {
    pre_sign_up = data.aws_lambda_function.mikes_lambda_pre_sign_up.arn
  }

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
  mfa_configuration = "OFF"
}

resource "aws_cognito_user_pool_client" "mikes_app_client" {
  name                                 = "mikes_app_client"
  user_pool_id                         = aws_cognito_user_pool.cognito_user_pool.id
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "profile"]
  callback_urls                        = ["https://example.com/callback"]
  logout_urls                          = ["https://example.com/logout"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_lambda_permission" "mikes_lambda_pre_sign_up_permission" {
  principal     = "cognito-idp.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.mikes_lambda_pre_sign_up.function_name
  source_arn    = aws_cognito_user_pool.cognito_user_pool.arn
}

resource "aws_cognito_user" "mikes_admin_user" {
  username                 = "admin@mikes.com"
  user_pool_id             = aws_cognito_user_pool.cognito_user_pool.id
  force_alias_creation     = true
  message_action           = "SUPPRESS"
  desired_delivery_mediums = ["EMAIL"]

  attributes = {
    email          = "admin@mikes.com"
    email_verified = true
  }
}