data "aws_iam_policy_document" "eks_log_group_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "eks_log_group_role" {
  name = "eks-log-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_log_group_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "eks_log_group_AmazonEKSWorkerNodePolicy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_log_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_log_group_AmazonEKS_CNI_Policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_log_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_log_group_AmazonEC2ContainerRegistryReadOnly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_log_group_role.name
}

#resource "aws_eks_node_group" "example" {
#  cluster_name    = aws_eks_cluster.eks_deployment_cluster.name
#  node_group_name = "eks-deployment-log-group"
#  node_role_arn   = aws_iam_role.eks_log_group_role.arn
#  subnet_ids      = [aws_subnet.eks_deployment_private_subnet["us-east-1a"].id]
#
#  capacity_type  = "ON_DEMAND"
#  disk_size = 20
#  instance_types = ["t2.medium"]
#
#  scaling_config {
#    desired_size = 2
#    max_size     = 4
#    min_size     = 1
#  }
#
#  update_config {
#    max_unavailable = 1
#  }
#
#  depends_on = [
#    aws_iam_role_policy_attachment.eks_log_group_AmazonEC2ContainerRegistryReadOnly_attachment,
#    aws_iam_role_policy_attachment.eks_log_group_AmazonEKS_CNI_Policy_attachment,
#    aws_iam_role_policy_attachment.eks_log_group_AmazonEKSWorkerNodePolicy_attachment,
#    aws_iam_role_policy_attachment.eks_deployment_role_policy_attachment,
#    aws_eks_addon.eks_deployment_cluster_add_ons
#  ]
#}