#!/bin/bash

# Define variables
TERRAFORM_DIR="./" # Specify the directory containing your Terraform files
VAR_FILE="terraform.tfvars" # Change this if you use a different variables file

# Change to Terraform directory
cd $TERRAFORM_DIR || { echo "Directory $TERRAFORM_DIR not found"; exit 1; }

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -input=false
if [ $? -ne 0 ]; then
  echo "Terraform initialization failed!"
  exit 1
fi

# Validate Terraform files
echo "Validating Terraform configuration..."
terraform validate
if [ $? -ne 0 ]; then
  echo "Terraform validation failed!"
  exit 1
fi

# Plan Terraform deployment
echo "Creating Terraform plan..."
terraform plan -var-file=$VAR_FILE -out=tfplan
if [ $? -ne 0 ]; then
  echo "Terraform plan creation failed!"
  exit 1
fi

# Apply Terraform plan
echo "Applying Terraform plan..."
terraform apply -input=false tfplan
if [ $? -ne 0 ]; then
  echo "Terraform apply failed!"
  exit 1
fi

echo "Terraform deployment completed successfully!"
