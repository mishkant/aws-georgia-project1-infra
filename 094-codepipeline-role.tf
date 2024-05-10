resource "aws_iam_role" "todo_app_codepipeline_role" {
  name = "todo_app_codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.todo_app_codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.todo_app.arn}",
        "${aws_s3_bucket.todo_app.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": [
        "${aws_codebuild_project.todo_app.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecs:*",
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "todo_app_pipeline_policies" {
  statement {
    sid       = ""
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github_connection.arn]
    effect    = "Allow"
  }
  statement {
    sid       = ""
    actions   = ["cloudwatch:*", "s3:*", "codebuild:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "todo_app_pipeline_policy" {
  name        = "todo-app-pipeline-policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.todo_app_pipeline_policies.json
}

resource "aws_iam_role_policy_attachment" "todo_app_pipeline_attachment" {
  policy_arn = aws_iam_policy.todo_app_pipeline_policy.arn
  role       = aws_iam_role.todo_app_codepipeline_role.id
}
