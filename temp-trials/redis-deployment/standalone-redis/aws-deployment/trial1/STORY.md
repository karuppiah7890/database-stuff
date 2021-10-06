I'm working on https://github.com/karuppiah7890/simple-dbaas/issues/2

TODOs

- Documentation
- Code
- Tests? Using terratest ?

Low Level TODOs

- Understand the different AWS resources required to deploy the Standalone Redis DB
- Expose only one port from the VM to the outside world / public Internet - this port will be used by Redis clients to connect to the Redis
- Password authentication for the Redis server
- Output the redis-cli command to use to connect to the server
- Output the file containing the generated SSH keys required to SSH into the machine running the Redis. Since SSH port won't be exposed to the public Internet, a bastion host has to be used. We can think about this later - how to automatically deploy a bastion and kill it off once we are done using it, all using Terraform

---

Port number - it's best to choose a number other than 6379 as it's a popular port and the default Redis port and it's crazy to expose that. Maybe a random number between 1024 and 65536 or a number of 50379 is good. Even then, there are port scanners on the Internet trying to find accessible public IP and the accessible ports in them and trying to find out the service running in that port and trying to hack them. So, even if exposed in a different port, we need to add strong authentication for the Redis server

---

AWS resources required to run Standalone Redis DB on a standalone VM with no platform like Kubernetes or Nomad etc -

I think we might need these -

Key Pair
VPC
Subnet
Network interface
EC2 instance
Security Group
Route Table
Internet Gateway

But I gotta check more on them - what they do, why exactly they are needed and how we can reduce the number of AWS resources required to deploy the Standalone Redis DB. We can also look at making the deployment easier - surely using Terraform is one way - a cloud agnostic way. But if someone wants an AWS specific way, maybe I could checkout CloudFormation, but that's another extra thing to checkout and look at and build for etc. Too much work, hmm. But some developers might choose it in case they don't know Terraform for example!

---

Documentation TODOs

- Document what access the access key ID and secret access key pair should have to deploy the Standalone Redis DB. This is important as users may not want to provide an automation script a token which has too much access. It's best to validate the required permissions - by creating credentials with those permissions and trying out the automation with those credentials, and only then document it!

---

Terratest testing -

It would be nice to test the automation script using some automation testing with some tool like terratest

---

To be able to deploy multiple Standalone Redis DBs using the same automation script and same AWS credentials, the script should not use hardcoded values for any of the fields, also no constant names like `redis-db` then we may not be able to create another resource named `redis-db` when we run the script again if the resource name has to be unique.

We can use random numbers for the names and tags etc. We can modularize the whole terraform code and create something like a terraform module. Users can reuse existing AWS resources like VPC or create a new VPC for every Redis DB. Not sure what the users prefer and what's the norm, but both should be possible and there should be nice defaults! :D

---

AWS VPC

https://aws.amazon.com/vpc/

https://aws.amazon.com/vpc/details

https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html

VPC Pricing

https://aws.amazon.com/vpc/pricing/

---

Network Interface

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/requester-managed-eni.html

---

Internet Gateway

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html

---

Gateway Route Tables

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html#gateway-route-table

---

Security Groups

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html

---

Network Access Control List comparison with Security Groups -

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html#VPC_Security_Comparison

---

```terraform
resource "aws_security_group" "redis_sg" {

}
```

---

Low level TODOs

- AWS resources to create using Terraform - [DONE]
  - VPC
  - Subnet
  - Key Pair
  - Network interface
  - Security Group
  - Internet Gateway
  - VPC Route Table
  - EC2 instance
- Create Amazon Machine Images (AMIs) for Redis and use it
- Check about the max number of open files in the VM using `ulimit -n` and increase the value

---

Redis AMI

We gotta create different AMIs for each Redis version that's required, the AMI is gonna be heavy, unlike container images

Also, does the AMI have to be created per AWS region?

Also, can the AMIs be public instead of private? So that anyone can use it? How does one host public AMIs? What's the cost of hosting and using AMIs (both public and private AMIs)? Are there ways to host AMIs outside of AWS infrastructure but be used to create the AWS instances? 🤔 For example Vagrant has a list of boxes / VM images that they host, many OS websites and other websites host VM images

Installing Redis? Use pre-built executables or use package managers to install Redis in an EC2 instance and then create an AMI out of the instance. Maybe use tools like packer to create the AMI

---

Redis server process basic monitoring and running -

It's best to run the Redis server as a systemd unit and let systemd run it whenever the machine starts instead of someone having to run the Redis server manually

Monitoring - we gotta take care of this later

---

```bash
trial1 $ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.27"...
- Installing hashicorp/aws v3.60.0...
- Installed hashicorp/aws v3.60.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
trial1 $ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/24"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions
if you run "terraform apply" now.
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/24"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $ gst
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .gitignore
	new file:   STORY.md
	new file:   main.tf

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   .gitignore

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	../../../../../cmu-database-systems-course/placeholder/
	.terraform.lock.hcl

trial1 $ ga .
trial1 $ terraform apply tfplan
aws_vpc.redis_vpc: Creating...
aws_vpc.redis_vpc: Still creating... [10s elapsed]
aws_vpc.redis_vpc: Creation complete after 13s [id=vpc-09998eb8f41666b86]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
trial1 $ terraform destroy
aws_vpc.redis_vpc: Refreshing state... [id=vpc-09998eb8f41666b86]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_vpc.redis_vpc will be destroyed
  - resource "aws_vpc" "redis_vpc" {
      - arn                              = "arn:aws:ec2:us-east-1:469318448823:vpc/vpc-09998eb8f41666b86" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.0.0.0/24" -> null
      - default_network_acl_id           = "acl-0a04df490d034ecc4" -> null
      - default_route_table_id           = "rtb-09682102da3eee3d0" -> null
      - default_security_group_id        = "sg-0dba45ac184f9cd8a" -> null
      - dhcp_options_id                  = "dopt-6fb3e10a" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = false -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-09998eb8f41666b86" -> null
      - instance_tenancy                 = "default" -> null
      - main_route_table_id              = "rtb-09682102da3eee3d0" -> null
      - owner_id                         = "469318448823" -> null
      - tags                             = {
          - "Name" = "redis-vpc"
        } -> null
      - tags_all                         = {
          - "Name" = "redis-vpc"
        } -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_vpc.redis_vpc: Destroying... [id=vpc-09998eb8f41666b86]
aws_vpc.redis_vpc: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
trial1 $ terraform version
Terraform v1.0.7
on darwin_amd64
+ provider registry.terraform.io/hashicorp/aws v3.60.0
trial1 $ terraform plan -out tfplan
╷
│ Error: Unsupported Terraform Core version
│
│   on main.tf line 9, in terraform:
│    9:   required_version = "1.0.8"
│
│ This configuration does not support Terraform version 1.0.7. To proceed, either choose another supported Terraform
│ version or update this version constraint. Version constraints are normally set for good reason, so updating the
│ constraint may lead to other errors or unexpected behavior.
╵
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/24"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $
```

---

VPC and DNS

https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html

---

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

---

```bash
trial1 $ ssh-keygen -t ed25519 -b 4096 -f dummy-key -C dummy@gmail.com
Generating public/private ed25519 key pair.
dummy-key already exists.
Overwrite (y/n)? y
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in dummy-key.
Your public key has been saved in dummy-key.pub.
The key fingerprint is:
SHA256:e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw dummy@gmail.com
The key's randomart image is:
+--[ED25519 256]--+
|  ..o..o+oo      |
|   . .. oo .     |
|      .. o.      |
|     o  ..    .  |
|    *   S .. = . |
|   = .   o  O O  |
|  o o . . .o X = |
| . . . . .= E =+=|
|        .o o oo=*|
+----[SHA256]-----+
trial1 $ cat dummy-key.pub  | pbcopy
trial1 $
```

---

```bash
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.redis_ssh_key will be created
  + resource "aws_key_pair" "redis_ssh_key" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = (known after apply)
      + key_name_prefix = "redis-ssh-key"
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
      + tags_all        = (known after apply)
    }

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/24"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $ terraform apply tfplan
aws_key_pair.redis_ssh_key: Creating...
aws_vpc.redis_vpc: Creating...
aws_key_pair.redis_ssh_key: Creation complete after 2s [id=redis-ssh-key20210925144806031400000001]
aws_vpc.redis_vpc: Still creating... [10s elapsed]
aws_vpc.redis_vpc: Creation complete after 11s [id=vpc-08ae3fdf9ceb2e57c]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925144806031400000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-08ae3fdf9ceb2e57c]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_key_pair.redis_ssh_key has been changed
  ~ resource "aws_key_pair" "redis_ssh_key" {
        id              = "redis-ssh-key20210925144806031400000001"
      + tags            = {}
        # (7 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_key_pair.redis_ssh_key will be destroyed
  - resource "aws_key_pair" "redis_ssh_key" {
      - arn             = "arn:aws:ec2:us-east-1:469318448823:key-pair/redis-ssh-key20210925144806031400000001" -> null
      - fingerprint     = "e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw=" -> null
      - id              = "redis-ssh-key20210925144806031400000001" -> null
      - key_name        = "redis-ssh-key20210925144806031400000001" -> null
      - key_name_prefix = "redis-ssh-key" -> null
      - key_pair_id     = "key-06fecbe33bb3ce443" -> null
      - public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com" -> null
      - tags            = {} -> null
      - tags_all        = {} -> null
    }

  # aws_vpc.redis_vpc will be destroyed
  - resource "aws_vpc" "redis_vpc" {
      - arn                              = "arn:aws:ec2:us-east-1:469318448823:vpc/vpc-08ae3fdf9ceb2e57c" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.0.0.0/24" -> null
      - default_network_acl_id           = "acl-0cc01558f2cdd320f" -> null
      - default_route_table_id           = "rtb-0a8284bd8e2daf2dc" -> null
      - default_security_group_id        = "sg-04c75231bbfbaa020" -> null
      - dhcp_options_id                  = "dopt-6fb3e10a" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = false -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-08ae3fdf9ceb2e57c" -> null
      - instance_tenancy                 = "default" -> null
      - main_route_table_id              = "rtb-0a8284bd8e2daf2dc" -> null
      - owner_id                         = "469318448823" -> null
      - tags                             = {
          - "Name" = "redis-vpc"
        } -> null
      - tags_all                         = {
          - "Name" = "redis-vpc"
        } -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_key_pair.redis_ssh_key: Destroying... [id=redis-ssh-key20210925144806031400000001]
aws_vpc.redis_vpc: Destroying... [id=vpc-08ae3fdf9ceb2e57c]
aws_key_pair.redis_ssh_key: Destruction complete after 1s
aws_vpc.redis_vpc: Destruction complete after 1s

Destroy complete! Resources: 2 destroyed.
trial1 $
```

---

```bash
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.redis_ssh_key will be created
  + resource "aws_key_pair" "redis_ssh_key" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = (known after apply)
      + key_name_prefix = "redis-ssh-key"
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
      + tags_all        = (known after apply)
    }

  # aws_subnet.redis_subnet will be created
  + resource "aws_subnet" "redis_subnet" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = (known after apply)
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.0.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "redis-subnet"
        }
      + tags_all                        = {
          + "Name" = "redis-subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $ terraform apply tfplan
aws_key_pair.redis_ssh_key: Creating...
aws_vpc.redis_vpc: Creating...
aws_key_pair.redis_ssh_key: Creation complete after 2s [id=redis-ssh-key20210925145653893800000001]
aws_vpc.redis_vpc: Still creating... [10s elapsed]
aws_vpc.redis_vpc: Creation complete after 11s [id=vpc-04e12ac450c884deb]
aws_subnet.redis_subnet: Creating...
aws_subnet.redis_subnet: Creation complete after 3s [id=subnet-0e86df5f7278f53a3]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
trial1 $
trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925145653893800000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-04e12ac450c884deb]
aws_subnet.redis_subnet: Refreshing state... [id=subnet-0e86df5f7278f53a3]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_key_pair.redis_ssh_key has been changed
  ~ resource "aws_key_pair" "redis_ssh_key" {
        id              = "redis-ssh-key20210925145653893800000001"
      + tags            = {}
        # (7 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_key_pair.redis_ssh_key will be destroyed
  - resource "aws_key_pair" "redis_ssh_key" {
      - arn             = "arn:aws:ec2:us-east-1:469318448823:key-pair/redis-ssh-key20210925145653893800000001" -> null
      - fingerprint     = "e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw=" -> null
      - id              = "redis-ssh-key20210925145653893800000001" -> null
      - key_name        = "redis-ssh-key20210925145653893800000001" -> null
      - key_name_prefix = "redis-ssh-key" -> null
      - key_pair_id     = "key-04e334d94b49686d9" -> null
      - public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com" -> null
      - tags            = {} -> null
      - tags_all        = {} -> null
    }

  # aws_subnet.redis_subnet will be destroyed
  - resource "aws_subnet" "redis_subnet" {
      - arn                             = "arn:aws:ec2:us-east-1:469318448823:subnet/subnet-0e86df5f7278f53a3" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-east-1c" -> null
      - availability_zone_id            = "use1-az6" -> null
      - cidr_block                      = "10.0.0.0/24" -> null
      - id                              = "subnet-0e86df5f7278f53a3" -> null
      - map_customer_owned_ip_on_launch = false -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "469318448823" -> null
      - tags                            = {
          - "Name" = "redis-subnet"
        } -> null
      - tags_all                        = {
          - "Name" = "redis-subnet"
        } -> null
      - vpc_id                          = "vpc-04e12ac450c884deb" -> null
    }

  # aws_vpc.redis_vpc will be destroyed
  - resource "aws_vpc" "redis_vpc" {
      - arn                              = "arn:aws:ec2:us-east-1:469318448823:vpc/vpc-04e12ac450c884deb" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.0.0.0/16" -> null
      - default_network_acl_id           = "acl-0f79dcaeef41d11fa" -> null
      - default_route_table_id           = "rtb-0edde735296f94dc0" -> null
      - default_security_group_id        = "sg-0123d8285e3c42c26" -> null
      - dhcp_options_id                  = "dopt-6fb3e10a" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = false -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-04e12ac450c884deb" -> null
      - instance_tenancy                 = "default" -> null
      - main_route_table_id              = "rtb-0edde735296f94dc0" -> null
      - owner_id                         = "469318448823" -> null
      - tags                             = {
          - "Name" = "redis-vpc"
        } -> null
      - tags_all                         = {
          - "Name" = "redis-vpc"
        } -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_key_pair.redis_ssh_key: Destroying... [id=redis-ssh-key20210925145653893800000001]
aws_subnet.redis_subnet: Destroying... [id=subnet-0e86df5f7278f53a3]
aws_key_pair.redis_ssh_key: Destruction complete after 1s
aws_subnet.redis_subnet: Destruction complete after 3s
aws_vpc.redis_vpc: Destroying... [id=vpc-04e12ac450c884deb]
aws_vpc.redis_vpc: Destruction complete after 1s

Destroy complete! Resources: 3 destroyed.
trial1 $

```

