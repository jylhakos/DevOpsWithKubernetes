#!/bin/bash

# Script to create IAM roles and policies for EKS
# Usage: ./setup-iam.sh

set -e

echo "Creating IAM roles and policies for EKS..."

# Create EKS Cluster Service Role
echo "Creating EKS Cluster Service Role..."
aws iam create-role \
    --role-name EKSClusterRole \
    --assume-role-policy-document file://eks-cluster-role-trust-policy.json \
    --description "EKS Cluster Service Role"

# Attach required policies to EKS Cluster Role
aws iam attach-role-policy \
    --role-name EKSClusterRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Create EKS Node Group Role
echo "Creating EKS Node Group Role..."
aws iam create-role \
    --role-name EKSNodeGroupRole \
    --assume-role-policy-document file://eks-nodegroup-role-trust-policy.json \
    --description "EKS Node Group Role"

# Attach required policies to EKS Node Group Role
aws iam attach-role-policy \
    --role-name EKSNodeGroupRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy \
    --role-name EKSNodeGroupRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

aws iam attach-role-policy \
    --role-name EKSNodeGroupRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

# Create ECR policy for pushing images
echo "Creating ECR access policy..."
cat > ecr-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": "*"
        }
    ]
}
EOF

aws iam create-policy \
    --policy-name ECRAccessPolicy \
    --policy-document file://ecr-policy.json \
    --description "Policy for ECR access"

# Get current user ARN and attach ECR policy
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
USER_NAME=$(echo $USER_ARN | cut -d'/' -f2)

aws iam attach-user-policy \
    --user-name $USER_NAME \
    --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/ECRAccessPolicy

echo "IAM roles and policies created successfully!"
echo ""
echo "Created roles:"
echo "- EKSClusterRole"
echo "- EKSNodeGroupRole"
echo ""
echo "Created policies:"
echo "- ECRAccessPolicy"
echo ""
echo "Note: It may take a few minutes for the roles to propagate."

# Clean up temporary files
rm -f ecr-policy.json
