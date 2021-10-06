# Standalone Redis Deployment on AWS Trial 1

Put AWS keys in `.env` file in the below format

```
export AWS_ACCESS_KEY_ID="aws-access-key"
export AWS_SECRET_ACCESS_KEY="secret-access-key"
```

```bash
$ source .env
$ terraform init
$ terraform plan -out tfplan
$ terraform apply tfplan
```

The above should finish successfully and give out a public IP to connect to

```bash
$ ssh -i dummy-key ec2-user@${IP}
```