---

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_sg_attachment - should not use !!!

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule

https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_IpPermission.html

http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_IpRange.html

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association - should not use !!!

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table - should not use !!!

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

---

No tag called `Name` for key pair as it has prefix for the name and adding a tag called `Name` with a constant value and something different from the actual name can be confusing, also I have seen AWS use the `Name` tag to show the name, apart from the unique ID for each resource

---

```bash
trial1 $ terraform plan -out tfplan
╷
│ Error: Incorrect attribute value type
│
│   on main.tf line 54, in resource "aws_security_group" "redis_security_group":
│   54:   ingress = [
│   55:     {
│   56:       description      = "Redis Traffic from the Internet"
│   57:       from_port        = 22
│   58:       to_port          = 22
│   59:       protocol         = "tcp"
│   60:       cidr_blocks      = ["0.0.0.0/0"]
│   61:       ipv6_cidr_blocks = ["::/0"]
│   62:     }
│   63:   ]
│
│ Inappropriate value for attribute "ingress": element 0: attributes "prefix_list_ids", "security_groups", and
│ "self" are required.
╵
╷
│ Error: Incorrect attribute value type
│
│   on main.tf line 65, in resource "aws_security_group" "redis_security_group":
│   65:   egress = [
│   66:     {
│   67:       from_port        = 0
│   68:       to_port          = 0
│   69:       protocol         = "-1"
│   70:       cidr_blocks      = ["0.0.0.0/0"]
│   71:       ipv6_cidr_blocks = ["::/0"]
│   72:     }
│   73:   ]
│
│ Inappropriate value for attribute "egress": element 0: attributes "description", "prefix_list_ids",
│ "security_groups", and "self" are required.
╵
╷
│ Error: Reference to undeclared resource
│
│   on main.tf line 89, in resource "aws_route_table" "redis_route_table":
│   89:   vpc_id = aws_vpc.example.id
│
│ A managed resource "aws_vpc" "example" has not been declared in the root module.
╵
trial1 $ terraform plan -out tfplan
╷
│ Error: Incorrect attribute value type
│
│   on main.tf line 54, in resource "aws_security_group" "redis_security_group":
│   54:   ingress = [
│   55:     {
│   56:       description      = "Redis Traffic from the Internet"
│   57:       from_port        = 22
│   58:       to_port          = 22
│   59:       protocol         = "tcp"
│   60:       cidr_blocks      = ["0.0.0.0/0"]
│   61:       ipv6_cidr_blocks = ["::/0"]
│   62:     }
│   63:   ]
│
│ Inappropriate value for attribute "ingress": element 0: attributes "prefix_list_ids", "security_groups", and
│ "self" are required.
╵
╷
│ Error: Incorrect attribute value type
│
│   on main.tf line 65, in resource "aws_security_group" "redis_security_group":
│   65:   egress = [
│   66:     {
│   67:       from_port        = 0
│   68:       to_port          = 0
│   69:       protocol         = "-1"
│   70:       cidr_blocks      = ["0.0.0.0/0"]
│   71:       ipv6_cidr_blocks = ["::/0"]
│   72:     }
│   73:   ]
│
│ Inappropriate value for attribute "egress": element 0: attributes "description", "prefix_list_ids",
│ "security_groups", and "self" are required.
╵
╷
│ Error: Incorrect attribute value type
│
│   on main.tf line 91, in resource "aws_route_table" "redis_route_table":
│   91:   route = [
│   92:     {
│   93:       cidr_block = aws_subnet.redis_subnet.id
│   94:       gateway_id = aws_internet_gateway.redis_internet_gateway.id
│   95:     }
│   96:   ]
│     ├────────────────
│     │ aws_internet_gateway.redis_internet_gateway.id will be known only after apply
│     │ aws_subnet.redis_subnet.id will be known only after apply
│
│ Inappropriate value for attribute "route": element 0: attributes "carrier_gateway_id",
│ "destination_prefix_list_id", "egress_only_gateway_id", "instance_id", "ipv6_cidr_block", "local_gateway_id",
│ "nat_gateway_id", "network_interface_id", "transit_gateway_id", "vpc_endpoint_id", and "vpc_peering_connection_id"
│ are required.
╵
trial1 $
```

---

```bash
trial1 $ terraform plan -out tfplan
╷
│ Error: Missing required argument
│
│   on main.tf line 58, in resource "aws_security_group_rule" "redis_security_group_ingress":
│   58: resource "aws_security_group_rule" "redis_security_group_ingress" {
│
│ The argument "type" is required, but no definition was found.
╵
╷
│ Error: Missing required argument
│
│   on main.tf line 68, in resource "aws_security_group_rule" "redis_security_group_egress":
│   68: resource "aws_security_group_rule" "redis_security_group_egress" {
│
│ The argument "security_group_id" is required, but no definition was found.
╵
╷
│ Error: Missing required argument
│
│   on main.tf line 68, in resource "aws_security_group_rule" "redis_security_group_egress":
│   68: resource "aws_security_group_rule" "redis_security_group_egress" {
│
│ The argument "type" is required, but no definition was found.
╵
trial1 $

trial1 $ terraform plan -out tfplan
╷
│ Error: expected type to be one of [ingress egress], got egess
│
│   with aws_security_group_rule.redis_security_group_egress,
│   on main.tf line 70, in resource "aws_security_group_rule" "redis_security_group_egress":
│   70:   type              = "egess"
│
╵
trial1 $
```

---

```bash
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.redis_server will be created
  + resource "aws_instance" "redis_server" {
      + ami                                  = "ami-029c64b3c205e6cce"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t4g.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aws"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "redis-server"
        }
      + tags_all                             = {
          + "Name" = "redis-server"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 8
          + volume_type           = (known after apply)
        }
    }

  # aws_internet_gateway.redis_internet_gateway will be created
  + resource "aws_internet_gateway" "redis_internet_gateway" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "redis-internet-gateway"
        }
      + tags_all = {
          + "Name" = "redis-internet-gateway"
        }
      + vpc_id   = (known after apply)
    }

  # aws_key_pair.redis_ssh_key will be created
  + resource "aws_key_pair" "redis_ssh_key" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = (known after apply)
      + key_name_prefix = "redis-ssh-key"
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
      + tags_all        = (known after apply)
    }

  # aws_network_interface.redis_network_interface will be created
  + resource "aws_network_interface" "redis_network_interface" {
      + id                 = (known after apply)
      + interface_type     = (known after apply)
      + ipv6_address_count = (known after apply)
      + ipv6_addresses     = (known after apply)
      + mac_address        = (known after apply)
      + outpost_arn        = (known after apply)
      + private_dns_name   = (known after apply)
      + private_ip         = (known after apply)
      + private_ips        = (known after apply)
      + private_ips_count  = (known after apply)
      + security_groups    = (known after apply)
      + source_dest_check  = true
      + subnet_id          = (known after apply)
      + tags               = {
          + "Name" = "redis-network-interface"
        }
      + tags_all           = {
          + "Name" = "redis-network-interface"
        }

      + attachment {
          + attachment_id = (known after apply)
          + device_index  = (known after apply)
          + instance      = (known after apply)
        }
    }

  # aws_route.redis_route will be created
  + resource "aws_route" "redis_route" {
      + destination_cidr_block = "10.0.0.0/24"
      + gateway_id             = (known after apply)
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)
    }

  # aws_route_table.redis_route_table will be created
  + resource "aws_route_table" "redis_route_table" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Name" = "redis-route-table"
        }
      + tags_all         = {
          + "Name" = "redis-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # aws_security_group.redis_security_group will be created
  + resource "aws_security_group" "redis_security_group" {
      + arn                    = (known after apply)
      + description            = "Allow Redis traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "allow_redis_traffic"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "allow-redis-traffic"
        }
      + tags_all               = {
          + "Name" = "allow-redis-traffic"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group_rule.redis_security_group_egress will be created
  + resource "aws_security_group_rule" "redis_security_group_egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # aws_security_group_rule.redis_security_group_ingress will be created
  + resource "aws_security_group_rule" "redis_security_group_ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Redis Traffic from the Internet"
      + from_port                = 22
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # aws_subnet.redis_subnet will be created
  + resource "aws_subnet" "redis_subnet" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = (known after apply)
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.0.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "redis-subnet"
        }
      + tags_all                        = {
          + "Name" = "redis-subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 11 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $ terraform apply tfplan
aws_key_pair.redis_ssh_key: Creating...
aws_vpc.redis_vpc: Creating...
aws_key_pair.redis_ssh_key: Creation complete after 2s [id=redis-ssh-key20210925154911290700000001]
aws_vpc.redis_vpc: Still creating... [10s elapsed]
aws_vpc.redis_vpc: Creation complete after 12s [id=vpc-00228dd0c114f8550]
aws_internet_gateway.redis_internet_gateway: Creating...
aws_route_table.redis_route_table: Creating...
aws_subnet.redis_subnet: Creating...
aws_security_group.redis_security_group: Creating...
aws_route_table.redis_route_table: Creation complete after 3s [id=rtb-0c7905f6350207b2b]
aws_subnet.redis_subnet: Creation complete after 3s [id=subnet-0fbcdc630c7caba7a]
aws_network_interface.redis_network_interface: Creating...
aws_internet_gateway.redis_internet_gateway: Creation complete after 5s [id=igw-059a46a1baab6bd01]
aws_route.redis_route: Creating...
aws_security_group.redis_security_group: Creation complete after 6s [id=sg-0080f02036d1153f2]
aws_security_group_rule.redis_security_group_egress: Creating...
aws_security_group_rule.redis_security_group_ingress: Creating...
aws_instance.redis_server: Creating...
aws_security_group_rule.redis_security_group_ingress: Creation complete after 3s [id=sgrule-868963820]
aws_security_group_rule.redis_security_group_egress: Creation complete after 7s [id=sgrule-1662463673]
aws_network_interface.redis_network_interface: Still creating... [10s elapsed]
aws_network_interface.redis_network_interface: Still creating... [20s elapsed]
aws_network_interface.redis_network_interface: Still creating... [30s elapsed]
aws_network_interface.redis_network_interface: Creation complete after 34s [id=eni-0dc814d94374f3b44]
╷
│ Error: error creating Route in Route Table (rtb-0c7905f6350207b2b) with destination (10.0.0.0/24): InvalidParameterValue: The destination CIDR block 10.0.0.0/24 is equal to or more specific than one of this VPC's CIDR blocks. This route can target only an interface or an instance.
│ 	status code: 400, request id: 8524f26c-35cb-45f6-b0e4-fb16d295da55
│
│   with aws_route.redis_route,
│   on main.tf line 94, in resource "aws_route" "redis_route":
│   94: resource "aws_route" "redis_route" {
│
╵
╷
│ Error: Error launching source instance: InvalidParameter: Security group sg-0080f02036d1153f2 and subnet subnet-ceb020ab belong to different networks.
│ 	status code: 400, request id: b65b31bc-8e24-4b1d-beec-28af659b127b
│
│   with aws_instance.redis_server,
│   on main.tf line 100, in resource "aws_instance" "redis_server":
│  100: resource "aws_instance" "redis_server" {
│
╵
trial1 $
```

