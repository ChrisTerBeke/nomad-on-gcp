init:
	terraform init

plan:
	terraform plan -var-file=env.tfvars

tunnel:
	gcloud compute start-iap-tunnel nomad-server-4m71 4646 --zone=europe-west4-b --project=summer-sun-394510 --local-host-port=localhost:4646
