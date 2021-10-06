# Standalone Redis Deployment on AWS Trial 1

Put AWS keys in `.env` file in the below format

```
export AWS_ACCOUNT_ID="aws-account-id"
export AWS_ACCESS_KEY_ID="aws-access-key"
export AWS_SECRET_ACCESS_KEY="secret-access-key"
```

```bash
$ source .env
$ packer init .
$ packer fmt .
$ packer build redis-server.pkr.hcl
```

Get the AMI ID and put it in the AMI field in the `main.tf` Terraform file

```bash
$ source .env
$ terraform init
$ terraform plan -out tfplan
$ terraform apply tfplan
```

The above should finish successfully and give out a public IP to connect to. If SSH feature is enabled then you can use the SSH

```bash
$ ssh -i dummy-key ec2-user@${IP}
```

For cleaning up images

```bash
$ source .env

$ envsubst < aws-nuke-config-template.yaml > aws-nuke-config.yaml

$ aws-nuke -c aws-nuke-config.yaml --access-key-id "$AWS_ACCESS_KEY_ID" --secret-access-key "$AWS_SECRET_ACCESS_KEY" --force --no-dry-run
```
