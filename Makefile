# ============================================================================
# TERRAFORM MAKEFILE
# ============================================================================

# Default environment
ENV ?= dev

# AWS Profile (can override: make apply ENV=dev AWS_PROFILE=my-profile)
AWS_PROFILE ?= mixcre-dev

# Terraform variables files
TF_VARS = -var-file="env/$(ENV)/commons.tfvars" \
          -var-file="env/$(ENV)/vpcs.tfvars" \
          -var-file="env/$(ENV)/nat.tfvars" \
          -var-file="env/$(ENV)/alb.tfvars" \
          -var-file="env/$(ENV)/ecs.tfvars" \
          -var-file="env/$(ENV)/rds.tfvars"

# Backend config
# BACKEND_CONFIG = -backend-config="env/$(ENV)/backend.hcl"

.PHONY: help init plan apply destroy fmt validate clean output refresh

# Help command
help:
	@echo "==================================================================="
	@echo "Terraform Management Commands"
	@echo "==================================================================="
	@echo "Usage: make [target] ENV=<environment>"
	@echo ""
	@echo "Available targets:"
	@echo "  init        - Initialize terraform with backend"
	@echo "  plan        - Show terraform plan"
	@echo "  apply       - Apply terraform changes"
	@echo "  destroy     - Destroy all infrastructure"
	@echo "  fmt         - Format terraform files"
	@echo "  validate    - Validate terraform configuration"
	@echo "  output      - Show terraform outputs"
	@echo "  refresh     - Refresh terraform state"
	@echo "  clean       - Clean terraform cache"
	@echo ""
	@echo "Helper targets:"
	@echo "  logs-fe     - Show frontend ECS logs"
	@echo "  logs-be     - Show backend ECS logs"
	@echo ""
	@echo "Examples:"
	@echo "  make plan ENV=dev"
	@echo "  make apply ENV=prod"
	@echo "==================================================================="

# Initialize terraform
init:
	@echo "Initializing Terraform for ENV=$(ENV)..."
	terraform init

# Format terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Validate terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Show terraform plan
plan:
	@echo "Creating Terraform plan for ENV=$(ENV)..."
	terraform plan $(TF_VARS)

# Apply terraform changes
apply:
	@echo "Applying Terraform changes for ENV=$(ENV)..."
	terraform apply $(TF_VARS)

# Auto approve apply (use with caution)
apply-auto:
	@echo "Auto-applying Terraform changes for ENV=$(ENV)..."
	terraform apply -auto-approve $(TF_VARS)

# Destroy infrastructure
destroy:
	@echo "Destroying infrastructure for ENV=$(ENV)..."
	terraform destroy $(TF_VARS)

# Show outputs
output:
	@echo "Terraform outputs for ENV=$(ENV):"
	terraform output

# Refresh state
refresh:
	@echo "Refreshing Terraform state for ENV=$(ENV)..."
	terraform refresh $(TF_VARS)

# Clean terraform cache
clean:
	@echo "Cleaning Terraform cache..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*

logs-fe:
	@echo "Showing frontend logs..."
	aws logs tail /ecs/$(ENV)-fe --follow --profile $(AWS_PROFILE)

logs-be:
	@echo "Showing backend logs..."
	aws logs tail /ecs/$(ENV)-be --follow --profile $(AWS_PROFILE)

# Full deploy (init + plan + apply)
deploy: init plan apply
	@echo "Deployment complete!"

# Quick dev setup
dev-setup: init
	@echo "Setting up dev environment..."
	make apply ENV=dev

# Maintenance mode commands
maintenance-on:
	@echo "Enabling maintenance mode..."
	aws events put-events --entries '[{"Source":"custom.maintenance","DetailType":"Maintenance Toggle","Detail":"{\"action\":\"ON\"}"}]' --profile $(AWS_PROFILE)
	@echo "Event sent! Check logs with: make maintenance-logs"

maintenance-off:
	@echo "Disabling maintenance mode..."
	aws events put-events --entries '[{"Source":"custom.maintenance","DetailType":"Maintenance Toggle","Detail":"{\"action\":\"OFF\"}"}]' --profile $(AWS_PROFILE)
	@echo "Event sent! Check logs with: make maintenance-logs"

maintenance-status:
	@echo "Current maintenance mode status:"
	@aws ssm get-parameter --name "/req-analysis-1/$(ENV)/maintenance-mode" --query 'Parameter.Value' --output text --profile $(AWS_PROFILE) 2>/dev/null || echo "Parameter not found. Run 'make package-lambda && make apply ENV=$(ENV)' first"

package-lambda:
	@echo "Packaging Lambda function..."
	@cd scripts && ./package-lambda.bat
