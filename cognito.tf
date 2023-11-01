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

data "aws_iam_role" "mikes_lambda_pre_sign_up_role" {
  name = "mikes_lambda_pre_sign_up_role"
}

resource "aws_iam_policy" "cognito_lambda_policy" {
  name        = "cognito_lambda_policy"
  description = "Policy to allow Cognito to invoke Lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Effect = "Allow",
        Resource = data.aws_lambda_function.mikes_lambda_pre_sign_up.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_lambda_attachment" {
  policy_arn = aws_iam_policy.cognito_lambda_policy.arn
  role       = data.aws_iam_role.mikes_lambda_pre_sign_up_role.name
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