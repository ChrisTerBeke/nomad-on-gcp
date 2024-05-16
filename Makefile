init:
	terraform init

plan:
	terraform plan -var-file=env.tfvars

apply:
	terraform apply -var-file=env.tfvars
