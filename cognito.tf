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

resource "aws_cognito_user_pool_client" "mikes-app-client" {
  name                                 = "mikes-cognito-app-client"
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

resource "aws_iam_policy" "mikes_lambda_pre_sign_up_policy" {
  name        = "cognito-pre-signup-lambda-policy"
  description = "Política para autorizar invocação da lambda quando ocorrer um sign up no cognito"

  policy = jsonencode({
    Version = "2012-10-17",
    Id = "default",
    Statement = [
      {
        Sid = "PreSignUpLambda"
        Effect = "Allow",
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        },
        Action = "lambda:InvokeFunction",
        Resource = data.aws_lambda_function.mikes_lambda_pre_sign_up.arn,
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mikes_lambda_pre_sign_up_policy_attachment" {
  policy_arn = aws_iam_policy.mikes_lambda_pre_sign_up_policy.arn
  role       = data.aws_lambda_function.mikes_lambda_pre_sign_up.role
}