```bash
trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925154911290700000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-00228dd0c114f8550]
aws_internet_gateway.redis_internet_gateway: Refreshing state... [id=igw-059a46a1baab6bd01]
aws_subnet.redis_subnet: Refreshing state... [id=subnet-0fbcdc630c7caba7a]
aws_route_table.redis_route_table: Refreshing state... [id=rtb-0c7905f6350207b2b]
aws_security_group.redis_security_group: Refreshing state... [id=sg-0080f02036d1153f2]
aws_security_group_rule.redis_security_group_egress: Refreshing state... [id=sgrule-1662463673]
aws_security_group_rule.redis_security_group_ingress: Refreshing state... [id=sgrule-868963820]
aws_network_interface.redis_network_interface: Refreshing state... [id=eni-0dc814d94374f3b44]
╷
│ Error: Conflicting configuration arguments
│
│   with aws_instance.redis_server,
│   on main.tf line 101, in resource "aws_instance" "redis_server":
│  101: resource "aws_instance" "redis_server" {
│
│ "network_interface": conflicts with associate_public_ip_address
╵
trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925154911290700000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-00228dd0c114f8550]
aws_security_group.redis_security_group: Refreshing state... [id=sg-0080f02036d1153f2]
aws_internet_gateway.redis_internet_gateway: Refreshing state... [id=igw-059a46a1baab6bd01]
aws_route_table.redis_route_table: Refreshing state... [id=rtb-0c7905f6350207b2b]
aws_subnet.redis_subnet: Refreshing state... [id=subnet-0fbcdc630c7caba7a]
aws_network_interface.redis_network_interface: Refreshing state... [id=eni-0dc814d94374f3b44]
aws_security_group_rule.redis_security_group_ingress: Refreshing state... [id=sgrule-868963820]
aws_security_group_rule.redis_security_group_egress: Refreshing state... [id=sgrule-1662463673]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_security_group_rule.redis_security_group_ingress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_ingress" {
        id                = "sgrule-868963820"
      + prefix_list_ids   = []
        # (9 unchanged attributes hidden)
    }
  # aws_key_pair.redis_ssh_key has been changed
  ~ resource "aws_key_pair" "redis_ssh_key" {
        id              = "redis-ssh-key20210925154911290700000001"
      + tags            = {}
        # (7 unchanged attributes hidden)
    }
  # aws_security_group_rule.redis_security_group_egress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_egress" {
        id                = "sgrule-1662463673"
      + prefix_list_ids   = []
        # (8 unchanged attributes hidden)
    }
  # aws_security_group.redis_security_group has been changed
  ~ resource "aws_security_group" "redis_security_group" {
      ~ egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
        id                     = "sg-0080f02036d1153f2"
      ~ ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Redis Traffic from the Internet"
              + from_port        = 22
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
        name                   = "allow_redis_traffic"
        tags                   = {
            "Name" = "allow-redis-traffic"
        }
        # (6 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_internet_gateway.redis_internet_gateway will be destroyed
  - resource "aws_internet_gateway" "redis_internet_gateway" {
      - arn      = "arn:aws:ec2:us-east-1:469318448823:internet-gateway/igw-059a46a1baab6bd01" -> null
      - id       = "igw-059a46a1baab6bd01" -> null
      - owner_id = "469318448823" -> null
      - tags     = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - tags_all = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - vpc_id   = "vpc-00228dd0c114f8550" -> null
    }

  # aws_key_pair.redis_ssh_key will be destroyed
  - resource "aws_key_pair" "redis_ssh_key" {
      - arn             = "arn:aws:ec2:us-east-1:469318448823:key-pair/redis-ssh-key20210925154911290700000001" -> null
      - fingerprint     = "e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw=" -> null
      - id              = "redis-ssh-key20210925154911290700000001" -> null
      - key_name        = "redis-ssh-key20210925154911290700000001" -> null
      - key_name_prefix = "redis-ssh-key" -> null
      - key_pair_id     = "key-03db80396e07e570c" -> null
      - public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com" -> null
      - tags            = {} -> null
      - tags_all        = {} -> null
    }

  # aws_network_interface.redis_network_interface will be destroyed
  - resource "aws_network_interface" "redis_network_interface" {
      - id                 = "eni-0dc814d94374f3b44" -> null
      - interface_type     = "interface" -> null
      - ipv6_address_count = 0 -> null
      - ipv6_addresses     = [] -> null
      - mac_address        = "0e:c1:ab:65:b2:85" -> null
      - private_ip         = "10.0.0.138" -> null
      - private_ips        = [
          - "10.0.0.138",
        ] -> null
      - private_ips_count  = 0 -> null
      - security_groups    = [
          - "sg-0c2b1fcdb03b7b73d",
        ] -> null
      - source_dest_check  = true -> null
      - subnet_id          = "subnet-0fbcdc630c7caba7a" -> null
      - tags               = {
          - "Name" = "redis-network-interface"
        } -> null
      - tags_all           = {
          - "Name" = "redis-network-interface"
        } -> null
    }

  # aws_route_table.redis_route_table will be destroyed
  - resource "aws_route_table" "redis_route_table" {
      - arn              = "arn:aws:ec2:us-east-1:469318448823:route-table/rtb-0c7905f6350207b2b" -> null
      - id               = "rtb-0c7905f6350207b2b" -> null
      - owner_id         = "469318448823" -> null
      - propagating_vgws = [] -> null
      - route            = [] -> null
      - tags             = {
          - "Name" = "redis-route-table"
        } -> null
      - tags_all         = {
          - "Name" = "redis-route-table"
        } -> null
      - vpc_id           = "vpc-00228dd0c114f8550" -> null
    }

  # aws_security_group.redis_security_group will be destroyed
  - resource "aws_security_group" "redis_security_group" {
      - arn                    = "arn:aws:ec2:us-east-1:469318448823:security-group/sg-0080f02036d1153f2" -> null
      - description            = "Allow Redis traffic" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0080f02036d1153f2" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Redis Traffic from the Internet"
              - from_port        = 22
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "allow_redis_traffic" -> null
      - owner_id               = "469318448823" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - tags_all               = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - vpc_id                 = "vpc-00228dd0c114f8550" -> null
    }

  # aws_security_group_rule.redis_security_group_egress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_egress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 0 -> null
      - id                = "sgrule-1662463673" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "-1" -> null
      - security_group_id = "sg-0080f02036d1153f2" -> null
      - self              = false -> null
      - to_port           = 0 -> null
      - type              = "egress" -> null
    }

  # aws_security_group_rule.redis_security_group_ingress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - description       = "Redis Traffic from the Internet" -> null
      - from_port         = 22 -> null
      - id                = "sgrule-868963820" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0080f02036d1153f2" -> null
      - self              = false -> null
      - to_port           = 22 -> null
      - type              = "ingress" -> null
    }

  # aws_subnet.redis_subnet will be destroyed
  - resource "aws_subnet" "redis_subnet" {
      - arn                             = "arn:aws:ec2:us-east-1:469318448823:subnet/subnet-0fbcdc630c7caba7a" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-east-1c" -> null
      - availability_zone_id            = "use1-az6" -> null
      - cidr_block                      = "10.0.0.0/24" -> null
      - id                              = "subnet-0fbcdc630c7caba7a" -> null
      - map_customer_owned_ip_on_launch = false -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "469318448823" -> null
      - tags                            = {
          - "Name" = "redis-subnet"
        } -> null
      - tags_all                        = {
          - "Name" = "redis-subnet"
        } -> null
      - vpc_id                          = "vpc-00228dd0c114f8550" -> null
    }

  # aws_vpc.redis_vpc will be destroyed
  - resource "aws_vpc" "redis_vpc" {
      - arn                              = "arn:aws:ec2:us-east-1:469318448823:vpc/vpc-00228dd0c114f8550" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.0.0.0/16" -> null
      - default_network_acl_id           = "acl-0ead402f8c5296f2d" -> null
      - default_route_table_id           = "rtb-06ea3177ae189274a" -> null
      - default_security_group_id        = "sg-0c2b1fcdb03b7b73d" -> null
      - dhcp_options_id                  = "dopt-6fb3e10a" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = false -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-00228dd0c114f8550" -> null
      - instance_tenancy                 = "default" -> null
      - main_route_table_id              = "rtb-06ea3177ae189274a" -> null
      - owner_id                         = "469318448823" -> null
      - tags                             = {
          - "Name" = "redis-vpc"
        } -> null
      - tags_all                         = {
          - "Name" = "redis-vpc"
        } -> null
    }

Plan: 0 to add, 0 to change, 9 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_internet_gateway.redis_internet_gateway: Destroying... [id=igw-059a46a1baab6bd01]
aws_route_table.redis_route_table: Destroying... [id=rtb-0c7905f6350207b2b]
aws_key_pair.redis_ssh_key: Destroying... [id=redis-ssh-key20210925154911290700000001]
aws_security_group_rule.redis_security_group_ingress: Destroying... [id=sgrule-868963820]
aws_security_group_rule.redis_security_group_egress: Destroying... [id=sgrule-1662463673]
aws_network_interface.redis_network_interface: Destroying... [id=eni-0dc814d94374f3b44]
aws_key_pair.redis_ssh_key: Destruction complete after 1s
aws_network_interface.redis_network_interface: Destruction complete after 2s
aws_subnet.redis_subnet: Destroying... [id=subnet-0fbcdc630c7caba7a]
aws_security_group_rule.redis_security_group_egress: Destruction complete after 2s
aws_route_table.redis_route_table: Destruction complete after 3s
aws_subnet.redis_subnet: Destruction complete after 2s
aws_security_group_rule.redis_security_group_ingress: Destruction complete after 5s
aws_security_group.redis_security_group: Destroying... [id=sg-0080f02036d1153f2]
aws_security_group.redis_security_group: Destruction complete after 2s
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-059a46a1baab6bd01, 10s elapsed]
aws_internet_gateway.redis_internet_gateway: Destruction complete after 13s
aws_vpc.redis_vpc: Destroying... [id=vpc-00228dd0c114f8550]
aws_vpc.redis_vpc: Destruction complete after 1s

Destroy complete! Resources: 9 destroyed.
trial1 $
```

---

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#network-interfaces

https://duckduckgo.com/?t=ffab&q=terraform+intepolation&ia=web

https://www.terraform.io/docs/configuration-0-11/interpolation.html

https://www.terraform.io/docs/language/functions/index.html

https://www.terraform.io/docs/language/functions/format.html

---

```bash
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.redis_server will be created
  + resource "aws_instance" "redis_server" {
      + ami                                  = "ami-029c64b3c205e6cce"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t4g.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aws"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "redis-server"
        }
      + tags_all                             = {
          + "Name" = "redis-server"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = false
          + device_index          = 0
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 8
          + volume_type           = (known after apply)
        }
    }

  # aws_internet_gateway.redis_internet_gateway will be created
  + resource "aws_internet_gateway" "redis_internet_gateway" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "redis-internet-gateway"
        }
      + tags_all = {
          + "Name" = "redis-internet-gateway"
        }
      + vpc_id   = (known after apply)
    }

  # aws_key_pair.redis_ssh_key will be created
  + resource "aws_key_pair" "redis_ssh_key" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = (known after apply)
      + key_name_prefix = "redis-ssh-key"
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
      + tags_all        = (known after apply)
    }

  # aws_network_interface.redis_network_interface will be created
  + resource "aws_network_interface" "redis_network_interface" {
      + id                 = (known after apply)
      + interface_type     = (known after apply)
      + ipv6_address_count = (known after apply)
      + ipv6_addresses     = (known after apply)
      + mac_address        = (known after apply)
      + outpost_arn        = (known after apply)
      + private_dns_name   = (known after apply)
      + private_ip         = (known after apply)
      + private_ips        = (known after apply)
      + private_ips_count  = (known after apply)
      + security_groups    = (known after apply)
      + source_dest_check  = true
      + subnet_id          = (known after apply)
      + tags               = {
          + "Name" = "redis-network-interface"
        }
      + tags_all           = {
          + "Name" = "redis-network-interface"
        }

      + attachment {
          + attachment_id = (known after apply)
          + device_index  = (known after apply)
          + instance      = (known after apply)
        }
    }

  # aws_route.redis_route will be created
  + resource "aws_route" "redis_route" {
      + destination_cidr_block = "10.0.0.0/24"
      + gateway_id             = (known after apply)
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)
    }

  # aws_route_table.redis_route_table will be created
  + resource "aws_route_table" "redis_route_table" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Name" = "redis-route-table"
        }
      + tags_all         = {
          + "Name" = "redis-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # aws_security_group.redis_security_group will be created
  + resource "aws_security_group" "redis_security_group" {
      + arn                    = (known after apply)
      + description            = "Allow Redis traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "allow_redis_traffic"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "allow-redis-traffic"
        }
      + tags_all               = {
          + "Name" = "allow-redis-traffic"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group_rule.redis_security_group_egress will be created
  + resource "aws_security_group_rule" "redis_security_group_egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # aws_security_group_rule.redis_security_group_ingress will be created
  + resource "aws_security_group_rule" "redis_security_group_ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Redis Traffic from the Internet"
      + from_port                = 22
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # aws_subnet.redis_subnet will be created
  + resource "aws_subnet" "redis_subnet" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = (known after apply)
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.0.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "redis-subnet"
        }
      + tags_all                        = {
          + "Name" = "redis-subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 11 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $ gst
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .gitignore
	new file:   .terraform.lock.hcl
	new file:   STORY.md
	new file:   main.tf

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   STORY.md
	modified:   main.tf

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	../../../../../cmu-database-systems-course/placeholder/

trial1 $ ga .
trial1 $
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.redis_server will be created
  + resource "aws_instance" "redis_server" {
      + ami                                  = "ami-029c64b3c205e6cce"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t4g.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aws"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "redis-server"
        }
      + tags_all                             = {
          + "Name" = "redis-server"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = false
          + device_index          = 0
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 8
          + volume_type           = (known after apply)
        }
    }

  # aws_internet_gateway.redis_internet_gateway will be created
  + resource "aws_internet_gateway" "redis_internet_gateway" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "redis-internet-gateway"
        }
      + tags_all = {
          + "Name" = "redis-internet-gateway"
        }
      + vpc_id   = (known after apply)
    }

  # aws_key_pair.redis_ssh_key will be created
  + resource "aws_key_pair" "redis_ssh_key" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = (known after apply)
      + key_name_prefix = "redis-ssh-key"
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
      + tags_all        = (known after apply)
    }

  # aws_network_interface.redis_network_interface will be created
  + resource "aws_network_interface" "redis_network_interface" {
      + id                 = (known after apply)
      + interface_type     = (known after apply)
      + ipv6_address_count = (known after apply)
      + ipv6_addresses     = (known after apply)
      + mac_address        = (known after apply)
      + outpost_arn        = (known after apply)
      + private_dns_name   = (known after apply)
      + private_ip         = (known after apply)
      + private_ips        = (known after apply)
      + private_ips_count  = (known after apply)
      + security_groups    = (known after apply)
      + source_dest_check  = true
      + subnet_id          = (known after apply)
      + tags               = {
          + "Name" = "redis-network-interface"
        }
      + tags_all           = {
          + "Name" = "redis-network-interface"
        }

      + attachment {
          + attachment_id = (known after apply)
          + device_index  = (known after apply)
          + instance      = (known after apply)
        }
    }

  # aws_route.redis_route will be created
  + resource "aws_route" "redis_route" {
      + destination_cidr_block = (known after apply)
      + gateway_id             = (known after apply)
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)
    }

  # aws_route_table.redis_route_table will be created
  + resource "aws_route_table" "redis_route_table" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Name" = "redis-route-table"
        }
      + tags_all         = {
          + "Name" = "redis-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # aws_security_group.redis_security_group will be created
  + resource "aws_security_group" "redis_security_group" {
      + arn                    = (known after apply)
      + description            = "Allow Redis traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "allow_redis_traffic"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "allow-redis-traffic"
        }
      + tags_all               = {
          + "Name" = "allow-redis-traffic"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group_rule.redis_security_group_egress will be created
  + resource "aws_security_group_rule" "redis_security_group_egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # aws_security_group_rule.redis_security_group_ingress will be created
  + resource "aws_security_group_rule" "redis_security_group_ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Redis Traffic from the Internet"
      + from_port                = 22
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # aws_subnet.redis_subnet will be created
  + resource "aws_subnet" "redis_subnet" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = (known after apply)
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.0.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "redis-subnet"
        }
      + tags_all                        = {
          + "Name" = "redis-subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 11 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $

```

