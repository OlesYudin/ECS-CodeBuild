# iam.tf | IAM Role Policies
resource "aws_iam_role" "ecs-ecr-iam-role" {
  name               = "${var.app_name}-ecs-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_role_policy.json
  tags = {
    Name = "${var.app_name}-iam-role"
  }
}

data "aws_iam_policy_document" "ecs_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Atach policy for ECS
resource "aws_iam_role_policy_attachment" "ecs-iam-policy" {
  role       = aws_iam_role.ecs-ecr-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# Attach policy for ECR
resource "aws_iam_role_policy_attachment" "ecr-iam-policy" {
  role       = aws_iam_role.ecs-ecr-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}


# Codebuild IAM
resource "aws_iam_role" "codebuild-iam-role" {
  name               = "${var.app_name}-codebuild-iam-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_role_policy.json
  tags = {
    Name = "${var.app_name}-${var.env}-codebuild-iam-role"
  }
}


# Policy for Codebuild
data "aws_iam_policy_document" "codebuild_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com", "codepipeline.amazonaws.com"]
    }
  }
}
# Attach pipeline policy to codebuild
resource "aws_iam_role_policy_attachment" "pipeline-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::564667093156:policy/service-role/AWSCodePipelineServiceRole-us-east-2-Pasword-generator-pipeline"
}
# Attach codebuild policy to codebuild
resource "aws_iam_role_policy_attachment" "codebuild-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::564667093156:policy/service-role/CodeBuildBasePolicy-Password-generator-us-east-2"
}
# Atach ECS policy to codebuild
resource "aws_iam_role_policy_attachment" "codebuild-ecs-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# Attach ECR policy to codebuild
resource "aws_iam_role_policy_attachment" "codebuild-ecr-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
# Attach SM policy to codebuild
resource "aws_iam_role_policy_attachment" "codebuild-secret-manager-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
# Attach Pipelinepolicy to codebuild
resource "aws_iam_role_policy_attachment" "codebuild-pipeline-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::564667093156:policy/service-role/AWSCodePipelineServiceRole-us-east-2-Pasword-generator-pipeline"
}
# Attach Full access codebuild policy to codebuild
resource "aws_iam_role_policy_attachment" "codebuild-full-access-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}
# Attach Read access policy IAM to codebuild
resource "aws_iam_role_policy_attachment" "iam-read-only-iam-policy" {
  role       = aws_iam_role.codebuild-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

