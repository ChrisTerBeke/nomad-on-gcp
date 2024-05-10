init:
	terraform init

plan:
	terraform plan -var-file=env.tfvars