```bash
trial1 $ terraform apply tfplan
aws_key_pair.redis_ssh_key: Creating...
aws_vpc.redis_vpc: Creating...
aws_key_pair.redis_ssh_key: Creation complete after 2s [id=redis-ssh-key20210925161011968600000001]
aws_vpc.redis_vpc: Still creating... [10s elapsed]
aws_vpc.redis_vpc: Creation complete after 12s [id=vpc-0d321af6048b821e5]
aws_internet_gateway.redis_internet_gateway: Creating...
aws_route_table.redis_route_table: Creating...
aws_subnet.redis_subnet: Creating...
aws_security_group.redis_security_group: Creating...
aws_route_table.redis_route_table: Creation complete after 3s [id=rtb-040ff4d3f4319adbb]
aws_subnet.redis_subnet: Creation complete after 4s [id=subnet-0b8e4bfdf1a200d78]
aws_network_interface.redis_network_interface: Creating...
aws_internet_gateway.redis_internet_gateway: Creation complete after 5s [id=igw-06ad7c09faee95735]
aws_security_group.redis_security_group: Creation complete after 7s [id=sg-0df6e9f40a710e2a8]
aws_security_group_rule.redis_security_group_ingress: Creating...
aws_security_group_rule.redis_security_group_egress: Creating...
aws_security_group_rule.redis_security_group_ingress: Creation complete after 4s [id=sgrule-3010105540]
aws_network_interface.redis_network_interface: Still creating... [10s elapsed]
aws_security_group_rule.redis_security_group_egress: Creation complete after 7s [id=sgrule-1587094055]
aws_network_interface.redis_network_interface: Still creating... [20s elapsed]
aws_network_interface.redis_network_interface: Still creating... [30s elapsed]
aws_network_interface.redis_network_interface: Creation complete after 33s [id=eni-04c3db1b609153c16]
aws_route.redis_route: Creating...
╷
│ Error: error creating Route in Route Table (rtb-040ff4d3f4319adbb) with destination (10.0.0.120/32): InvalidParameterValue: The destination CIDR block 10.0.0.120/32 is equal to or more specific than one of this VPC's CIDR blocks. This route can target only an interface or an instance.
│ 	status code: 400, request id: 2ceaf0a1-ad38-4755-938e-cb0d8934999a
│
│   with aws_route.redis_route,
│   on main.tf line 94, in resource "aws_route" "redis_route":
│   94: resource "aws_route" "redis_route" {
│
╵
╷
│ Error: Conflicting configuration arguments
│
│   with aws_instance.redis_server,
│   on main.tf line 100, in resource "aws_instance" "redis_server":
│  100: resource "aws_instance" "redis_server" {
│
│ "network_interface": conflicts with associate_public_ip_address
╵
trial1 $
```

```bash
trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925161011968600000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-0d321af6048b821e5]
aws_subnet.redis_subnet: Refreshing state... [id=subnet-0b8e4bfdf1a200d78]
aws_internet_gateway.redis_internet_gateway: Refreshing state... [id=igw-06ad7c09faee95735]
aws_route_table.redis_route_table: Refreshing state... [id=rtb-040ff4d3f4319adbb]
aws_security_group.redis_security_group: Refreshing state... [id=sg-0df6e9f40a710e2a8]
aws_security_group_rule.redis_security_group_egress: Refreshing state... [id=sgrule-1587094055]
aws_security_group_rule.redis_security_group_ingress: Refreshing state... [id=sgrule-3010105540]
aws_network_interface.redis_network_interface: Refreshing state... [id=eni-04c3db1b609153c16]
╷
│ Error: Conflicting configuration arguments
│
│   with aws_instance.redis_server,
│   on main.tf line 100, in resource "aws_instance" "redis_server":
│  100: resource "aws_instance" "redis_server" {
│
│ "network_interface": conflicts with associate_public_ip_address
╵
trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925161011968600000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-0d321af6048b821e5]
aws_route_table.redis_route_table: Refreshing state... [id=rtb-040ff4d3f4319adbb]
aws_internet_gateway.redis_internet_gateway: Refreshing state... [id=igw-06ad7c09faee95735]
aws_subnet.redis_subnet: Refreshing state... [id=subnet-0b8e4bfdf1a200d78]
aws_security_group.redis_security_group: Refreshing state... [id=sg-0df6e9f40a710e2a8]
aws_network_interface.redis_network_interface: Refreshing state... [id=eni-04c3db1b609153c16]
aws_security_group_rule.redis_security_group_ingress: Refreshing state... [id=sgrule-3010105540]
aws_security_group_rule.redis_security_group_egress: Refreshing state... [id=sgrule-1587094055]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_key_pair.redis_ssh_key has been changed
  ~ resource "aws_key_pair" "redis_ssh_key" {
        id              = "redis-ssh-key20210925161011968600000001"
      + tags            = {}
        # (7 unchanged attributes hidden)
    }
  # aws_security_group_rule.redis_security_group_egress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_egress" {
        id                = "sgrule-1587094055"
      + prefix_list_ids   = []
        # (8 unchanged attributes hidden)
    }
  # aws_security_group_rule.redis_security_group_ingress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_ingress" {
        id                = "sgrule-3010105540"
      + prefix_list_ids   = []
        # (9 unchanged attributes hidden)
    }
  # aws_security_group.redis_security_group has been changed
  ~ resource "aws_security_group" "redis_security_group" {
      ~ egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
        id                     = "sg-0df6e9f40a710e2a8"
      ~ ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Redis Traffic from the Internet"
              + from_port        = 22
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
        name                   = "allow_redis_traffic"
        tags                   = {
            "Name" = "allow-redis-traffic"
        }
        # (6 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_internet_gateway.redis_internet_gateway will be destroyed
  - resource "aws_internet_gateway" "redis_internet_gateway" {
      - arn      = "arn:aws:ec2:us-east-1:469318448823:internet-gateway/igw-06ad7c09faee95735" -> null
      - id       = "igw-06ad7c09faee95735" -> null
      - owner_id = "469318448823" -> null
      - tags     = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - tags_all = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - vpc_id   = "vpc-0d321af6048b821e5" -> null
    }

  # aws_key_pair.redis_ssh_key will be destroyed
  - resource "aws_key_pair" "redis_ssh_key" {
      - arn             = "arn:aws:ec2:us-east-1:469318448823:key-pair/redis-ssh-key20210925161011968600000001" -> null
      - fingerprint     = "e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw=" -> null
      - id              = "redis-ssh-key20210925161011968600000001" -> null
      - key_name        = "redis-ssh-key20210925161011968600000001" -> null
      - key_name_prefix = "redis-ssh-key" -> null
      - key_pair_id     = "key-057ea2d9c90cd3c18" -> null
      - public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com" -> null
      - tags            = {} -> null
      - tags_all        = {} -> null
    }

  # aws_network_interface.redis_network_interface will be destroyed
  - resource "aws_network_interface" "redis_network_interface" {
      - id                 = "eni-04c3db1b609153c16" -> null
      - interface_type     = "interface" -> null
      - ipv6_address_count = 0 -> null
      - ipv6_addresses     = [] -> null
      - mac_address        = "0a:c2:67:41:de:43" -> null
      - private_ip         = "10.0.0.120" -> null
      - private_ips        = [
          - "10.0.0.120",
        ] -> null
      - private_ips_count  = 0 -> null
      - security_groups    = [
          - "sg-04faefe95c68845f9",
        ] -> null
      - source_dest_check  = true -> null
      - subnet_id          = "subnet-0b8e4bfdf1a200d78" -> null
      - tags               = {
          - "Name" = "redis-network-interface"
        } -> null
      - tags_all           = {
          - "Name" = "redis-network-interface"
        } -> null
    }

  # aws_route_table.redis_route_table will be destroyed
  - resource "aws_route_table" "redis_route_table" {
      - arn              = "arn:aws:ec2:us-east-1:469318448823:route-table/rtb-040ff4d3f4319adbb" -> null
      - id               = "rtb-040ff4d3f4319adbb" -> null
      - owner_id         = "469318448823" -> null
      - propagating_vgws = [] -> null
      - route            = [] -> null
      - tags             = {
          - "Name" = "redis-route-table"
        } -> null
      - tags_all         = {
          - "Name" = "redis-route-table"
        } -> null
      - vpc_id           = "vpc-0d321af6048b821e5" -> null
    }

  # aws_security_group.redis_security_group will be destroyed
  - resource "aws_security_group" "redis_security_group" {
      - arn                    = "arn:aws:ec2:us-east-1:469318448823:security-group/sg-0df6e9f40a710e2a8" -> null
      - description            = "Allow Redis traffic" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0df6e9f40a710e2a8" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Redis Traffic from the Internet"
              - from_port        = 22
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "allow_redis_traffic" -> null
      - owner_id               = "469318448823" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - tags_all               = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - vpc_id                 = "vpc-0d321af6048b821e5" -> null
    }

  # aws_security_group_rule.redis_security_group_egress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_egress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 0 -> null
      - id                = "sgrule-1587094055" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "-1" -> null
      - security_group_id = "sg-0df6e9f40a710e2a8" -> null
      - self              = false -> null
      - to_port           = 0 -> null
      - type              = "egress" -> null
    }

  # aws_security_group_rule.redis_security_group_ingress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - description       = "Redis Traffic from the Internet" -> null
      - from_port         = 22 -> null
      - id                = "sgrule-3010105540" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0df6e9f40a710e2a8" -> null
      - self              = false -> null
      - to_port           = 22 -> null
      - type              = "ingress" -> null
    }

  # aws_subnet.redis_subnet will be destroyed
  - resource "aws_subnet" "redis_subnet" {
      - arn                             = "arn:aws:ec2:us-east-1:469318448823:subnet/subnet-0b8e4bfdf1a200d78" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-east-1b" -> null
      - availability_zone_id            = "use1-az4" -> null
      - cidr_block                      = "10.0.0.0/24" -> null
      - id                              = "subnet-0b8e4bfdf1a200d78" -> null
      - map_customer_owned_ip_on_launch = false -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "469318448823" -> null
      - tags                            = {
          - "Name" = "redis-subnet"
        } -> null
      - tags_all                        = {
          - "Name" = "redis-subnet"
        } -> null
      - vpc_id                          = "vpc-0d321af6048b821e5" -> null
    }

  # aws_vpc.redis_vpc will be destroyed
  - resource "aws_vpc" "redis_vpc" {
      - arn                              = "arn:aws:ec2:us-east-1:469318448823:vpc/vpc-0d321af6048b821e5" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.0.0.0/16" -> null
      - default_network_acl_id           = "acl-01da8c3d6f7771536" -> null
      - default_route_table_id           = "rtb-0dafc7041e78277df" -> null
      - default_security_group_id        = "sg-04faefe95c68845f9" -> null
      - dhcp_options_id                  = "dopt-6fb3e10a" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = false -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-0d321af6048b821e5" -> null
      - instance_tenancy                 = "default" -> null
      - main_route_table_id              = "rtb-0dafc7041e78277df" -> null
      - owner_id                         = "469318448823" -> null
      - tags                             = {
          - "Name" = "redis-vpc"
        } -> null
      - tags_all                         = {
          - "Name" = "redis-vpc"
        } -> null
    }

Plan: 0 to add, 0 to change, 9 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_key_pair.redis_ssh_key: Destroying... [id=redis-ssh-key20210925161011968600000001]
aws_internet_gateway.redis_internet_gateway: Destroying... [id=igw-06ad7c09faee95735]
aws_security_group_rule.redis_security_group_ingress: Destroying... [id=sgrule-3010105540]
aws_security_group_rule.redis_security_group_egress: Destroying... [id=sgrule-1587094055]
aws_network_interface.redis_network_interface: Destroying... [id=eni-04c3db1b609153c16]
aws_route_table.redis_route_table: Destroying... [id=rtb-040ff4d3f4319adbb]
aws_key_pair.redis_ssh_key: Destruction complete after 1s
aws_network_interface.redis_network_interface: Destruction complete after 1s
aws_subnet.redis_subnet: Destroying... [id=subnet-0b8e4bfdf1a200d78]
aws_security_group_rule.redis_security_group_ingress: Destruction complete after 2s
aws_route_table.redis_route_table: Destruction complete after 3s
aws_subnet.redis_subnet: Destruction complete after 3s
aws_security_group_rule.redis_security_group_egress: Destruction complete after 4s
aws_security_group.redis_security_group: Destroying... [id=sg-0df6e9f40a710e2a8]
aws_security_group.redis_security_group: Destruction complete after 3s
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-06ad7c09faee95735, 10s elapsed]
aws_internet_gateway.redis_internet_gateway: Destruction complete after 12s
aws_vpc.redis_vpc: Destroying... [id=vpc-0d321af6048b821e5]
aws_vpc.redis_vpc: Destruction complete after 1s

Destroy complete! Resources: 9 destroyed.
trial1 $
```

