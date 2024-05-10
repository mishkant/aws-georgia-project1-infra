resource "aws_codepipeline" "todo_app_codepipeline" {
  name       = "todo-app-codepipeline"
  role_arn   = aws_iam_role.todo_app_codepipeline_role.arn
  depends_on = [aws_ecs_service.app_staging]


  artifact_store {
    location = aws_s3_bucket.todo_app.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        FullRepositoryId     = "mishkant/aws-georgia-project1"
        BranchName           = "main"
        ConnectionArn        = aws_codestarconnections_connection.github_connection.arn
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.todo_app.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.cluster_staging.name
        ServiceName = aws_ecs_service.app_staging.name
      }
    }
  }
}

resource "aws_codestarconnections_connection" "github_connection" {
  name          = "aws-geo-tests-github-conn"
  provider_type = "GitHub"
}
