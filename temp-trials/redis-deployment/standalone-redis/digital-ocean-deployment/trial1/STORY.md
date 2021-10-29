
Goal - Create a virtual machine image for Digital Ocean that can deploy a Redis server when a droplet is created using that virtual machine image along with some user data to inject configuration like port, password etc

[TODO]
- Create a packer file to automate the creation of a Digital Ocean VM image
- Check where and how the VM images are stored in Digital Ocean and the cost of the storage and if it is publicly available to all or a private registry or if both are available
- Check how to pass user data and how to use it to configure Redis exactly once for the first time when the VM is created / booted. Should we use cloud init or bash script? Maybe bash?
- Use service unit file to run the Redis server
- For the Digital Ocean deployment - ensure that there are appropriate security measures taken - firewall for allowing particular ports, etc

---

https://www.packer.io/docs/builders/digitalocean

[Level-2] [TODO]
- Packer file automation for VM image
    - Use a Linux OS image as base image, maybe Ubuntu
    - Create a bash script for Redis installation
        - The script can install using `apt` maybe. I think it comes with service unit along with it
        - Preferably install the latest Redis - v6.2.6


https://www.packer.io/docs/builders/digitalocean#api_token

```bash
trial1 $ packer init .
Installed plugin github.com/hashicorp/digitalocean v1.0.1 in "/Users/karuppiahn/.config/packer/plugins/github.com/hashicorp/digitalocean/packer-plugin-digitalocean_v1.0.1_x5.0_darwin_amd64"
trial1 $ gst
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   STORY.md
	new file:   redis-server.pkr.hcl

trial1 $ ls
STORY.md		redis-server.pkr.hcl
trial1 $ ls -al
total 16
drwxr-xr-x  4 karuppiahn  staff   128 Oct 29 06:54 .
drwxr-xr-x  3 karuppiahn  staff    96 Oct 29 06:54 ..
-rw-r--r--  1 karuppiahn  staff  1292 Oct 29 07:05 STORY.md
-rw-r--r--  1 karuppiahn  staff   370 Oct 29 07:36 redis-server.pkr.hcl
trial1 $ packer fmt .
redis-server.pkr.hcl
trial1 $ packer validate .
Error: 1 error(s) occurred:

* An ssh_username must be specified
  Note: some builders used to default ssh_username to "root".

  on redis-server.pkr.hcl line 10:
  (source code not available)


trial1 $ packer validate .
The configuration is valid.
trial1 $ packer fmt .
redis-server.pkr.hcl
trial1 $ packer build 
Usage: packer build [options] TEMPLATE

  Will execute multiple builds in parallel as defined in the template.
  The various artifacts created by the template will be outputted.

Options:

  -color=false                  Disable color output. (Default: color)
  -debug                        Debug mode enabled for builds.
  -except=foo,bar,baz           Run all builds and post-processors other than these.
  -only=foo,bar,baz             Build only the specified builds.
  -force                        Force a build to continue if artifacts exist, deletes existing artifacts.
  -machine-readable             Produce machine-readable output.
  -on-error=[cleanup|abort|ask|run-cleanup-provisioner] If the build fails do: clean up (default), abort, ask, or run-cleanup-provisioner.
  -parallel-builds=1            Number of builds to run in parallel. 1 disables parallelization. 0 means no limit (Default: 0)
  -timestamp-ui                 Enable prefixing of each ui output with an RFC3339 timestamp.
  -var 'key=value'              Variable for templates, can be used multiple times.
  -var-file=path                JSON or HCL2 file containing user variables.
trial1 $ 
trial1 $ packer build 
STORY.md              redis-server.pkr.hcl  
trial1 $ packer build redis-server.pkr.hcl 
redis.digitalocean.redis: output will be in this color.

==> redis.digitalocean.redis: Creating temporary RSA SSH key for instance...
==> redis.digitalocean.redis: Importing SSH public key...
==> redis.digitalocean.redis: Creating droplet...
==> redis.digitalocean.redis: Error creating droplet: POST https://api.digitalocean.com/v2/droplets: 403 (request "6154682a-51c0-41ec-b068-597ddc1a7b54") You do not have access for the attempted action.
==> redis.digitalocean.redis: Deleting temporary ssh key...
Build 'redis.digitalocean.redis' errored after 4 seconds 573 milliseconds: Error creating droplet: POST https://api.digitalocean.com/v2/droplets: 403 (request "6154682a-51c0-41ec-b068-597ddc1a7b54") You do not have access for the attempted action.

==> Wait completed after 4 seconds 574 milliseconds

==> Some builds didn't complete successfully and had errors:
--> redis.digitalocean.redis: Error creating droplet: POST https://api.digitalocean.com/v2/droplets: 403 (request "6154682a-51c0-41ec-b068-597ddc1a7b54") You do not have access for the attempted action.

==> Builds finished but no artifacts were created.
```

```bash
trial1 $ packer build redis-server.pkr.hcl 
redis.digitalocean.redis: output will be in this color.

==> redis.digitalocean.redis: Creating temporary RSA SSH key for instance...
==> redis.digitalocean.redis: Importing SSH public key...
==> redis.digitalocean.redis: Creating droplet...
==> redis.digitalocean.redis: Waiting for droplet to become active...
==> redis.digitalocean.redis: Using SSH communicator to connect: 159.203.85.66
==> redis.digitalocean.redis: Waiting for SSH to become available...
==> redis.digitalocean.redis: Connected to SSH!
==> redis.digitalocean.redis: Gracefully shutting down droplet...
==> redis.digitalocean.redis: Creating snapshot: redis-server
==> redis.digitalocean.redis: Waiting for snapshot to complete...
==> redis.digitalocean.redis: Destroying droplet...
==> redis.digitalocean.redis: Deleting temporary ssh key...
Build 'redis.digitalocean.redis' finished after 2 minutes 38 seconds.

==> Wait completed after 2 minutes 38 seconds

==> Builds finished. The artifacts of successful builds are:
--> redis.digitalocean.redis: A snapshot was created: 'redis-server' (ID: 94611958) in regions 'nyc3'
trial1 $ 
```

That took about 1.52 GB space

Cost is based on space / storage used. Pricing - $0.05/GiB/month

Note - I was able to add the snapshot to other regions very easily with the click of a button. So, we don't have to create the same image again and again for each region. We can create it in one region and make it available in multiple regions and I think the cost will still be the same - based on the amount of space used which will just be 1.52 GB for example even if available in one region or multiple regions. But I gotta confirm this with support team maybe. But surely I'm not gonna create multiple images with different images, all with same content but just being available in different regions, as that doesn't make sense here.

I could use Digital Ocean API to make the image that's created once to be available in multiple regions if it's required by the user

And I don't think VM images can be made publicly available. As in, if I create the image / snapshot, I noticed that I can transfer the ownership to someone else, that's it

But I did notice that one can use custom images - import from URL etc. Gotta check how that happens! Maybe I can create the images before hand and provide it to the user easily by just importing it into their account, if they prefer that, or they can create it on demand at that point too, using something like Packer, it's just that it would take a bit more time but depending on user trust, they can choose to do whatever they want. Also, if it's a managed DBaaS(SaaS) service then there won't be a user cloud, just one cloud or many clouds, all controlled by the DBaaS company and billed to their cloud account, users just have to pay the DBaaS then, no such issues about storing VM images

https://docs.digitalocean.com/products/images/custom-images/

https://docs.openstack.org/image-guide/obtain-images.html

https://www.digitalocean.com/blog/custom-images/?

https://docs.digitalocean.com/reference/api/api-reference/#tag/Images