---

https://duckduckgo.com/?t=ffab&q=aws+route+table+association&ia=web

https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/associate-route-table.html

https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

https://docs.aws.amazon.com/vpc/latest/userguide/managed-prefix-lists.html

---

```bash
trial1 $ terraform plan -out tfplan
╷
│ Error: expected "destination_cidr_block" to be an empty string: got ::/0
│
│   with aws_route.redis_route_ipv6_internet_access,
│   on main.tf line 94, in resource "aws_route" "redis_route_ipv6_internet_access":
│   94:   destination_cidr_block = "::/0"
│
╵
╷
│ Error: "::/0" is not a valid IPv4 CIDR block
│
│   with aws_route.redis_route_ipv6_internet_access,
│   on main.tf line 94, in resource "aws_route" "redis_route_ipv6_internet_access":
│   94:   destination_cidr_block = "::/0"
│
╵
trial1 $
```

---

```bash
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.redis_server will be created
  + resource "aws_instance" "redis_server" {
      + ami                                  = "ami-029c64b3c205e6cce"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t4g.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aws"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "redis-server"
        }
      + tags_all                             = {
          + "Name" = "redis-server"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 8
          + volume_type           = (known after apply)
        }
    }

  # aws_internet_gateway.redis_internet_gateway will be created
  + resource "aws_internet_gateway" "redis_internet_gateway" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "redis-internet-gateway"
        }
      + tags_all = {
          + "Name" = "redis-internet-gateway"
        }
      + vpc_id   = (known after apply)
    }

  # aws_key_pair.redis_ssh_key will be created
  + resource "aws_key_pair" "redis_ssh_key" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = (known after apply)
      + key_name_prefix = "redis-ssh-key"
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
      + tags_all        = (known after apply)
    }

  # aws_route.redis_route_ipv4_internet_access will be created
  + resource "aws_route" "redis_route_ipv4_internet_access" {
      + destination_cidr_block = "0.0.0.0/0"
      + gateway_id             = (known after apply)
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)
    }

  # aws_route.redis_route_ipv6_internet_access will be created
  + resource "aws_route" "redis_route_ipv6_internet_access" {
      + destination_ipv6_cidr_block = "::/0"
      + gateway_id                  = (known after apply)
      + id                          = (known after apply)
      + instance_id                 = (known after apply)
      + instance_owner_id           = (known after apply)
      + network_interface_id        = (known after apply)
      + origin                      = (known after apply)
      + route_table_id              = (known after apply)
      + state                       = (known after apply)
    }

  # aws_route_table.redis_route_table will be created
  + resource "aws_route_table" "redis_route_table" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Name" = "redis-route-table"
        }
      + tags_all         = {
          + "Name" = "redis-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.redis_route_table_with_subnet will be created
  + resource "aws_route_table_association" "redis_route_table_with_subnet" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.redis_security_group will be created
  + resource "aws_security_group" "redis_security_group" {
      + arn                    = (known after apply)
      + description            = "Allow Redis traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "allow_redis_traffic"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "allow-redis-traffic"
        }
      + tags_all               = {
          + "Name" = "allow-redis-traffic"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group_rule.redis_security_group_egress will be created
  + resource "aws_security_group_rule" "redis_security_group_egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # aws_security_group_rule.redis_security_group_ingress will be created
  + resource "aws_security_group_rule" "redis_security_group_ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Redis Traffic from the Internet"
      + from_port                = 22
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # aws_subnet.redis_subnet will be created
  + resource "aws_subnet" "redis_subnet" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = (known after apply)
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.0.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "redis-subnet"
        }
      + tags_all                        = {
          + "Name" = "redis-subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 12 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $ terraform apply tfplan
aws_key_pair.redis_ssh_key: Creating...
aws_vpc.redis_vpc: Creating...
aws_key_pair.redis_ssh_key: Creation complete after 2s [id=redis-ssh-key20210925173804304400000001]
aws_vpc.redis_vpc: Still creating... [10s elapsed]
aws_vpc.redis_vpc: Creation complete after 12s [id=vpc-0b45c36773ac7882c]
aws_internet_gateway.redis_internet_gateway: Creating...
aws_route_table.redis_route_table: Creating...
aws_subnet.redis_subnet: Creating...
aws_security_group.redis_security_group: Creating...
aws_route_table.redis_route_table: Creation complete after 3s [id=rtb-0b7924b8e6f57cfb0]
aws_subnet.redis_subnet: Creation complete after 3s [id=subnet-05db60892d72c5558]
aws_route_table_association.redis_route_table_with_subnet: Creating...
aws_internet_gateway.redis_internet_gateway: Creation complete after 5s [id=igw-08b9b28b4806e8aad]
aws_route.redis_route_ipv6_internet_access: Creating...
aws_route.redis_route_ipv4_internet_access: Creating...
aws_route_table_association.redis_route_table_with_subnet: Creation complete after 3s [id=rtbassoc-0c38a59517b8bb125]
aws_security_group.redis_security_group: Creation complete after 6s [id=sg-0396f39a81eb9f1c2]
aws_security_group_rule.redis_security_group_ingress: Creating...
aws_security_group_rule.redis_security_group_egress: Creating...
aws_instance.redis_server: Creating...
aws_route.redis_route_ipv6_internet_access: Creation complete after 3s [id=r-rtb-0b7924b8e6f57cfb02750132062]
aws_route.redis_route_ipv4_internet_access: Creation complete after 4s [id=r-rtb-0b7924b8e6f57cfb01080289494]
aws_security_group_rule.redis_security_group_egress: Creation complete after 3s [id=sgrule-3652026972]
aws_security_group_rule.redis_security_group_ingress: Creation complete after 7s [id=sgrule-2580997973]
aws_instance.redis_server: Still creating... [10s elapsed]
aws_instance.redis_server: Still creating... [20s elapsed]
aws_instance.redis_server: Creation complete after 22s [id=i-06804bc5c48d40b7e]

Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
trial1 $ ssh -v -i dummy-key ec2-user@34.236.33.160
OpenSSH_8.1p1, LibreSSL 2.7.3
debug1: Reading configuration data /Users/karuppiahn/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 47: Applying options for *
debug1: Connecting to 34.236.33.160 [34.236.33.160] port 22.
debug1: Connection established.
debug1: identity file dummy-key type 3
debug1: identity file dummy-key-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_8.1
debug1: Remote protocol version 2.0, remote software version OpenSSH_7.4
debug1: match: OpenSSH_7.4 pat OpenSSH_7.0*,OpenSSH_7.1*,OpenSSH_7.2*,OpenSSH_7.3*,OpenSSH_7.4*,OpenSSH_7.5*,OpenSSH_7.6*,OpenSSH_7.7* compat 0x04000002
debug1: Authenticating to 34.236.33.160:22 as 'ec2-user'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:LPzy4nbdXAq38m+JpyvYlzzsx97tKkrpZBlaXWCNwz4
The authenticity of host '34.236.33.160 (34.236.33.160)' can't be established.
ECDSA key fingerprint is SHA256:LPzy4nbdXAq38m+JpyvYlzzsx97tKkrpZBlaXWCNwz4.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '34.236.33.160' (ECDSA) to the list of known hosts.
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey in after 134217728 blocks
debug1: Will attempt key: karuppiahn@vmware.com ED25519 SHA256:3vku70losGmr1kmlRT52RuAG4e0IEDevQV+uOmCL3NI agent
debug1: Will attempt key: dummy-key ED25519 SHA256:e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw explicit
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<rsa-sha2-256,rsa-sha2-512>
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-with-mic
debug1: Next authentication method: publickey
debug1: Offering public key: karuppiahn@vmware.com ED25519 SHA256:3vku70losGmr1kmlRT52RuAG4e0IEDevQV+uOmCL3NI agent
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-with-mic
debug1: Offering public key: dummy-key ED25519 SHA256:e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw explicit
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-with-mic
debug1: No more authentication methods to try.
ec2-user@34.236.33.160: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
trial1 $ ssh -v -i ~/.ssh/aws ec2-user@34.236.33.160
OpenSSH_8.1p1, LibreSSL 2.7.3
debug1: Reading configuration data /Users/karuppiahn/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 47: Applying options for *
debug1: Connecting to 34.236.33.160 [34.236.33.160] port 22.
debug1: Connection established.
debug1: identity file /Users/karuppiahn/.ssh/aws type 0
debug1: identity file /Users/karuppiahn/.ssh/aws-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_8.1
debug1: Remote protocol version 2.0, remote software version OpenSSH_7.4
debug1: match: OpenSSH_7.4 pat OpenSSH_7.0*,OpenSSH_7.1*,OpenSSH_7.2*,OpenSSH_7.3*,OpenSSH_7.4*,OpenSSH_7.5*,OpenSSH_7.6*,OpenSSH_7.7* compat 0x04000002
debug1: Authenticating to 34.236.33.160:22 as 'ec2-user'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:LPzy4nbdXAq38m+JpyvYlzzsx97tKkrpZBlaXWCNwz4
debug1: Host '34.236.33.160' is known and matches the ECDSA host key.
debug1: Found key in /Users/karuppiahn/.ssh/known_hosts:49
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey in after 134217728 blocks
debug1: Will attempt key: karuppiahn@vmware.com ED25519 SHA256:3vku70losGmr1kmlRT52RuAG4e0IEDevQV+uOmCL3NI agent
debug1: Will attempt key: /Users/karuppiahn/.ssh/aws RSA SHA256:qImJtkIChdPcSAPsZkAhWxOfMBBJEIm4wQ/792Yf6NU explicit
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<rsa-sha2-256,rsa-sha2-512>
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-with-mic
debug1: Next authentication method: publickey
debug1: Offering public key: karuppiahn@vmware.com ED25519 SHA256:3vku70losGmr1kmlRT52RuAG4e0IEDevQV+uOmCL3NI agent
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-with-mic
debug1: Offering public key: /Users/karuppiahn/.ssh/aws RSA SHA256:qImJtkIChdPcSAPsZkAhWxOfMBBJEIm4wQ/792Yf6NU explicit
debug1: Server accepts key: /Users/karuppiahn/.ssh/aws RSA SHA256:qImJtkIChdPcSAPsZkAhWxOfMBBJEIm4wQ/792Yf6NU explicit
Enter passphrase for key '/Users/karuppiahn/.ssh/aws':
debug1: Authentication succeeded (publickey).
Authenticated to 34.236.33.160 ([34.236.33.160]:22).
debug1: channel 0: new [client-session]
debug1: Requesting no-more-sessions@openssh.com
debug1: Entering interactive session.
debug1: pledge: network
debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
debug1: Sending environment.
debug1: Sending env LC_CTYPE = UTF-8

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
11 package(s) needed for security, out of 34 available
Run "sudo yum update" to apply all updates.
-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
[ec2-user@ip-10-0-0-196 ~]$ debug1: client_input_channel_req: channel 0 rtype exit-status reply 0
debug1: client_input_channel_req: channel 0 rtype eow@openssh.com reply 0
logout
debug1: channel 0: free: client-session, nchannels 1
Connection to 34.236.33.160 closed.
Transferred: sent 3212, received 3316 bytes, in 2.2 seconds
Bytes per second: sent 1453.3, received 1500.3
debug1: Exit status 0
trial1 $
```

---

https://github.com/joshrosso/workstation/blob/master/terraform/servers.tf

---

