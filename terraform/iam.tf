# iam.tf | IAM Role Policies

resource "aws_iam_role" "ecs-ecr-iam-role" {
  name               = "${var.app_name}-iam-role"
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

data "aws_iam_policy_document" "ecr_role_policy" {
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
