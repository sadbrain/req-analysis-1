ENV ?= dev

init:
	terraform init -backend-config=env/$(ENV)/backend.hcl

plan:
	terraform plan \
		-var-file=env/$(ENV)/commons.tfvars \
		-var-file=env/$(ENV)/vpcs.tfvars 

apply:
	terraform apply \
		-var-file=env/$(ENV)/commons.tfvars \
		-var-file=env/$(ENV)/vpcs.tfvars 