```bash
trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925173804304400000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-0b45c36773ac7882c]
aws_route_table.redis_route_table: Refreshing state... [id=rtb-0b7924b8e6f57cfb0]
aws_internet_gateway.redis_internet_gateway: Refreshing state... [id=igw-08b9b28b4806e8aad]
aws_security_group.redis_security_group: Refreshing state... [id=sg-0396f39a81eb9f1c2]
aws_subnet.redis_subnet: Refreshing state... [id=subnet-05db60892d72c5558]
aws_security_group_rule.redis_security_group_egress: Refreshing state... [id=sgrule-3652026972]
aws_security_group_rule.redis_security_group_ingress: Refreshing state... [id=sgrule-2580997973]
aws_instance.redis_server: Refreshing state... [id=i-06804bc5c48d40b7e]
aws_route_table_association.redis_route_table_with_subnet: Refreshing state... [id=rtbassoc-0c38a59517b8bb125]
aws_route.redis_route_ipv4_internet_access: Refreshing state... [id=r-rtb-0b7924b8e6f57cfb01080289494]
aws_route.redis_route_ipv6_internet_access: Refreshing state... [id=r-rtb-0b7924b8e6f57cfb02750132062]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_route_table.redis_route_table has been changed
  ~ resource "aws_route_table" "redis_route_table" {
        id               = "rtb-0b7924b8e6f57cfb0"
      ~ route            = [
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = ""
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = "igw-08b9b28b4806e8aad"
              + instance_id                = ""
              + ipv6_cidr_block            = "::/0"
              + local_gateway_id           = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = "0.0.0.0/0"
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = "igw-08b9b28b4806e8aad"
              + instance_id                = ""
              + ipv6_cidr_block            = ""
              + local_gateway_id           = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
        ]
        tags             = {
            "Name" = "redis-route-table"
        }
        # (5 unchanged attributes hidden)
    }
  # aws_security_group_rule.redis_security_group_ingress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_ingress" {
        id                = "sgrule-2580997973"
      + prefix_list_ids   = []
        # (9 unchanged attributes hidden)
    }
  # aws_key_pair.redis_ssh_key has been changed
  ~ resource "aws_key_pair" "redis_ssh_key" {
        id              = "redis-ssh-key20210925173804304400000001"
      + tags            = {}
        # (7 unchanged attributes hidden)
    }
  # aws_security_group.redis_security_group has been changed
  ~ resource "aws_security_group" "redis_security_group" {
      ~ egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
        id                     = "sg-0396f39a81eb9f1c2"
      ~ ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Redis Traffic from the Internet"
              + from_port        = 22
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
        name                   = "allow_redis_traffic"
        tags                   = {
            "Name" = "allow-redis-traffic"
        }
        # (6 unchanged attributes hidden)
    }
  # aws_instance.redis_server has been changed
  ~ resource "aws_instance" "redis_server" {
        id                                   = "i-06804bc5c48d40b7e"
        tags                                 = {
            "Name" = "redis-server"
        }
        # (28 unchanged attributes hidden)




      ~ root_block_device {
          + tags                  = {}
            # (8 unchanged attributes hidden)
        }
        # (3 unchanged blocks hidden)
    }
  # aws_security_group_rule.redis_security_group_egress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_egress" {
        id                = "sgrule-3652026972"
      + prefix_list_ids   = []
        # (8 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.redis_server will be destroyed
  - resource "aws_instance" "redis_server" {
      - ami                                  = "ami-029c64b3c205e6cce" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:469318448823:instance/i-06804bc5c48d40b7e" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "us-east-1f" -> null
      - cpu_core_count                       = 2 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-06804bc5c48d40b7e" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t4g.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - key_name                             = "aws" -> null
      - monitoring                           = false -> null
      - primary_network_interface_id         = "eni-04e72624a2018d44a" -> null
      - private_dns                          = "ip-10-0-0-196.ec2.internal" -> null
      - private_ip                           = "10.0.0.196" -> null
      - public_ip                            = "34.236.33.160" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-05db60892d72c5558" -> null
      - tags                                 = {
          - "Name" = "redis-server"
        } -> null
      - tags_all                             = {
          - "Name" = "redis-server"
        } -> null
      - tenancy                              = "default" -> null
      - vpc_security_group_ids               = [
          - "sg-0396f39a81eb9f1c2",
        ] -> null

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/xvda" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-05b2f8ade147c074c" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
        }
    }

  # aws_internet_gateway.redis_internet_gateway will be destroyed
  - resource "aws_internet_gateway" "redis_internet_gateway" {
      - arn      = "arn:aws:ec2:us-east-1:469318448823:internet-gateway/igw-08b9b28b4806e8aad" -> null
      - id       = "igw-08b9b28b4806e8aad" -> null
      - owner_id = "469318448823" -> null
      - tags     = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - tags_all = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - vpc_id   = "vpc-0b45c36773ac7882c" -> null
    }

  # aws_key_pair.redis_ssh_key will be destroyed
  - resource "aws_key_pair" "redis_ssh_key" {
      - arn             = "arn:aws:ec2:us-east-1:469318448823:key-pair/redis-ssh-key20210925173804304400000001" -> null
      - fingerprint     = "e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw=" -> null
      - id              = "redis-ssh-key20210925173804304400000001" -> null
      - key_name        = "redis-ssh-key20210925173804304400000001" -> null
      - key_name_prefix = "redis-ssh-key" -> null
      - key_pair_id     = "key-047628fe8c6579aef" -> null
      - public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com" -> null
      - tags            = {} -> null
      - tags_all        = {} -> null
    }

  # aws_route.redis_route_ipv4_internet_access will be destroyed
  - resource "aws_route" "redis_route_ipv4_internet_access" {
      - destination_cidr_block = "0.0.0.0/0" -> null
      - gateway_id             = "igw-08b9b28b4806e8aad" -> null
      - id                     = "r-rtb-0b7924b8e6f57cfb01080289494" -> null
      - origin                 = "CreateRoute" -> null
      - route_table_id         = "rtb-0b7924b8e6f57cfb0" -> null
      - state                  = "active" -> null
    }

  # aws_route.redis_route_ipv6_internet_access will be destroyed
  - resource "aws_route" "redis_route_ipv6_internet_access" {
      - destination_ipv6_cidr_block = "::/0" -> null
      - gateway_id                  = "igw-08b9b28b4806e8aad" -> null
      - id                          = "r-rtb-0b7924b8e6f57cfb02750132062" -> null
      - origin                      = "CreateRoute" -> null
      - route_table_id              = "rtb-0b7924b8e6f57cfb0" -> null
      - state                       = "active" -> null
    }

  # aws_route_table.redis_route_table will be destroyed
  - resource "aws_route_table" "redis_route_table" {
      - arn              = "arn:aws:ec2:us-east-1:469318448823:route-table/rtb-0b7924b8e6f57cfb0" -> null
      - id               = "rtb-0b7924b8e6f57cfb0" -> null
      - owner_id         = "469318448823" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - carrier_gateway_id         = ""
              - cidr_block                 = ""
              - destination_prefix_list_id = ""
              - egress_only_gateway_id     = ""
              - gateway_id                 = "igw-08b9b28b4806e8aad"
              - instance_id                = ""
              - ipv6_cidr_block            = "::/0"
              - local_gateway_id           = ""
              - nat_gateway_id             = ""
              - network_interface_id       = ""
              - transit_gateway_id         = ""
              - vpc_endpoint_id            = ""
              - vpc_peering_connection_id  = ""
            },
          - {
              - carrier_gateway_id         = ""
              - cidr_block                 = "0.0.0.0/0"
              - destination_prefix_list_id = ""
              - egress_only_gateway_id     = ""
              - gateway_id                 = "igw-08b9b28b4806e8aad"
              - instance_id                = ""
              - ipv6_cidr_block            = ""
              - local_gateway_id           = ""
              - nat_gateway_id             = ""
              - network_interface_id       = ""
              - transit_gateway_id         = ""
              - vpc_endpoint_id            = ""
              - vpc_peering_connection_id  = ""
            },
        ] -> null
      - tags             = {
          - "Name" = "redis-route-table"
        } -> null
      - tags_all         = {
          - "Name" = "redis-route-table"
        } -> null
      - vpc_id           = "vpc-0b45c36773ac7882c" -> null
    }

  # aws_route_table_association.redis_route_table_with_subnet will be destroyed
  - resource "aws_route_table_association" "redis_route_table_with_subnet" {
      - id             = "rtbassoc-0c38a59517b8bb125" -> null
      - route_table_id = "rtb-0b7924b8e6f57cfb0" -> null
      - subnet_id      = "subnet-05db60892d72c5558" -> null
    }

  # aws_security_group.redis_security_group will be destroyed
  - resource "aws_security_group" "redis_security_group" {
      - arn                    = "arn:aws:ec2:us-east-1:469318448823:security-group/sg-0396f39a81eb9f1c2" -> null
      - description            = "Allow Redis traffic" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0396f39a81eb9f1c2" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Redis Traffic from the Internet"
              - from_port        = 22
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "allow_redis_traffic" -> null
      - owner_id               = "469318448823" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - tags_all               = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - vpc_id                 = "vpc-0b45c36773ac7882c" -> null
    }

  # aws_security_group_rule.redis_security_group_egress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_egress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 0 -> null
      - id                = "sgrule-3652026972" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "-1" -> null
      - security_group_id = "sg-0396f39a81eb9f1c2" -> null
      - self              = false -> null
      - to_port           = 0 -> null
      - type              = "egress" -> null
    }

  # aws_security_group_rule.redis_security_group_ingress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - description       = "Redis Traffic from the Internet" -> null
      - from_port         = 22 -> null
      - id                = "sgrule-2580997973" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0396f39a81eb9f1c2" -> null
      - self              = false -> null
      - to_port           = 22 -> null
      - type              = "ingress" -> null
    }

  # aws_subnet.redis_subnet will be destroyed
  - resource "aws_subnet" "redis_subnet" {
      - arn                             = "arn:aws:ec2:us-east-1:469318448823:subnet/subnet-05db60892d72c5558" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-east-1f" -> null
      - availability_zone_id            = "use1-az5" -> null
      - cidr_block                      = "10.0.0.0/24" -> null
      - id                              = "subnet-05db60892d72c5558" -> null
      - map_customer_owned_ip_on_launch = false -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "469318448823" -> null
      - tags                            = {
          - "Name" = "redis-subnet"
        } -> null
      - tags_all                        = {
          - "Name" = "redis-subnet"
        } -> null
      - vpc_id                          = "vpc-0b45c36773ac7882c" -> null
    }

  # aws_vpc.redis_vpc will be destroyed
  - resource "aws_vpc" "redis_vpc" {
      - arn                              = "arn:aws:ec2:us-east-1:469318448823:vpc/vpc-0b45c36773ac7882c" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.0.0.0/16" -> null
      - default_network_acl_id           = "acl-0a1b0106caba9828f" -> null
      - default_route_table_id           = "rtb-0da7568e9bea8d94a" -> null
      - default_security_group_id        = "sg-09ada6104a5384446" -> null
      - dhcp_options_id                  = "dopt-6fb3e10a" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = false -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-0b45c36773ac7882c" -> null
      - instance_tenancy                 = "default" -> null
      - main_route_table_id              = "rtb-0da7568e9bea8d94a" -> null
      - owner_id                         = "469318448823" -> null
      - tags                             = {
          - "Name" = "redis-vpc"
        } -> null
      - tags_all                         = {
          - "Name" = "redis-vpc"
        } -> null
    }

Plan: 0 to add, 0 to change, 12 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_route_table_association.redis_route_table_with_subnet: Destroying... [id=rtbassoc-0c38a59517b8bb125]
aws_key_pair.redis_ssh_key: Destroying... [id=redis-ssh-key20210925173804304400000001]
aws_security_group_rule.redis_security_group_ingress: Destroying... [id=sgrule-2580997973]
aws_security_group_rule.redis_security_group_egress: Destroying... [id=sgrule-3652026972]
aws_route.redis_route_ipv6_internet_access: Destroying... [id=r-rtb-0b7924b8e6f57cfb02750132062]
aws_route.redis_route_ipv4_internet_access: Destroying... [id=r-rtb-0b7924b8e6f57cfb01080289494]
aws_instance.redis_server: Destroying... [id=i-06804bc5c48d40b7e]
aws_key_pair.redis_ssh_key: Destruction complete after 1s
aws_route_table_association.redis_route_table_with_subnet: Destruction complete after 2s
aws_security_group_rule.redis_security_group_egress: Destruction complete after 2s
aws_route.redis_route_ipv6_internet_access: Destruction complete after 3s
aws_route.redis_route_ipv4_internet_access: Destruction complete after 3s
aws_internet_gateway.redis_internet_gateway: Destroying... [id=igw-08b9b28b4806e8aad]
aws_route_table.redis_route_table: Destroying... [id=rtb-0b7924b8e6f57cfb0]
aws_security_group_rule.redis_security_group_ingress: Destruction complete after 4s
aws_route_table.redis_route_table: Destruction complete after 3s
aws_instance.redis_server: Still destroying... [id=i-06804bc5c48d40b7e, 10s elapsed]
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-08b9b28b4806e8aad, 10s elapsed]
aws_instance.redis_server: Still destroying... [id=i-06804bc5c48d40b7e, 20s elapsed]
aws_internet_gateway.redis_internet_gateway: Destruction complete after 17s
aws_instance.redis_server: Destruction complete after 24s
aws_subnet.redis_subnet: Destroying... [id=subnet-05db60892d72c5558]
aws_security_group.redis_security_group: Destroying... [id=sg-0396f39a81eb9f1c2]
aws_security_group.redis_security_group: Destruction complete after 2s
aws_subnet.redis_subnet: Destruction complete after 3s
aws_vpc.redis_vpc: Destroying... [id=vpc-0b45c36773ac7882c]
aws_vpc.redis_vpc: Destruction complete after 1s

Destroy complete! Resources: 12 destroyed.
trial1 $
```

---

