# AWS Infra terraform

Terraform template for Dify on AWS

## Premise and summary

- VPC 
- Forward Proxy 
- ElastiCache Redis 
- PostgreSQL &`pgvector Vector Storage 
- Aurora PostgreSQL Serverless

## Prerequisites

- Terraform

## Usage

1. Clone this repository
2. Edit `terraform.tfvars` to set your variables
3. Edit `backend.tf` to set your S3 bucket and DynamoDB table
4. Run `terraform init`
5. Run `terraform plan`
6. Run `terraform apply -target aws_rds_cluster_instance.dify`
7. Execute the following SQL in the RDS cluster

    ```sql
    CREATE ROLE dify WITH LOGIN PASSWORD 'your-password';
    GRANT dify TO postgres;
    CREATE DATABASE dify WITH OWNER dify;
    \c dify
    CREATE EXTENSION vector;
    ```

8. Run `terraform apply`
9. Run `terraform apply` again, if task is not started
