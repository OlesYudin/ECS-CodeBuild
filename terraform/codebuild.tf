# CodeBuild Project
resource "aws_codebuild_project" "password-generator-codebuild-plan" {
  depends_on    = [aws_iam_role.codebuild-iam-role]
  name          = "Password-generator-${var.env}-codebuild-plan"
  description   = "CodeBuild project for password generator application"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild-iam-role.arn # TODO: Create own IAM role and policy

  # Артефакты, которые можно хранить в S3 bucket в качестве архива. 
  artifacts {
    type = "NO_ARTIFACTS" # This type dont keep artifacts anywhere
  }
  # Cache можно хранить локально или в S3 bucket 
  cache {
    type = "NO_CACHE" # This type dont keep cache anywhere
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL" # Free 100minutes of build per month
    # Image can take from official Terraform Docker image, your custom Docker image or from this official AWS:
    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image = "aws/codebuild/standard:4.0"
    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
    type                        = "LINUX_CONTAINER" # ARM container use general1.small image type
    image_pull_credentials_type = "CODEBUILD"       # Type of credentials AWS CodeBuild uses to pull images in your build
    privileged_mode             = true              # All command in pipeline will run with sudo

    environment_variable {
      name  = "environment"
      value = var.env
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_url
    buildspec       = var.buildspec
    git_clone_depth = 1

    report_build_status = "true" # Whether to report the status of a build's start and finish to your source provider.
  }

  source_version = "main"

  tags = {
    Environment = var.env
  }
}

# AWS Pipeline
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook
# Manages a CodeBuild webhook, which is an endpoint accepted by the CodeBuild service 
# to trigger builds from source code repositories. Depending on the source type of the CodeBuild project, 
# the CodeBuild service may also automatically create and delete the actual repository webhook as well.
resource "aws_codebuild_webhook" "password-generator-webhook" {
  project_name = aws_codebuild_project.password-generator-codebuild-plan.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH" # What event will be to start webhook
    }

    filter {
      type    = "HEAD_REF"
      pattern = var.github_branch # In what branch will trigger to webhook
    }
  }
}

resource "aws_ssm_parameter" "ssm-github-auth" {
  name        = "GitHubAuth-${var.app_name}-${var.env}"
  description = "Github token for codebuild auth"
  type        = "SecureString"
  value       = var.github_credential

  tags = {
    name = "GitHubAuth"
    env  = var.env
  }
}

resource "aws_codebuild_source_credential" "github-auth-credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = aws_ssm_parameter.ssm-github-auth.value
}



# # Codestar connection
# # Resource for github connections v2
# resource "aws_codestarconnections_connection" "github-codestar-connect" {
#   name          = "github-codestar-connect"
#   provider_type = "GitHub"
# }

# # Pipeline
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline
# resource "aws_codepipeline" "password-generator-codepipeline" {
#   name     = "Password-generator-${var.env}-codepipeline"
#   role_arn = aws_iam_role.codebuild-iam-role.arn

#   artifact_store {
#     location = "aws_s3_bucket.codebuild-s3.name
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeStarSourceConnection"
#       version          = "1"
#       region           = var.region
#       run_order        = 1
#       namespace        = "SourceVariables"
#       output_artifacts = ["SourceArtifact"]

#       configuration = {
#         BranchName           = var.github_branch
#         FullRepositoryId     = var.github_repository_id
#         ConnectionArn        = aws_codestarconnections_connection.github-codestar-connect.arn
#         OutputArtifactFormat = "CODE_ZIP"
#       }
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       version          = "1"
#       region           = var.region
#       run_order        = 1
#       namespace        = "BuildVariables"
#       input_artifacts  = ["SourceArtifact"]
#       output_artifacts = ["BuildArtifact"]

#       configuration = {
#         ProjectName = aws_codebuild_project.password-generator-codebuild-plan.name
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "ECS"
#       version         = "1"
#       run_order       = 1
#       region          = var.region
#       namespace       = "DeployVariables"
#       input_artifacts = ["BuildArtifact"]

#       configuration = {
#         ClusterName = aws_ecs_cluster.ecs-cluster.name
#         ServiceName = aws_ecs_service.password-generator.name
#       }
#     }
#   }
# }