```bash
trial1 $ terraform plan -out tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.redis_server will be created
  + resource "aws_instance" "redis_server" {
      + ami                                  = "ami-029c64b3c205e6cce"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t4g.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "redis-server"
        }
      + tags_all                             = {
          + "Name" = "redis-server"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 8
          + volume_type           = (known after apply)
        }
    }

  # aws_internet_gateway.redis_internet_gateway will be created
  + resource "aws_internet_gateway" "redis_internet_gateway" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "redis-internet-gateway"
        }
      + tags_all = {
          + "Name" = "redis-internet-gateway"
        }
      + vpc_id   = (known after apply)
    }

  # aws_key_pair.redis_ssh_key will be created
  + resource "aws_key_pair" "redis_ssh_key" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = (known after apply)
      + key_name_prefix = "redis-ssh-key"
      + key_pair_id     = (known after apply)
      + public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
      + tags_all        = (known after apply)
    }

  # aws_route.redis_route_ipv4_internet_access will be created
  + resource "aws_route" "redis_route_ipv4_internet_access" {
      + destination_cidr_block = "0.0.0.0/0"
      + gateway_id             = (known after apply)
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)
    }

  # aws_route.redis_route_ipv6_internet_access will be created
  + resource "aws_route" "redis_route_ipv6_internet_access" {
      + destination_ipv6_cidr_block = "::/0"
      + gateway_id                  = (known after apply)
      + id                          = (known after apply)
      + instance_id                 = (known after apply)
      + instance_owner_id           = (known after apply)
      + network_interface_id        = (known after apply)
      + origin                      = (known after apply)
      + route_table_id              = (known after apply)
      + state                       = (known after apply)
    }

  # aws_route_table.redis_route_table will be created
  + resource "aws_route_table" "redis_route_table" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Name" = "redis-route-table"
        }
      + tags_all         = {
          + "Name" = "redis-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.redis_route_table_with_subnet will be created
  + resource "aws_route_table_association" "redis_route_table_with_subnet" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.redis_security_group will be created
  + resource "aws_security_group" "redis_security_group" {
      + arn                    = (known after apply)
      + description            = "Allow Redis traffic"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "allow_redis_traffic"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "allow-redis-traffic"
        }
      + tags_all               = {
          + "Name" = "allow-redis-traffic"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group_rule.redis_security_group_egress will be created
  + resource "aws_security_group_rule" "redis_security_group_egress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # aws_security_group_rule.redis_security_group_ingress will be created
  + resource "aws_security_group_rule" "redis_security_group_ingress" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Redis Traffic from the Internet"
      + from_port                = 22
      + id                       = (known after apply)
      + ipv6_cidr_blocks         = [
          + "::/0",
        ]
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # aws_subnet.redis_subnet will be created
  + resource "aws_subnet" "redis_subnet" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = (known after apply)
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.0.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "redis-subnet"
        }
      + tags_all                        = {
          + "Name" = "redis-subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.redis_vpc will be created
  + resource "aws_vpc" "redis_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "redis-vpc"
        }
      + tags_all                         = {
          + "Name" = "redis-vpc"
        }
    }

Plan: 12 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ip = (known after apply)

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
trial1 $ terraform apply tfplan
aws_key_pair.redis_ssh_key: Creating...
aws_vpc.redis_vpc: Creating...
aws_key_pair.redis_ssh_key: Creation complete after 2s [id=redis-ssh-key20210925174953991200000001]
aws_vpc.redis_vpc: Still creating... [10s elapsed]
aws_vpc.redis_vpc: Creation complete after 11s [id=vpc-03d7951ba6c86ba72]
aws_internet_gateway.redis_internet_gateway: Creating...
aws_route_table.redis_route_table: Creating...
aws_subnet.redis_subnet: Creating...
aws_security_group.redis_security_group: Creating...
aws_route_table.redis_route_table: Creation complete after 3s [id=rtb-0f1908557cca58987]
aws_subnet.redis_subnet: Creation complete after 4s [id=subnet-0e332317735330792]
aws_route_table_association.redis_route_table_with_subnet: Creating...
aws_internet_gateway.redis_internet_gateway: Creation complete after 5s [id=igw-0f99d81bcb0643aa7]
aws_route.redis_route_ipv6_internet_access: Creating...
aws_route.redis_route_ipv4_internet_access: Creating...
aws_route_table_association.redis_route_table_with_subnet: Creation complete after 3s [id=rtbassoc-0114c433f0861317d]
aws_security_group.redis_security_group: Creation complete after 7s [id=sg-0fd0bf4fde6011b74]
aws_security_group_rule.redis_security_group_egress: Creating...
aws_security_group_rule.redis_security_group_ingress: Creating...
aws_instance.redis_server: Creating...
aws_route.redis_route_ipv4_internet_access: Creation complete after 5s [id=r-rtb-0f1908557cca589871080289494]
aws_route.redis_route_ipv6_internet_access: Creation complete after 5s [id=r-rtb-0f1908557cca589872750132062]
aws_security_group_rule.redis_security_group_egress: Creation complete after 3s [id=sgrule-218942937]
aws_security_group_rule.redis_security_group_ingress: Creation complete after 7s [id=sgrule-2658890409]
aws_instance.redis_server: Still creating... [10s elapsed]
aws_instance.redis_server: Still creating... [20s elapsed]
aws_instance.redis_server: Creation complete after 22s [id=i-0162661ba412ca2d4]

Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

ip = "52.91.70.219"
trial1 $ ssh -v -i dummy-key ec2-user@52.91.70.219
OpenSSH_8.1p1, LibreSSL 2.7.3
debug1: Reading configuration data /Users/karuppiahn/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 47: Applying options for *
debug1: Connecting to 52.91.70.219 [52.91.70.219] port 22.
debug1: Connection established.
debug1: identity file dummy-key type 3
debug1: identity file dummy-key-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_8.1
debug1: Remote protocol version 2.0, remote software version OpenSSH_7.4
debug1: match: OpenSSH_7.4 pat OpenSSH_7.0*,OpenSSH_7.1*,OpenSSH_7.2*,OpenSSH_7.3*,OpenSSH_7.4*,OpenSSH_7.5*,OpenSSH_7.6*,OpenSSH_7.7* compat 0x04000002
debug1: Authenticating to 52.91.70.219:22 as 'ec2-user'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:wZyGZgxipPjT6quhQZZOEhzb3pEoshWQSmJbUhZQKlo
The authenticity of host '52.91.70.219 (52.91.70.219)' can't be established.
ECDSA key fingerprint is SHA256:wZyGZgxipPjT6quhQZZOEhzb3pEoshWQSmJbUhZQKlo.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '52.91.70.219' (ECDSA) to the list of known hosts.
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey in after 134217728 blocks
debug1: Will attempt key: karuppiahn@vmware.com ED25519 SHA256:3vku70losGmr1kmlRT52RuAG4e0IEDevQV+uOmCL3NI agent
debug1: Will attempt key: dummy-key ED25519 SHA256:e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw explicit
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<rsa-sha2-256,rsa-sha2-512>
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-with-mic
debug1: Next authentication method: publickey
debug1: Offering public key: karuppiahn@vmware.com ED25519 SHA256:3vku70losGmr1kmlRT52RuAG4e0IEDevQV+uOmCL3NI agent
debug1: Authentications that can continue: publickey,gssapi-keyex,gssapi-with-mic
debug1: Offering public key: dummy-key ED25519 SHA256:e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw explicit
debug1: Server accepts key: dummy-key ED25519 SHA256:e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw explicit
debug1: Authentication succeeded (publickey).
Authenticated to 52.91.70.219 ([52.91.70.219]:22).
debug1: channel 0: new [client-session]
debug1: Requesting no-more-sessions@openssh.com
debug1: Entering interactive session.
debug1: pledge: network
debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
debug1: Sending environment.
debug1: Sending env LC_CTYPE = UTF-8

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
11 package(s) needed for security, out of 34 available
Run "sudo yum update" to apply all updates.
-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
[ec2-user@ip-10-0-0-45 ~]$ echo YESSS
YESSS
[ec2-user@ip-10-0-0-45 ~]$ debug1: client_input_channel_req: channel 0 rtype exit-status reply 0
debug1: client_input_channel_req: channel 0 rtype eow@openssh.com reply 0
logout
debug1: channel 0: free: client-session, nchannels 1
Connection to 52.91.70.219 closed.
Transferred: sent 2776, received 3368 bytes, in 6.6 seconds
Bytes per second: sent 423.7, received 514.0
debug1: Exit status 0
trial1 $

trial1 $ terraform destroy
aws_key_pair.redis_ssh_key: Refreshing state... [id=redis-ssh-key20210925174953991200000001]
aws_vpc.redis_vpc: Refreshing state... [id=vpc-03d7951ba6c86ba72]
aws_route_table.redis_route_table: Refreshing state... [id=rtb-0f1908557cca58987]
aws_internet_gateway.redis_internet_gateway: Refreshing state... [id=igw-0f99d81bcb0643aa7]
aws_subnet.redis_subnet: Refreshing state... [id=subnet-0e332317735330792]
aws_security_group.redis_security_group: Refreshing state... [id=sg-0fd0bf4fde6011b74]
aws_security_group_rule.redis_security_group_egress: Refreshing state... [id=sgrule-218942937]
aws_security_group_rule.redis_security_group_ingress: Refreshing state... [id=sgrule-2658890409]
aws_route.redis_route_ipv4_internet_access: Refreshing state... [id=r-rtb-0f1908557cca589871080289494]
aws_route.redis_route_ipv6_internet_access: Refreshing state... [id=r-rtb-0f1908557cca589872750132062]
aws_route_table_association.redis_route_table_with_subnet: Refreshing state... [id=rtbassoc-0114c433f0861317d]
aws_instance.redis_server: Refreshing state... [id=i-0162661ba412ca2d4]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_key_pair.redis_ssh_key has been changed
  ~ resource "aws_key_pair" "redis_ssh_key" {
        id              = "redis-ssh-key20210925174953991200000001"
      + tags            = {}
        # (7 unchanged attributes hidden)
    }
  # aws_instance.redis_server has been changed
  ~ resource "aws_instance" "redis_server" {
        id                                   = "i-0162661ba412ca2d4"
        tags                                 = {
            "Name" = "redis-server"
        }
        # (28 unchanged attributes hidden)




      ~ root_block_device {
          + tags                  = {}
            # (8 unchanged attributes hidden)
        }
        # (3 unchanged blocks hidden)
    }
  # aws_security_group.redis_security_group has been changed
  ~ resource "aws_security_group" "redis_security_group" {
      ~ egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
        id                     = "sg-0fd0bf4fde6011b74"
      ~ ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Redis Traffic from the Internet"
              + from_port        = 22
              + ipv6_cidr_blocks = [
                  + "::/0",
                ]
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
        name                   = "allow_redis_traffic"
        tags                   = {
            "Name" = "allow-redis-traffic"
        }
        # (6 unchanged attributes hidden)
    }
  # aws_security_group_rule.redis_security_group_egress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_egress" {
        id                = "sgrule-218942937"
      + prefix_list_ids   = []
        # (8 unchanged attributes hidden)
    }
  # aws_route_table.redis_route_table has been changed
  ~ resource "aws_route_table" "redis_route_table" {
        id               = "rtb-0f1908557cca58987"
      ~ route            = [
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = ""
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = "igw-0f99d81bcb0643aa7"
              + instance_id                = ""
              + ipv6_cidr_block            = "::/0"
              + local_gateway_id           = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = "0.0.0.0/0"
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = "igw-0f99d81bcb0643aa7"
              + instance_id                = ""
              + ipv6_cidr_block            = ""
              + local_gateway_id           = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
        ]
        tags             = {
            "Name" = "redis-route-table"
        }
        # (5 unchanged attributes hidden)
    }
  # aws_security_group_rule.redis_security_group_ingress has been changed
  ~ resource "aws_security_group_rule" "redis_security_group_ingress" {
        id                = "sgrule-2658890409"
      + prefix_list_ids   = []
        # (9 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.redis_server will be destroyed
  - resource "aws_instance" "redis_server" {
      - ami                                  = "ami-029c64b3c205e6cce" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:469318448823:instance/i-0162661ba412ca2d4" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "us-east-1a" -> null
      - cpu_core_count                       = 2 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-0162661ba412ca2d4" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t4g.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - key_name                             = "redis-ssh-key20210925174953991200000001" -> null
      - monitoring                           = false -> null
      - primary_network_interface_id         = "eni-0b33d6d824daae649" -> null
      - private_dns                          = "ip-10-0-0-45.ec2.internal" -> null
      - private_ip                           = "10.0.0.45" -> null
      - public_ip                            = "52.91.70.219" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-0e332317735330792" -> null
      - tags                                 = {
          - "Name" = "redis-server"
        } -> null
      - tags_all                             = {
          - "Name" = "redis-server"
        } -> null
      - tenancy                              = "default" -> null
      - vpc_security_group_ids               = [
          - "sg-0fd0bf4fde6011b74",
        ] -> null

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/xvda" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-0aa67a61ab61ce692" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
        }
    }

  # aws_internet_gateway.redis_internet_gateway will be destroyed
  - resource "aws_internet_gateway" "redis_internet_gateway" {
      - arn      = "arn:aws:ec2:us-east-1:469318448823:internet-gateway/igw-0f99d81bcb0643aa7" -> null
      - id       = "igw-0f99d81bcb0643aa7" -> null
      - owner_id = "469318448823" -> null
      - tags     = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - tags_all = {
          - "Name" = "redis-internet-gateway"
        } -> null
      - vpc_id   = "vpc-03d7951ba6c86ba72" -> null
    }

  # aws_key_pair.redis_ssh_key will be destroyed
  - resource "aws_key_pair" "redis_ssh_key" {
      - arn             = "arn:aws:ec2:us-east-1:469318448823:key-pair/redis-ssh-key20210925174953991200000001" -> null
      - fingerprint     = "e0Q0MJQbEgD3Omap1nZ/OXZTs8HhcvanjW1+AvkGabw=" -> null
      - id              = "redis-ssh-key20210925174953991200000001" -> null
      - key_name        = "redis-ssh-key20210925174953991200000001" -> null
      - key_name_prefix = "redis-ssh-key" -> null
      - key_pair_id     = "key-020f279e6c4536a7a" -> null
      - public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com" -> null
      - tags            = {} -> null
      - tags_all        = {} -> null
    }

  # aws_route.redis_route_ipv4_internet_access will be destroyed
  - resource "aws_route" "redis_route_ipv4_internet_access" {
      - destination_cidr_block = "0.0.0.0/0" -> null
      - gateway_id             = "igw-0f99d81bcb0643aa7" -> null
      - id                     = "r-rtb-0f1908557cca589871080289494" -> null
      - origin                 = "CreateRoute" -> null
      - route_table_id         = "rtb-0f1908557cca58987" -> null
      - state                  = "active" -> null
    }

  # aws_route.redis_route_ipv6_internet_access will be destroyed
  - resource "aws_route" "redis_route_ipv6_internet_access" {
      - destination_ipv6_cidr_block = "::/0" -> null
      - gateway_id                  = "igw-0f99d81bcb0643aa7" -> null
      - id                          = "r-rtb-0f1908557cca589872750132062" -> null
      - origin                      = "CreateRoute" -> null
      - route_table_id              = "rtb-0f1908557cca58987" -> null
      - state                       = "active" -> null
    }

  # aws_route_table.redis_route_table will be destroyed
  - resource "aws_route_table" "redis_route_table" {
      - arn              = "arn:aws:ec2:us-east-1:469318448823:route-table/rtb-0f1908557cca58987" -> null
      - id               = "rtb-0f1908557cca58987" -> null
      - owner_id         = "469318448823" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - carrier_gateway_id         = ""
              - cidr_block                 = ""
              - destination_prefix_list_id = ""
              - egress_only_gateway_id     = ""
              - gateway_id                 = "igw-0f99d81bcb0643aa7"
              - instance_id                = ""
              - ipv6_cidr_block            = "::/0"
              - local_gateway_id           = ""
              - nat_gateway_id             = ""
              - network_interface_id       = ""
              - transit_gateway_id         = ""
              - vpc_endpoint_id            = ""
              - vpc_peering_connection_id  = ""
            },
          - {
              - carrier_gateway_id         = ""
              - cidr_block                 = "0.0.0.0/0"
              - destination_prefix_list_id = ""
              - egress_only_gateway_id     = ""
              - gateway_id                 = "igw-0f99d81bcb0643aa7"
              - instance_id                = ""
              - ipv6_cidr_block            = ""
              - local_gateway_id           = ""
              - nat_gateway_id             = ""
              - network_interface_id       = ""
              - transit_gateway_id         = ""
              - vpc_endpoint_id            = ""
              - vpc_peering_connection_id  = ""
            },
        ] -> null
      - tags             = {
          - "Name" = "redis-route-table"
        } -> null
      - tags_all         = {
          - "Name" = "redis-route-table"
        } -> null
      - vpc_id           = "vpc-03d7951ba6c86ba72" -> null
    }

  # aws_route_table_association.redis_route_table_with_subnet will be destroyed
  - resource "aws_route_table_association" "redis_route_table_with_subnet" {
      - id             = "rtbassoc-0114c433f0861317d" -> null
      - route_table_id = "rtb-0f1908557cca58987" -> null
      - subnet_id      = "subnet-0e332317735330792" -> null
    }

  # aws_security_group.redis_security_group will be destroyed
  - resource "aws_security_group" "redis_security_group" {
      - arn                    = "arn:aws:ec2:us-east-1:469318448823:security-group/sg-0fd0bf4fde6011b74" -> null
      - description            = "Allow Redis traffic" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = ""
              - from_port        = 0
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0fd0bf4fde6011b74" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Redis Traffic from the Internet"
              - from_port        = 22
              - ipv6_cidr_blocks = [
                  - "::/0",
                ]
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "allow_redis_traffic" -> null
      - owner_id               = "469318448823" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - tags_all               = {
          - "Name" = "allow-redis-traffic"
        } -> null
      - vpc_id                 = "vpc-03d7951ba6c86ba72" -> null
    }

  # aws_security_group_rule.redis_security_group_egress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_egress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - from_port         = 0 -> null
      - id                = "sgrule-218942937" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "-1" -> null
      - security_group_id = "sg-0fd0bf4fde6011b74" -> null
      - self              = false -> null
      - to_port           = 0 -> null
      - type              = "egress" -> null
    }

  # aws_security_group_rule.redis_security_group_ingress will be destroyed
  - resource "aws_security_group_rule" "redis_security_group_ingress" {
      - cidr_blocks       = [
          - "0.0.0.0/0",
        ] -> null
      - description       = "Redis Traffic from the Internet" -> null
      - from_port         = 22 -> null
      - id                = "sgrule-2658890409" -> null
      - ipv6_cidr_blocks  = [
          - "::/0",
        ] -> null
      - prefix_list_ids   = [] -> null
      - protocol          = "tcp" -> null
      - security_group_id = "sg-0fd0bf4fde6011b74" -> null
      - self              = false -> null
      - to_port           = 22 -> null
      - type              = "ingress" -> null
    }

  # aws_subnet.redis_subnet will be destroyed
  - resource "aws_subnet" "redis_subnet" {
      - arn                             = "arn:aws:ec2:us-east-1:469318448823:subnet/subnet-0e332317735330792" -> null
      - assign_ipv6_address_on_creation = false -> null
      - availability_zone               = "us-east-1a" -> null
      - availability_zone_id            = "use1-az2" -> null
      - cidr_block                      = "10.0.0.0/24" -> null
      - id                              = "subnet-0e332317735330792" -> null
      - map_customer_owned_ip_on_launch = false -> null
      - map_public_ip_on_launch         = false -> null
      - owner_id                        = "469318448823" -> null
      - tags                            = {
          - "Name" = "redis-subnet"
        } -> null
      - tags_all                        = {
          - "Name" = "redis-subnet"
        } -> null
      - vpc_id                          = "vpc-03d7951ba6c86ba72" -> null
    }

  # aws_vpc.redis_vpc will be destroyed
  - resource "aws_vpc" "redis_vpc" {
      - arn                              = "arn:aws:ec2:us-east-1:469318448823:vpc/vpc-03d7951ba6c86ba72" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.0.0.0/16" -> null
      - default_network_acl_id           = "acl-0266f4d9c2721ca21" -> null
      - default_route_table_id           = "rtb-0b675f95f8f6a5e81" -> null
      - default_security_group_id        = "sg-063c14c8f08b13a37" -> null
      - dhcp_options_id                  = "dopt-6fb3e10a" -> null
      - enable_classiclink               = false -> null
      - enable_classiclink_dns_support   = false -> null
      - enable_dns_hostnames             = false -> null
      - enable_dns_support               = true -> null
      - id                               = "vpc-03d7951ba6c86ba72" -> null
      - instance_tenancy                 = "default" -> null
      - main_route_table_id              = "rtb-0b675f95f8f6a5e81" -> null
      - owner_id                         = "469318448823" -> null
      - tags                             = {
          - "Name" = "redis-vpc"
        } -> null
      - tags_all                         = {
          - "Name" = "redis-vpc"
        } -> null
    }

Plan: 0 to add, 0 to change, 12 to destroy.

Changes to Outputs:
  - ip = "52.91.70.219" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_route_table_association.redis_route_table_with_subnet: Destroying... [id=rtbassoc-0114c433f0861317d]
aws_security_group_rule.redis_security_group_egress: Destroying... [id=sgrule-218942937]
aws_route.redis_route_ipv4_internet_access: Destroying... [id=r-rtb-0f1908557cca589871080289494]
aws_security_group_rule.redis_security_group_ingress: Destroying... [id=sgrule-2658890409]
aws_route.redis_route_ipv6_internet_access: Destroying... [id=r-rtb-0f1908557cca589872750132062]
aws_instance.redis_server: Destroying... [id=i-0162661ba412ca2d4]
aws_route_table_association.redis_route_table_with_subnet: Destruction complete after 2s
aws_security_group_rule.redis_security_group_egress: Destruction complete after 2s
aws_route.redis_route_ipv4_internet_access: Destruction complete after 3s
aws_route.redis_route_ipv6_internet_access: Destruction complete after 3s
aws_internet_gateway.redis_internet_gateway: Destroying... [id=igw-0f99d81bcb0643aa7]
aws_route_table.redis_route_table: Destroying... [id=rtb-0f1908557cca58987]
aws_security_group_rule.redis_security_group_ingress: Destruction complete after 4s
aws_route_table.redis_route_table: Destruction complete after 3s
aws_instance.redis_server: Still destroying... [id=i-0162661ba412ca2d4, 10s elapsed]
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-0f99d81bcb0643aa7, 10s elapsed]
aws_instance.redis_server: Still destroying... [id=i-0162661ba412ca2d4, 20s elapsed]
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-0f99d81bcb0643aa7, 20s elapsed]
aws_instance.redis_server: Still destroying... [id=i-0162661ba412ca2d4, 30s elapsed]
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-0f99d81bcb0643aa7, 30s elapsed]
aws_instance.redis_server: Still destroying... [id=i-0162661ba412ca2d4, 40s elapsed]
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-0f99d81bcb0643aa7, 40s elapsed]
aws_instance.redis_server: Still destroying... [id=i-0162661ba412ca2d4, 50s elapsed]
aws_internet_gateway.redis_internet_gateway: Still destroying... [id=igw-0f99d81bcb0643aa7, 50s elapsed]
aws_internet_gateway.redis_internet_gateway: Destruction complete after 51s
aws_instance.redis_server: Destruction complete after 58s
aws_key_pair.redis_ssh_key: Destroying... [id=redis-ssh-key20210925174953991200000001]
aws_subnet.redis_subnet: Destroying... [id=subnet-0e332317735330792]
aws_security_group.redis_security_group: Destroying... [id=sg-0fd0bf4fde6011b74]
aws_key_pair.redis_ssh_key: Destruction complete after 1s
aws_security_group.redis_security_group: Destruction complete after 2s
aws_subnet.redis_subnet: Destruction complete after 2s
aws_vpc.redis_vpc: Destroying... [id=vpc-03d7951ba6c86ba72]
aws_vpc.redis_vpc: Destruction complete after 2s

Destroy complete! Resources: 12 destroyed.
trial1 $

```

