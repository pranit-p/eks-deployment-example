data "aws_iam_policy_document" "eks_deployment_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "eks_deployment_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_deployment_role_policy_document.json
  name               = "EKSDeploymentRole"
}

data "aws_iam_policy_document" "eks_deployment_policy_document" {

  statement {
    sid    = "AllowToUseAWSAccountForEKSDeployment"
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_deployment_role_policy" {
  name        = "eks-deployment-role-policy"
  description = "Allow EKS cluster to create resources in AWS account"
  policy      = data.aws_iam_policy_document.eks_deployment_policy_document.json
}

resource "aws_iam_role_policy_attachment" "eks_deployment_role_policy_attachment" {
  role       = aws_iam_role.eks_deployment_role.name
  policy_arn = aws_iam_policy.eks_deployment_role_policy.arn
}

locals {
  cluster_add_on = ["coredns","kube-proxy","coredns","eks-pod-identity-agent"]
}

resource "aws_eks_addon" "eks_deployment_cluster_add_ons" {
  for_each = toset(local.cluster_add_on)
  cluster_name                = aws_eks_cluster.eks_deployment_cluster.name
  addon_name                  = each.value
}

resource "aws_eks_cluster" "eks_deployment_cluster" {
  name     = "eks-deployment-cluster"
  role_arn = aws_iam_role.eks_deployment_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_deployment_private_subnet["us-east-1a"].id,
      aws_subnet.eks_deployment_private_subnet["us-east-1b"].id,
    ]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_log_group_AmazonEC2ContainerRegistryReadOnly_attachment,
    aws_iam_role_policy_attachment.eks_log_group_AmazonEKS_CNI_Policy_attachment,
    aws_iam_role_policy_attachment.eks_log_group_AmazonEKSWorkerNodePolicy_attachment,
    aws_iam_role_policy_attachment.eks_deployment_role_policy_attachment
  ]
}


