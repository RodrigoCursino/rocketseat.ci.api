resource "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    IAC = true
  }
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = "arn:aws:iam::132466043431:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = [
              "sts.amazonaws.com"
            ]
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:RodrigoCursino/rocketseat.ci.api:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    IAC = true
  }
}
  
resource "aws_iam_role_policy" "ecr-role-inline-policy" {
    name = "ecr-role-inline-policy"
    role = aws_iam_role.ecr-role.name
  
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "Statement1"
          Action   = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
          ],
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
}