TODO

- Checkout about Amazon Machine Images

---

Checking out systemctl unit file for running Redis

https://duckduckgo.com/?t=ffab&q=systemctl+unit+for+redis&ia=web

https://gist.github.com/mkocikowski/aeca878d58d313e902bb

```
[Unit]
Description=Redis
After=syslog.target

[Service]
ExecStart=/bin/redis-server /etc/redis/redis.conf
RestartSec=5s
Restart=on-success

[Install]
WantedBy=multi-user.target
```

```bash
[root@ip-10-0-0-67 ec2-user]# systemctl status redis
● redis.service - Redis
   Loaded: loaded (/etc/systemd/system/redis.service; disabled; vendor preset: disabled)
  Drop-In: /etc/systemd/system/redis.service.d
           └─limit.conf
   Active: failed (Result: exit-code) since Wed 2021-10-06 03:03:57 UTC; 3min 34s ago
  Process: 1678 ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf (code=exited, status=203/EXEC)
 Main PID: 1678 (code=exited, status=203/EXEC)

Oct 06 03:03:57 ip-10-0-0-67.ec2.internal systemd[1]: Started Redis.
Oct 06 03:03:57 ip-10-0-0-67.ec2.internal systemd[1]: redis.service: main process exited, code=exited, status=...EXEC
Oct 06 03:03:57 ip-10-0-0-67.ec2.internal systemd[1]: Unit redis.service entered failed state.
Oct 06 03:03:57 ip-10-0-0-67.ec2.internal systemd[1]: redis.service failed.
Warning: redis.service changed on disk. Run 'systemctl daemon-reload' to reload units.
Hint: Some lines were ellipsized, use -l to show in full.
[root@ip-10-0-0-67 ec2-user]# systemctl start redis
Warning: redis.service changed on disk. Run 'systemctl daemon-reload' to reload units.
[root@ip-10-0-0-67 ec2-user]# systemctl daemon-relod
Unknown operation 'daemon-relod'.
[root@ip-10-0-0-67 ec2-user]# systemctl daemon-reload
[root@ip-10-0-0-67 ec2-user]# systemctl start redis
[root@ip-10-0-0-67 ec2-user]# systemctl status redis
● redis.service - Redis
   Loaded: loaded (/etc/systemd/system/redis.service; disabled; vendor preset: disabled)
  Drop-In: /etc/systemd/system/redis.service.d
           └─limit.conf
   Active: active (running) since Wed 2021-10-06 03:07:52 UTC; 4s ago
 Main PID: 1764 (redis-server)
   CGroup: /system.slice/redis.service
           └─1764 /bin/redis-server 127.0.0.1:6379

Oct 06 03:07:52 ip-10-0-0-67.ec2.internal systemd[1]: Started Redis.
[root@ip-10-0-0-67 ec2-user]#
```

```bash
[root@ip-10-0-0-67 ec2-user]# redis-cli
127.0.0.1:6379> keys *
(empty array)
127.0.0.1:6379>
[root@ip-10-0-0-67 ec2-user]# redis-cli dbsize
(integer) 0
[root@ip-10-0-0-67 ec2-user]# redis-cli info cluster
# Cluster
cluster_enabled:0
[root@ip-10-0-0-67 ec2-user]# redis-cli info replication
# Replication
role:master
connected_slaves:0
master_failover_state:no-failover
master_replid:a79b6916035bd4f3edb1a732ca5521503bc3a58d
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
[root@ip-10-0-0-67 ec2-user]#
```
