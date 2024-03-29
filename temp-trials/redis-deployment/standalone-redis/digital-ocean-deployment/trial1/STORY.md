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

---

I was checking out how Digital Ocean managed Redis is deployed, it was pretty interesting! The UI/UX etc :D They take users on a journey and help them connect to their Redis DB

First choose Redis version. They had v6 alone, and then asked region for deployment, and then asked the size of the Redis

The deployment took a few moments, while they were showing how to get started and gave details like - connection details - just a list of things - username, password, host, port to form the username:password@host:port format which is generic for any network service especially DBs, in DBs a database name is also included at the end, protocol://username:password@host:port/database-name . They also showed connection string format with rediss protocol, I think it's Redis Secured protocol, with credentials and host connection details. They also showed how to connect using Redis CLI, but not `redis-cli` CLI, instead of `redli` which I mistook to be a typo for a moment, and smiled, silly me.

redli is a third party CLI tool https://github.com/IBM-Cloud/redli

```
username = default
password = tcNP2VtiBcCyYV5C
host = db-redis-blr1-79526-do-user-2265104-0.b.db.ondigitalocean.com
port = 25061
```

```bash
redli --tls -h db-redis-blr1-79526-do-user-2265104-0.b.db.ondigitalocean.com -a tcNP2VtiBcCyYV5C -p 25061
```

```bash
go install -v github.com/IBM-Cloud/redli@latest
```

https://www.digitalocean.com/community/tutorials/how-to-encrypt-traffic-to-redis-with-stunnel-on-ubuntu-16-04

https://docs.digitalocean.com/products/databases/redis/how-to/connect/

I also noticed how Digital Ocean provides an experience for the Redis

They make it easy to increase the size of the instance of the Redis, make it secure by securing the network connectivity by asking if you want to restrict connections to just - from your IP address mentioning that it's open to all initially

They also had alert policies, and it asked for DB cluster name and then the kind of alert - it had disk utilization and a few other kind of alerts!

Also, as part of the installation, they also asked the kind of maxmemory eviction policy the user wants, and provided the options and also explained those options in a very simple manner! It was pretty cool! :D There was no option to "increase instance size automatically when memory is full" ;) I guess that's manual if it's needed ;)

I also saw that one can change the window of updates and that during updates, the DNS will remain the same so that applications can talk to the Redis but that underlying IP address will change. Not sure how they handle that! On client side, I think it's hard because some clients cache the IP address resolved from the domain and maintain that state and keep doing it until the Redis does not work and it won't retry to resolve the DNS again. Some weird behavior that I have heard of before, and the apps I have seen, it does not enforce resolving the DNS again when current (possibly cached) IP address resolved from the DNS does not work and avoiding any sort of state as much as possible at the app level. Ideally I would expect IP address to not change, which would help a lot of developers I think, who don't have to face any possible issues due to IP caching!

It said that there won't be any downtime during maintenance updates / upgrades and that there won't be any downtime while increasing the size of the Redis instances from small to big etc

I also saw logs in the Digital Ocean dashboard. It showed the Redis server logs, which showed that's being managed by the systemd and I was like "ah, wow, nice!" as I was thinking to use the same thing for automatic configuration and restart / start of service when machine boots

Digital Ocean also had insights tab which had alerts stuff and also the graphs to show CPU and Memory usage graphs

---

Trying to deploy a Redis server on Digital Ocean Droplet

- Created a Droplet of size 1GB RAM, 1vCPU, 25 GB Disk (boot disk) + 10 GB external volume (block storage)

  - Basic Droplet, in Shared CPU plan
  - Regular Intel with SSD disk
  - Chose Ubuntu 20.04 LTS (x64) OS version
  - Provided ed25519 4096 bits SSH key
  - Created it in Bangalore region
  - Tags - demo, redis

- SSHed into the machine using root user and the SSH key

/etc/systemd/system/redis.service

---

https://github.com/redis/redis

https://github.com/jemalloc/jemalloc/

https://github.com/jemalloc/jemalloc/blob/dev/INSTALL.md

https://github.com/jemalloc/jemalloc/releases/tag/5.2.1

---

https://duckduckgo.com/?t=ffab&q=install+redis+6+on+ubuntu+20.04&ia=web

https://bitlaunch.io/blog/installing-redis-server-on-ubuntu-20-04-lts/

https://www.linode.com/docs/guides/install-redis-ubuntu/

https://www.linode.com/docs/guides/install-redis-ubuntu/#install-redis-from-a-package

https://www.linode.com/docs/guides/install-redis-ubuntu/#install-redis-from-a-downloaded-file

https://otodiginet.com/database/how-to-install-and-configure-redis-6-0-on-ubuntu-20-04-lts/

https://phoenixnap.com/kb/install-redis-on-ubuntu-20-04

https://askubuntu.com/questions/1244058/how-to-install-redis-server-6-0-1-in-ubuntu-20-04

https://github.com/redis/redis/tree/unstable/deps

https://duckduckgo.com/?t=ffab&q=ubuntu+readline&ia=web

---

```bash
root@ubuntu-s-1vcpu-1gb-blr1-01:~# wget https://download.redis.io/releases/redis-6.2.6.tar.gz
--2021-10-30 05:04:42--  https://download.redis.io/releases/redis-6.2.6.tar.gz
Resolving download.redis.io (download.redis.io)... 45.60.125.1
Connecting to download.redis.io (download.redis.io)|45.60.125.1|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2476542 (2.4M) [application/octet-stream]
Saving to: ‘redis-6.2.6.tar.gz’

redis-6.2.6.tar.gz              100%[=====================================================>]   2.36M  13.2MB/s    in 0.2s

2021-10-30 05:04:42 (13.2 MB/s) - ‘redis-6.2.6.tar.gz’ saved [2476542/2476542]

root@ubuntu-s-1vcpu-1gb-blr1-01:~# tar
tar: You must specify one of the '-Acdtrux', '--delete' or '--test-label' options
Try 'tar --help' or 'tar --usage' for more information.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# tar -xvzf redis-6.2.6.tar.gz
redis-6.2.6/
redis-6.2.6/.github/
redis-6.2.6/.github/ISSUE_TEMPLATE/
redis-6.2.6/.github/ISSUE_TEMPLATE/bug_report.md
redis-6.2.6/.github/ISSUE_TEMPLATE/crash_report.md
redis-6.2.6/.github/ISSUE_TEMPLATE/feature_request.md
redis-6.2.6/.github/ISSUE_TEMPLATE/other_stuff.md
redis-6.2.6/.github/ISSUE_TEMPLATE/question.md
redis-6.2.6/.github/workflows/
redis-6.2.6/.github/workflows/ci.yml
redis-6.2.6/.github/workflows/daily.yml
redis-6.2.6/.gitignore
redis-6.2.6/00-RELEASENOTES
redis-6.2.6/BUGS
redis-6.2.6/CONDUCT
redis-6.2.6/CONTRIBUTING
redis-6.2.6/COPYING
redis-6.2.6/INSTALL
redis-6.2.6/MANIFESTO
redis-6.2.6/Makefile
redis-6.2.6/README.md
redis-6.2.6/TLS.md
redis-6.2.6/deps/
redis-6.2.6/deps/Makefile
redis-6.2.6/deps/README.md
redis-6.2.6/deps/hdr_histogram/
redis-6.2.6/deps/hdr_histogram/COPYING.txt
redis-6.2.6/deps/hdr_histogram/LICENSE.txt
redis-6.2.6/deps/hdr_histogram/Makefile
redis-6.2.6/deps/hdr_histogram/README.md
redis-6.2.6/deps/hdr_histogram/hdr_atomic.h
redis-6.2.6/deps/hdr_histogram/hdr_histogram.c
redis-6.2.6/deps/hdr_histogram/hdr_histogram.h
redis-6.2.6/deps/hiredis/
redis-6.2.6/deps/hiredis/.gitignore
redis-6.2.6/deps/hiredis/.travis.yml
redis-6.2.6/deps/hiredis/CHANGELOG.md
redis-6.2.6/deps/hiredis/CMakeLists.txt
redis-6.2.6/deps/hiredis/COPYING
redis-6.2.6/deps/hiredis/Makefile
redis-6.2.6/deps/hiredis/README.md
redis-6.2.6/deps/hiredis/adapters/
redis-6.2.6/deps/hiredis/adapters/ae.h
redis-6.2.6/deps/hiredis/adapters/glib.h
redis-6.2.6/deps/hiredis/adapters/ivykis.h
redis-6.2.6/deps/hiredis/adapters/libev.h
redis-6.2.6/deps/hiredis/adapters/libevent.h
redis-6.2.6/deps/hiredis/adapters/libuv.h
redis-6.2.6/deps/hiredis/adapters/macosx.h
redis-6.2.6/deps/hiredis/adapters/qt.h
redis-6.2.6/deps/hiredis/alloc.c
redis-6.2.6/deps/hiredis/alloc.h
redis-6.2.6/deps/hiredis/appveyor.yml
redis-6.2.6/deps/hiredis/async.c
redis-6.2.6/deps/hiredis/async.h
redis-6.2.6/deps/hiredis/async_private.h
redis-6.2.6/deps/hiredis/dict.c
redis-6.2.6/deps/hiredis/dict.h
redis-6.2.6/deps/hiredis/examples/
redis-6.2.6/deps/hiredis/examples/CMakeLists.txt
redis-6.2.6/deps/hiredis/examples/example-ae.c
redis-6.2.6/deps/hiredis/examples/example-glib.c
redis-6.2.6/deps/hiredis/examples/example-ivykis.c
redis-6.2.6/deps/hiredis/examples/example-libev.c
redis-6.2.6/deps/hiredis/examples/example-libevent-ssl.c
redis-6.2.6/deps/hiredis/examples/example-libevent.c
redis-6.2.6/deps/hiredis/examples/example-libuv.c
redis-6.2.6/deps/hiredis/examples/example-macosx.c
redis-6.2.6/deps/hiredis/examples/example-push.c
redis-6.2.6/deps/hiredis/examples/example-qt.cpp
redis-6.2.6/deps/hiredis/examples/example-qt.h
redis-6.2.6/deps/hiredis/examples/example-ssl.c
redis-6.2.6/deps/hiredis/examples/example.c
redis-6.2.6/deps/hiredis/fmacros.h
redis-6.2.6/deps/hiredis/hiredis-config.cmake.in
redis-6.2.6/deps/hiredis/hiredis.c
redis-6.2.6/deps/hiredis/hiredis.h
redis-6.2.6/deps/hiredis/hiredis.pc.in
redis-6.2.6/deps/hiredis/hiredis_ssl-config.cmake.in
redis-6.2.6/deps/hiredis/hiredis_ssl.h
redis-6.2.6/deps/hiredis/hiredis_ssl.pc.in
redis-6.2.6/deps/hiredis/net.c
redis-6.2.6/deps/hiredis/net.h
redis-6.2.6/deps/hiredis/read.c
redis-6.2.6/deps/hiredis/read.h
redis-6.2.6/deps/hiredis/sds.c
redis-6.2.6/deps/hiredis/sds.h
redis-6.2.6/deps/hiredis/sdsalloc.h
redis-6.2.6/deps/hiredis/sdscompat.h
redis-6.2.6/deps/hiredis/sockcompat.c
redis-6.2.6/deps/hiredis/sockcompat.h
redis-6.2.6/deps/hiredis/ssl.c
redis-6.2.6/deps/hiredis/test.c
redis-6.2.6/deps/hiredis/test.sh
redis-6.2.6/deps/hiredis/win32.h
redis-6.2.6/deps/jemalloc/
redis-6.2.6/deps/jemalloc/.appveyor.yml
redis-6.2.6/deps/jemalloc/.autom4te.cfg
redis-6.2.6/deps/jemalloc/.gitattributes
redis-6.2.6/deps/jemalloc/.gitignore
redis-6.2.6/deps/jemalloc/.travis.yml
redis-6.2.6/deps/jemalloc/COPYING
redis-6.2.6/deps/jemalloc/ChangeLog
redis-6.2.6/deps/jemalloc/INSTALL.md
redis-6.2.6/deps/jemalloc/Makefile.in
redis-6.2.6/deps/jemalloc/README
redis-6.2.6/deps/jemalloc/TUNING.md
redis-6.2.6/deps/jemalloc/VERSION
redis-6.2.6/deps/jemalloc/autogen.sh
redis-6.2.6/deps/jemalloc/bin/
redis-6.2.6/deps/jemalloc/bin/jemalloc-config.in
redis-6.2.6/deps/jemalloc/bin/jemalloc.sh.in
redis-6.2.6/deps/jemalloc/bin/jeprof.in
redis-6.2.6/deps/jemalloc/build-aux/
redis-6.2.6/deps/jemalloc/build-aux/config.guess
redis-6.2.6/deps/jemalloc/build-aux/config.sub
redis-6.2.6/deps/jemalloc/build-aux/install-sh
redis-6.2.6/deps/jemalloc/config.stamp.in
redis-6.2.6/deps/jemalloc/configure
redis-6.2.6/deps/jemalloc/configure.ac
redis-6.2.6/deps/jemalloc/doc/
redis-6.2.6/deps/jemalloc/doc/html.xsl.in
redis-6.2.6/deps/jemalloc/doc/jemalloc.xml.in
redis-6.2.6/deps/jemalloc/doc/manpages.xsl.in
redis-6.2.6/deps/jemalloc/doc/stylesheet.xsl
redis-6.2.6/deps/jemalloc/include/
redis-6.2.6/deps/jemalloc/include/jemalloc/
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/arena_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/arena_inlines_a.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/arena_inlines_b.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/arena_stats.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/arena_structs_a.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/arena_structs_b.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/arena_types.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/assert.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/atomic.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/atomic_c11.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/atomic_gcc_atomic.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/atomic_gcc_sync.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/atomic_msvc.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/background_thread_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/background_thread_inlines.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/background_thread_structs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/base_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/base_inlines.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/base_structs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/base_types.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/bin.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/bin_stats.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/bit_util.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/bitmap.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/cache_bin.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/ckh.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/ctl.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/div.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/emitter.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/extent_dss.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/extent_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/extent_inlines.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/extent_mmap.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/extent_structs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/extent_types.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/hash.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/hooks.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_decls.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_defs.h.in
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_includes.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_inlines_a.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_inlines_b.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_inlines_c.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_macros.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_internal_types.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/jemalloc_preamble.h.in
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/large_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/log.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/malloc_io.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/mutex.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/mutex_pool.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/mutex_prof.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/nstime.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/pages.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/ph.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/private_namespace.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/private_symbols.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/prng.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/prof_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/prof_inlines_a.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/prof_inlines_b.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/prof_structs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/prof_types.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/public_namespace.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/public_unnamespace.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/ql.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/qr.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/rb.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/rtree.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/rtree_tsd.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/size_classes.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/smoothstep.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/smoothstep.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/spin.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/stats.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/sz.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tcache_externs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tcache_inlines.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tcache_structs.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tcache_types.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/ticker.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tsd.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tsd_generic.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tsd_malloc_thread_cleanup.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tsd_tls.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tsd_types.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/tsd_win.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/util.h
redis-6.2.6/deps/jemalloc/include/jemalloc/internal/witness.h
redis-6.2.6/deps/jemalloc/include/jemalloc/jemalloc.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/jemalloc_defs.h.in
redis-6.2.6/deps/jemalloc/include/jemalloc/jemalloc_macros.h.in
redis-6.2.6/deps/jemalloc/include/jemalloc/jemalloc_mangle.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/jemalloc_protos.h.in
redis-6.2.6/deps/jemalloc/include/jemalloc/jemalloc_rename.sh
redis-6.2.6/deps/jemalloc/include/jemalloc/jemalloc_typedefs.h.in
redis-6.2.6/deps/jemalloc/include/msvc_compat/
redis-6.2.6/deps/jemalloc/include/msvc_compat/C99/
redis-6.2.6/deps/jemalloc/include/msvc_compat/C99/stdbool.h
redis-6.2.6/deps/jemalloc/include/msvc_compat/C99/stdint.h
redis-6.2.6/deps/jemalloc/include/msvc_compat/strings.h
redis-6.2.6/deps/jemalloc/include/msvc_compat/windows_extra.h
redis-6.2.6/deps/jemalloc/jemalloc.pc.in
redis-6.2.6/deps/jemalloc/m4/
redis-6.2.6/deps/jemalloc/m4/ax_cxx_compile_stdcxx.m4
redis-6.2.6/deps/jemalloc/msvc/
redis-6.2.6/deps/jemalloc/msvc/ReadMe.txt
redis-6.2.6/deps/jemalloc/msvc/jemalloc_vc2015.sln
redis-6.2.6/deps/jemalloc/msvc/jemalloc_vc2017.sln
redis-6.2.6/deps/jemalloc/msvc/projects/
redis-6.2.6/deps/jemalloc/msvc/projects/vc2015/
redis-6.2.6/deps/jemalloc/msvc/projects/vc2015/jemalloc/
redis-6.2.6/deps/jemalloc/msvc/projects/vc2015/jemalloc/jemalloc.vcxproj
redis-6.2.6/deps/jemalloc/msvc/projects/vc2015/jemalloc/jemalloc.vcxproj.filters
redis-6.2.6/deps/jemalloc/msvc/projects/vc2015/test_threads/
redis-6.2.6/deps/jemalloc/msvc/projects/vc2015/test_threads/test_threads.vcxproj
redis-6.2.6/deps/jemalloc/msvc/projects/vc2015/test_threads/test_threads.vcxproj.filters
redis-6.2.6/deps/jemalloc/msvc/projects/vc2017/
redis-6.2.6/deps/jemalloc/msvc/projects/vc2017/jemalloc/
redis-6.2.6/deps/jemalloc/msvc/projects/vc2017/jemalloc/jemalloc.vcxproj
redis-6.2.6/deps/jemalloc/msvc/projects/vc2017/jemalloc/jemalloc.vcxproj.filters
redis-6.2.6/deps/jemalloc/msvc/projects/vc2017/test_threads/
redis-6.2.6/deps/jemalloc/msvc/projects/vc2017/test_threads/test_threads.vcxproj
redis-6.2.6/deps/jemalloc/msvc/projects/vc2017/test_threads/test_threads.vcxproj.filters
redis-6.2.6/deps/jemalloc/msvc/test_threads/
redis-6.2.6/deps/jemalloc/msvc/test_threads/test_threads.cpp
redis-6.2.6/deps/jemalloc/msvc/test_threads/test_threads.h
redis-6.2.6/deps/jemalloc/msvc/test_threads/test_threads_main.cpp
redis-6.2.6/deps/jemalloc/run_tests.sh
redis-6.2.6/deps/jemalloc/scripts/
redis-6.2.6/deps/jemalloc/scripts/gen_run_tests.py
redis-6.2.6/deps/jemalloc/scripts/gen_travis.py
redis-6.2.6/deps/jemalloc/src/
redis-6.2.6/deps/jemalloc/src/arena.c
redis-6.2.6/deps/jemalloc/src/background_thread.c
redis-6.2.6/deps/jemalloc/src/base.c
redis-6.2.6/deps/jemalloc/src/bin.c
redis-6.2.6/deps/jemalloc/src/bitmap.c
redis-6.2.6/deps/jemalloc/src/ckh.c
redis-6.2.6/deps/jemalloc/src/ctl.c
redis-6.2.6/deps/jemalloc/src/div.c
redis-6.2.6/deps/jemalloc/src/extent.c
redis-6.2.6/deps/jemalloc/src/extent_dss.c
redis-6.2.6/deps/jemalloc/src/extent_mmap.c
redis-6.2.6/deps/jemalloc/src/hash.c
redis-6.2.6/deps/jemalloc/src/hooks.c
redis-6.2.6/deps/jemalloc/src/jemalloc.c
redis-6.2.6/deps/jemalloc/src/jemalloc_cpp.cpp
redis-6.2.6/deps/jemalloc/src/large.c
redis-6.2.6/deps/jemalloc/src/log.c
redis-6.2.6/deps/jemalloc/src/malloc_io.c
redis-6.2.6/deps/jemalloc/src/mutex.c
redis-6.2.6/deps/jemalloc/src/mutex_pool.c
redis-6.2.6/deps/jemalloc/src/nstime.c
redis-6.2.6/deps/jemalloc/src/pages.c
redis-6.2.6/deps/jemalloc/src/prng.c
redis-6.2.6/deps/jemalloc/src/prof.c
redis-6.2.6/deps/jemalloc/src/rtree.c
redis-6.2.6/deps/jemalloc/src/stats.c
redis-6.2.6/deps/jemalloc/src/sz.c
redis-6.2.6/deps/jemalloc/src/tcache.c
redis-6.2.6/deps/jemalloc/src/ticker.c
redis-6.2.6/deps/jemalloc/src/tsd.c
redis-6.2.6/deps/jemalloc/src/witness.c
redis-6.2.6/deps/jemalloc/src/zone.c
redis-6.2.6/deps/jemalloc/test/
redis-6.2.6/deps/jemalloc/test/include/
redis-6.2.6/deps/jemalloc/test/include/test/
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-alti.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params11213.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params1279.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params132049.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params19937.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params216091.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params2281.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params4253.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params44497.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params607.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-params86243.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT-sse2.h
redis-6.2.6/deps/jemalloc/test/include/test/SFMT.h
redis-6.2.6/deps/jemalloc/test/include/test/btalloc.h
redis-6.2.6/deps/jemalloc/test/include/test/extent_hooks.h
redis-6.2.6/deps/jemalloc/test/include/test/jemalloc_test.h.in
redis-6.2.6/deps/jemalloc/test/include/test/jemalloc_test_defs.h.in
redis-6.2.6/deps/jemalloc/test/include/test/math.h
redis-6.2.6/deps/jemalloc/test/include/test/mq.h
redis-6.2.6/deps/jemalloc/test/include/test/mtx.h
redis-6.2.6/deps/jemalloc/test/include/test/test.h
redis-6.2.6/deps/jemalloc/test/include/test/thd.h
redis-6.2.6/deps/jemalloc/test/include/test/timer.h
redis-6.2.6/deps/jemalloc/test/integration/
redis-6.2.6/deps/jemalloc/test/integration/MALLOCX_ARENA.c
redis-6.2.6/deps/jemalloc/test/integration/aligned_alloc.c
redis-6.2.6/deps/jemalloc/test/integration/allocated.c
redis-6.2.6/deps/jemalloc/test/integration/cpp/
redis-6.2.6/deps/jemalloc/test/integration/cpp/basic.cpp
redis-6.2.6/deps/jemalloc/test/integration/extent.c
redis-6.2.6/deps/jemalloc/test/integration/extent.sh
redis-6.2.6/deps/jemalloc/test/integration/mallocx.c
redis-6.2.6/deps/jemalloc/test/integration/mallocx.sh
redis-6.2.6/deps/jemalloc/test/integration/overflow.c
redis-6.2.6/deps/jemalloc/test/integration/posix_memalign.c
redis-6.2.6/deps/jemalloc/test/integration/rallocx.c
redis-6.2.6/deps/jemalloc/test/integration/sdallocx.c
redis-6.2.6/deps/jemalloc/test/integration/thread_arena.c
redis-6.2.6/deps/jemalloc/test/integration/thread_tcache_enabled.c
redis-6.2.6/deps/jemalloc/test/integration/xallocx.c
redis-6.2.6/deps/jemalloc/test/integration/xallocx.sh
redis-6.2.6/deps/jemalloc/test/src/
redis-6.2.6/deps/jemalloc/test/src/SFMT.c
redis-6.2.6/deps/jemalloc/test/src/btalloc.c
redis-6.2.6/deps/jemalloc/test/src/btalloc_0.c
redis-6.2.6/deps/jemalloc/test/src/btalloc_1.c
redis-6.2.6/deps/jemalloc/test/src/math.c
redis-6.2.6/deps/jemalloc/test/src/mq.c
redis-6.2.6/deps/jemalloc/test/src/mtx.c
redis-6.2.6/deps/jemalloc/test/src/test.c
redis-6.2.6/deps/jemalloc/test/src/thd.c
redis-6.2.6/deps/jemalloc/test/src/timer.c
redis-6.2.6/deps/jemalloc/test/stress/
redis-6.2.6/deps/jemalloc/test/stress/microbench.c
redis-6.2.6/deps/jemalloc/test/test.sh.in
redis-6.2.6/deps/jemalloc/test/unit/
redis-6.2.6/deps/jemalloc/test/unit/SFMT.c
redis-6.2.6/deps/jemalloc/test/unit/a0.c
redis-6.2.6/deps/jemalloc/test/unit/arena_reset.c
redis-6.2.6/deps/jemalloc/test/unit/arena_reset_prof.c
redis-6.2.6/deps/jemalloc/test/unit/arena_reset_prof.sh
redis-6.2.6/deps/jemalloc/test/unit/atomic.c
redis-6.2.6/deps/jemalloc/test/unit/background_thread.c
redis-6.2.6/deps/jemalloc/test/unit/background_thread_enable.c
redis-6.2.6/deps/jemalloc/test/unit/base.c
redis-6.2.6/deps/jemalloc/test/unit/bit_util.c
redis-6.2.6/deps/jemalloc/test/unit/bitmap.c
redis-6.2.6/deps/jemalloc/test/unit/ckh.c
redis-6.2.6/deps/jemalloc/test/unit/decay.c
redis-6.2.6/deps/jemalloc/test/unit/decay.sh
redis-6.2.6/deps/jemalloc/test/unit/div.c
redis-6.2.6/deps/jemalloc/test/unit/emitter.c
redis-6.2.6/deps/jemalloc/test/unit/extent_quantize.c
redis-6.2.6/deps/jemalloc/test/unit/fork.c
redis-6.2.6/deps/jemalloc/test/unit/hash.c
redis-6.2.6/deps/jemalloc/test/unit/hooks.c
redis-6.2.6/deps/jemalloc/test/unit/junk.c
redis-6.2.6/deps/jemalloc/test/unit/junk.sh
redis-6.2.6/deps/jemalloc/test/unit/junk_alloc.c
redis-6.2.6/deps/jemalloc/test/unit/junk_alloc.sh
redis-6.2.6/deps/jemalloc/test/unit/junk_free.c
redis-6.2.6/deps/jemalloc/test/unit/junk_free.sh
redis-6.2.6/deps/jemalloc/test/unit/log.c
redis-6.2.6/deps/jemalloc/test/unit/mallctl.c
redis-6.2.6/deps/jemalloc/test/unit/malloc_io.c
redis-6.2.6/deps/jemalloc/test/unit/math.c
redis-6.2.6/deps/jemalloc/test/unit/mq.c
redis-6.2.6/deps/jemalloc/test/unit/mtx.c
redis-6.2.6/deps/jemalloc/test/unit/nstime.c
redis-6.2.6/deps/jemalloc/test/unit/pack.c
redis-6.2.6/deps/jemalloc/test/unit/pack.sh
redis-6.2.6/deps/jemalloc/test/unit/pages.c
redis-6.2.6/deps/jemalloc/test/unit/ph.c
redis-6.2.6/deps/jemalloc/test/unit/prng.c
redis-6.2.6/deps/jemalloc/test/unit/prof_accum.c
redis-6.2.6/deps/jemalloc/test/unit/prof_accum.sh
redis-6.2.6/deps/jemalloc/test/unit/prof_active.c
redis-6.2.6/deps/jemalloc/test/unit/prof_active.sh
redis-6.2.6/deps/jemalloc/test/unit/prof_gdump.c
redis-6.2.6/deps/jemalloc/test/unit/prof_gdump.sh
redis-6.2.6/deps/jemalloc/test/unit/prof_idump.c
redis-6.2.6/deps/jemalloc/test/unit/prof_idump.sh
redis-6.2.6/deps/jemalloc/test/unit/prof_reset.c
redis-6.2.6/deps/jemalloc/test/unit/prof_reset.sh
redis-6.2.6/deps/jemalloc/test/unit/prof_tctx.c
redis-6.2.6/deps/jemalloc/test/unit/prof_tctx.sh
redis-6.2.6/deps/jemalloc/test/unit/prof_thread_name.c
redis-6.2.6/deps/jemalloc/test/unit/prof_thread_name.sh
redis-6.2.6/deps/jemalloc/test/unit/ql.c
redis-6.2.6/deps/jemalloc/test/unit/qr.c
redis-6.2.6/deps/jemalloc/test/unit/rb.c
redis-6.2.6/deps/jemalloc/test/unit/retained.c
redis-6.2.6/deps/jemalloc/test/unit/rtree.c
redis-6.2.6/deps/jemalloc/test/unit/size_classes.c
redis-6.2.6/deps/jemalloc/test/unit/slab.c
redis-6.2.6/deps/jemalloc/test/unit/smoothstep.c
redis-6.2.6/deps/jemalloc/test/unit/spin.c
redis-6.2.6/deps/jemalloc/test/unit/stats.c
redis-6.2.6/deps/jemalloc/test/unit/stats_print.c
redis-6.2.6/deps/jemalloc/test/unit/ticker.c
redis-6.2.6/deps/jemalloc/test/unit/tsd.c
redis-6.2.6/deps/jemalloc/test/unit/witness.c
redis-6.2.6/deps/jemalloc/test/unit/zero.c
redis-6.2.6/deps/jemalloc/test/unit/zero.sh
redis-6.2.6/deps/linenoise/
redis-6.2.6/deps/linenoise/.gitignore
redis-6.2.6/deps/linenoise/Makefile
redis-6.2.6/deps/linenoise/README.markdown
redis-6.2.6/deps/linenoise/example.c
redis-6.2.6/deps/linenoise/linenoise.c
redis-6.2.6/deps/linenoise/linenoise.h
redis-6.2.6/deps/lua/
redis-6.2.6/deps/lua/COPYRIGHT
redis-6.2.6/deps/lua/HISTORY
redis-6.2.6/deps/lua/INSTALL
redis-6.2.6/deps/lua/Makefile
redis-6.2.6/deps/lua/README
redis-6.2.6/deps/lua/doc/
redis-6.2.6/deps/lua/doc/contents.html
redis-6.2.6/deps/lua/doc/cover.png
redis-6.2.6/deps/lua/doc/logo.gif
redis-6.2.6/deps/lua/doc/lua.1
redis-6.2.6/deps/lua/doc/lua.css
redis-6.2.6/deps/lua/doc/lua.html
redis-6.2.6/deps/lua/doc/luac.1
redis-6.2.6/deps/lua/doc/luac.html
redis-6.2.6/deps/lua/doc/manual.css
redis-6.2.6/deps/lua/doc/manual.html
redis-6.2.6/deps/lua/doc/readme.html
redis-6.2.6/deps/lua/etc/
redis-6.2.6/deps/lua/etc/Makefile
redis-6.2.6/deps/lua/etc/README
redis-6.2.6/deps/lua/etc/all.c
redis-6.2.6/deps/lua/etc/lua.hpp
redis-6.2.6/deps/lua/etc/lua.ico
redis-6.2.6/deps/lua/etc/lua.pc
redis-6.2.6/deps/lua/etc/luavs.bat
redis-6.2.6/deps/lua/etc/min.c
redis-6.2.6/deps/lua/etc/noparser.c
redis-6.2.6/deps/lua/etc/strict.lua
redis-6.2.6/deps/lua/src/
redis-6.2.6/deps/lua/src/Makefile
redis-6.2.6/deps/lua/src/fpconv.c
redis-6.2.6/deps/lua/src/fpconv.h
redis-6.2.6/deps/lua/src/lapi.c
redis-6.2.6/deps/lua/src/lapi.h
redis-6.2.6/deps/lua/src/lauxlib.c
redis-6.2.6/deps/lua/src/lauxlib.h
redis-6.2.6/deps/lua/src/lbaselib.c
redis-6.2.6/deps/lua/src/lcode.c
redis-6.2.6/deps/lua/src/lcode.h
redis-6.2.6/deps/lua/src/ldblib.c
redis-6.2.6/deps/lua/src/ldebug.c
redis-6.2.6/deps/lua/src/ldebug.h
redis-6.2.6/deps/lua/src/ldo.c
redis-6.2.6/deps/lua/src/ldo.h
redis-6.2.6/deps/lua/src/ldump.c
redis-6.2.6/deps/lua/src/lfunc.c
redis-6.2.6/deps/lua/src/lfunc.h
redis-6.2.6/deps/lua/src/lgc.c
redis-6.2.6/deps/lua/src/lgc.h
redis-6.2.6/deps/lua/src/linit.c
redis-6.2.6/deps/lua/src/liolib.c
redis-6.2.6/deps/lua/src/llex.c
redis-6.2.6/deps/lua/src/llex.h
redis-6.2.6/deps/lua/src/llimits.h
redis-6.2.6/deps/lua/src/lmathlib.c
redis-6.2.6/deps/lua/src/lmem.c
redis-6.2.6/deps/lua/src/lmem.h
redis-6.2.6/deps/lua/src/loadlib.c
redis-6.2.6/deps/lua/src/lobject.c
redis-6.2.6/deps/lua/src/lobject.h
redis-6.2.6/deps/lua/src/lopcodes.c
redis-6.2.6/deps/lua/src/lopcodes.h
redis-6.2.6/deps/lua/src/loslib.c
redis-6.2.6/deps/lua/src/lparser.c
redis-6.2.6/deps/lua/src/lparser.h
redis-6.2.6/deps/lua/src/lstate.c
redis-6.2.6/deps/lua/src/lstate.h
redis-6.2.6/deps/lua/src/lstring.c
redis-6.2.6/deps/lua/src/lstring.h
redis-6.2.6/deps/lua/src/lstrlib.c
redis-6.2.6/deps/lua/src/ltable.c
redis-6.2.6/deps/lua/src/ltable.h
redis-6.2.6/deps/lua/src/ltablib.c
redis-6.2.6/deps/lua/src/ltm.c
redis-6.2.6/deps/lua/src/ltm.h
redis-6.2.6/deps/lua/src/lua.c
redis-6.2.6/deps/lua/src/lua.h
redis-6.2.6/deps/lua/src/lua_bit.c
redis-6.2.6/deps/lua/src/lua_cjson.c
redis-6.2.6/deps/lua/src/lua_cmsgpack.c
redis-6.2.6/deps/lua/src/lua_struct.c
redis-6.2.6/deps/lua/src/luac.c
redis-6.2.6/deps/lua/src/luaconf.h
redis-6.2.6/deps/lua/src/lualib.h
redis-6.2.6/deps/lua/src/lundump.c
redis-6.2.6/deps/lua/src/lundump.h
redis-6.2.6/deps/lua/src/lvm.c
redis-6.2.6/deps/lua/src/lvm.h
redis-6.2.6/deps/lua/src/lzio.c
redis-6.2.6/deps/lua/src/lzio.h
redis-6.2.6/deps/lua/src/print.c
redis-6.2.6/deps/lua/src/strbuf.c
redis-6.2.6/deps/lua/src/strbuf.h
redis-6.2.6/deps/lua/test/
redis-6.2.6/deps/lua/test/README
redis-6.2.6/deps/lua/test/bisect.lua
redis-6.2.6/deps/lua/test/cf.lua
redis-6.2.6/deps/lua/test/echo.lua
redis-6.2.6/deps/lua/test/env.lua
redis-6.2.6/deps/lua/test/factorial.lua
redis-6.2.6/deps/lua/test/fib.lua
redis-6.2.6/deps/lua/test/fibfor.lua
redis-6.2.6/deps/lua/test/globals.lua
redis-6.2.6/deps/lua/test/hello.lua
redis-6.2.6/deps/lua/test/life.lua
redis-6.2.6/deps/lua/test/luac.lua
redis-6.2.6/deps/lua/test/printf.lua
redis-6.2.6/deps/lua/test/readonly.lua
redis-6.2.6/deps/lua/test/sieve.lua
redis-6.2.6/deps/lua/test/sort.lua
redis-6.2.6/deps/lua/test/table.lua
redis-6.2.6/deps/lua/test/trace-calls.lua
redis-6.2.6/deps/lua/test/trace-globals.lua
redis-6.2.6/deps/lua/test/xd.lua
redis-6.2.6/deps/update-jemalloc.sh
redis-6.2.6/redis.conf
redis-6.2.6/runtest
redis-6.2.6/runtest-cluster
redis-6.2.6/runtest-moduleapi
redis-6.2.6/runtest-sentinel
redis-6.2.6/sentinel.conf
redis-6.2.6/src/
redis-6.2.6/src/.gitignore
redis-6.2.6/src/Makefile
redis-6.2.6/src/acl.c
redis-6.2.6/src/adlist.c
redis-6.2.6/src/adlist.h
redis-6.2.6/src/ae.c
redis-6.2.6/src/ae.h
redis-6.2.6/src/ae_epoll.c
redis-6.2.6/src/ae_evport.c
redis-6.2.6/src/ae_kqueue.c
redis-6.2.6/src/ae_select.c
redis-6.2.6/src/anet.c
redis-6.2.6/src/anet.h
redis-6.2.6/src/aof.c
redis-6.2.6/src/asciilogo.h
redis-6.2.6/src/atomicvar.h
redis-6.2.6/src/bio.c
redis-6.2.6/src/bio.h
redis-6.2.6/src/bitops.c
redis-6.2.6/src/blocked.c
redis-6.2.6/src/childinfo.c
redis-6.2.6/src/cli_common.c
redis-6.2.6/src/cli_common.h
redis-6.2.6/src/cluster.c
redis-6.2.6/src/cluster.h
redis-6.2.6/src/config.c
redis-6.2.6/src/config.h
redis-6.2.6/src/connection.c
redis-6.2.6/src/connection.h
redis-6.2.6/src/connhelpers.h
redis-6.2.6/src/crc16.c
redis-6.2.6/src/crc16_slottable.h
redis-6.2.6/src/crc64.c
redis-6.2.6/src/crc64.h
redis-6.2.6/src/crcspeed.c
redis-6.2.6/src/crcspeed.h
redis-6.2.6/src/db.c
redis-6.2.6/src/debug.c
redis-6.2.6/src/debugmacro.h
redis-6.2.6/src/defrag.c
redis-6.2.6/src/dict.c
redis-6.2.6/src/dict.h
redis-6.2.6/src/endianconv.c
redis-6.2.6/src/endianconv.h
redis-6.2.6/src/evict.c
redis-6.2.6/src/expire.c
redis-6.2.6/src/fmacros.h
redis-6.2.6/src/geo.c
redis-6.2.6/src/geo.h
redis-6.2.6/src/geohash.c
redis-6.2.6/src/geohash.h
redis-6.2.6/src/geohash_helper.c
redis-6.2.6/src/geohash_helper.h
redis-6.2.6/src/gopher.c
redis-6.2.6/src/help.h
redis-6.2.6/src/hyperloglog.c
redis-6.2.6/src/intset.c
redis-6.2.6/src/intset.h
redis-6.2.6/src/latency.c
redis-6.2.6/src/latency.h
redis-6.2.6/src/lazyfree.c
redis-6.2.6/src/listpack.c
redis-6.2.6/src/listpack.h
redis-6.2.6/src/listpack_malloc.h
redis-6.2.6/src/localtime.c
redis-6.2.6/src/lolwut.c
redis-6.2.6/src/lolwut.h
redis-6.2.6/src/lolwut5.c
redis-6.2.6/src/lolwut6.c
redis-6.2.6/src/lzf.h
redis-6.2.6/src/lzfP.h
redis-6.2.6/src/lzf_c.c
redis-6.2.6/src/lzf_d.c
redis-6.2.6/src/memtest.c
redis-6.2.6/src/mkreleasehdr.sh
redis-6.2.6/src/module.c
redis-6.2.6/src/modules/
redis-6.2.6/src/modules/.gitignore
redis-6.2.6/src/modules/Makefile
redis-6.2.6/src/modules/gendoc.rb
redis-6.2.6/src/modules/helloacl.c
redis-6.2.6/src/modules/helloblock.c
redis-6.2.6/src/modules/hellocluster.c
redis-6.2.6/src/modules/hellodict.c
redis-6.2.6/src/modules/hellohook.c
redis-6.2.6/src/modules/hellotimer.c
redis-6.2.6/src/modules/hellotype.c
redis-6.2.6/src/modules/helloworld.c
redis-6.2.6/src/monotonic.c
redis-6.2.6/src/monotonic.h
redis-6.2.6/src/mt19937-64.c
redis-6.2.6/src/mt19937-64.h
redis-6.2.6/src/multi.c
redis-6.2.6/src/networking.c
redis-6.2.6/src/notify.c
redis-6.2.6/src/object.c
redis-6.2.6/src/pqsort.c
redis-6.2.6/src/pqsort.h
redis-6.2.6/src/pubsub.c
redis-6.2.6/src/quicklist.c
redis-6.2.6/src/quicklist.h
redis-6.2.6/src/rand.c
redis-6.2.6/src/rand.h
redis-6.2.6/src/rax.c
redis-6.2.6/src/rax.h
redis-6.2.6/src/rax_malloc.h
redis-6.2.6/src/rdb.c
redis-6.2.6/src/rdb.h
redis-6.2.6/src/redis-benchmark.c
redis-6.2.6/src/redis-check-aof.c
redis-6.2.6/src/redis-check-rdb.c
redis-6.2.6/src/redis-cli.c
redis-6.2.6/src/redis-trib.rb
redis-6.2.6/src/redisassert.h
redis-6.2.6/src/redismodule.h
redis-6.2.6/src/release.c
redis-6.2.6/src/replication.c
redis-6.2.6/src/rio.c
redis-6.2.6/src/rio.h
redis-6.2.6/src/scripting.c
redis-6.2.6/src/sds.c
redis-6.2.6/src/sds.h
redis-6.2.6/src/sdsalloc.h
redis-6.2.6/src/sentinel.c
redis-6.2.6/src/server.c
redis-6.2.6/src/server.h
redis-6.2.6/src/setcpuaffinity.c
redis-6.2.6/src/setproctitle.c
redis-6.2.6/src/sha1.c
redis-6.2.6/src/sha1.h
redis-6.2.6/src/sha256.c
redis-6.2.6/src/sha256.h
redis-6.2.6/src/siphash.c
redis-6.2.6/src/slowlog.c
redis-6.2.6/src/slowlog.h
redis-6.2.6/src/solarisfixes.h
redis-6.2.6/src/sort.c
redis-6.2.6/src/sparkline.c
redis-6.2.6/src/sparkline.h
redis-6.2.6/src/stream.h
redis-6.2.6/src/syncio.c
redis-6.2.6/src/t_hash.c
redis-6.2.6/src/t_list.c
redis-6.2.6/src/t_set.c
redis-6.2.6/src/t_stream.c
redis-6.2.6/src/t_string.c
redis-6.2.6/src/t_zset.c
redis-6.2.6/src/testhelp.h
redis-6.2.6/src/timeout.c
redis-6.2.6/src/tls.c
redis-6.2.6/src/tracking.c
redis-6.2.6/src/util.c
redis-6.2.6/src/util.h
redis-6.2.6/src/valgrind.sup
redis-6.2.6/src/version.h
redis-6.2.6/src/ziplist.c
redis-6.2.6/src/ziplist.h
redis-6.2.6/src/zipmap.c
redis-6.2.6/src/zipmap.h
redis-6.2.6/src/zmalloc.c
redis-6.2.6/src/zmalloc.h
redis-6.2.6/tests/
redis-6.2.6/tests/assets/
redis-6.2.6/tests/assets/corrupt_empty_keys.rdb
redis-6.2.6/tests/assets/corrupt_ziplist.rdb
redis-6.2.6/tests/assets/default.conf
redis-6.2.6/tests/assets/encodings.rdb
redis-6.2.6/tests/assets/hash-zipmap.rdb
redis-6.2.6/tests/assets/minimal.conf
redis-6.2.6/tests/assets/nodefaultuser.acl
redis-6.2.6/tests/assets/user.acl
redis-6.2.6/tests/cluster/
redis-6.2.6/tests/cluster/cluster.tcl
redis-6.2.6/tests/cluster/run.tcl
redis-6.2.6/tests/cluster/tests/
redis-6.2.6/tests/cluster/tests/00-base.tcl
redis-6.2.6/tests/cluster/tests/01-faildet.tcl
redis-6.2.6/tests/cluster/tests/02-failover.tcl
redis-6.2.6/tests/cluster/tests/03-failover-loop.tcl
redis-6.2.6/tests/cluster/tests/04-resharding.tcl
redis-6.2.6/tests/cluster/tests/05-slave-selection.tcl
redis-6.2.6/tests/cluster/tests/06-slave-stop-cond.tcl
redis-6.2.6/tests/cluster/tests/07-replica-migration.tcl
redis-6.2.6/tests/cluster/tests/08-update-msg.tcl
redis-6.2.6/tests/cluster/tests/09-pubsub.tcl
redis-6.2.6/tests/cluster/tests/10-manual-failover.tcl
redis-6.2.6/tests/cluster/tests/11-manual-takeover.tcl
redis-6.2.6/tests/cluster/tests/12-replica-migration-2.tcl
redis-6.2.6/tests/cluster/tests/12.1-replica-migration-3.tcl
redis-6.2.6/tests/cluster/tests/13-no-failover-option.tcl
redis-6.2.6/tests/cluster/tests/14-consistency-check.tcl
redis-6.2.6/tests/cluster/tests/15-cluster-slots.tcl
redis-6.2.6/tests/cluster/tests/16-transactions-on-replica.tcl
redis-6.2.6/tests/cluster/tests/17-diskless-load-swapdb.tcl
redis-6.2.6/tests/cluster/tests/18-info.tcl
redis-6.2.6/tests/cluster/tests/19-cluster-nodes-slots.tcl
redis-6.2.6/tests/cluster/tests/20-half-migrated-slot.tcl
redis-6.2.6/tests/cluster/tests/21-many-slot-migration.tcl
redis-6.2.6/tests/cluster/tests/helpers/
redis-6.2.6/tests/cluster/tests/helpers/onlydots.tcl
redis-6.2.6/tests/cluster/tests/includes/
redis-6.2.6/tests/cluster/tests/includes/init-tests.tcl
redis-6.2.6/tests/cluster/tests/includes/utils.tcl
redis-6.2.6/tests/cluster/tmp/
redis-6.2.6/tests/cluster/tmp/.gitignore
redis-6.2.6/tests/helpers/
redis-6.2.6/tests/helpers/bg_block_op.tcl
redis-6.2.6/tests/helpers/bg_complex_data.tcl
redis-6.2.6/tests/helpers/fake_redis_node.tcl
redis-6.2.6/tests/helpers/gen_write_load.tcl
redis-6.2.6/tests/instances.tcl
redis-6.2.6/tests/integration/
redis-6.2.6/tests/integration/aof-race.tcl
redis-6.2.6/tests/integration/aof.tcl
redis-6.2.6/tests/integration/block-repl.tcl
redis-6.2.6/tests/integration/convert-zipmap-hash-on-load.tcl
redis-6.2.6/tests/integration/corrupt-dump-fuzzer.tcl
redis-6.2.6/tests/integration/corrupt-dump.tcl
redis-6.2.6/tests/integration/failover.tcl
redis-6.2.6/tests/integration/logging.tcl
redis-6.2.6/tests/integration/psync2-pingoff.tcl
redis-6.2.6/tests/integration/psync2-reg.tcl
redis-6.2.6/tests/integration/psync2.tcl
redis-6.2.6/tests/integration/rdb.tcl
redis-6.2.6/tests/integration/redis-benchmark.tcl
redis-6.2.6/tests/integration/redis-cli.tcl
redis-6.2.6/tests/integration/replication-2.tcl
redis-6.2.6/tests/integration/replication-3.tcl
redis-6.2.6/tests/integration/replication-4.tcl
redis-6.2.6/tests/integration/replication-psync.tcl
redis-6.2.6/tests/integration/replication.tcl
redis-6.2.6/tests/modules/
redis-6.2.6/tests/modules/Makefile
redis-6.2.6/tests/modules/auth.c
redis-6.2.6/tests/modules/basics.c
redis-6.2.6/tests/modules/blockedclient.c
redis-6.2.6/tests/modules/blockonbackground.c
redis-6.2.6/tests/modules/blockonkeys.c
redis-6.2.6/tests/modules/commandfilter.c
redis-6.2.6/tests/modules/datatype.c
redis-6.2.6/tests/modules/defragtest.c
redis-6.2.6/tests/modules/fork.c
redis-6.2.6/tests/modules/getkeys.c
redis-6.2.6/tests/modules/hash.c
redis-6.2.6/tests/modules/hooks.c
redis-6.2.6/tests/modules/infotest.c
redis-6.2.6/tests/modules/keyspace_events.c
redis-6.2.6/tests/modules/misc.c
redis-6.2.6/tests/modules/propagate.c
redis-6.2.6/tests/modules/scan.c
redis-6.2.6/tests/modules/stream.c
redis-6.2.6/tests/modules/test_lazyfree.c
redis-6.2.6/tests/modules/testrdb.c
redis-6.2.6/tests/modules/timer.c
redis-6.2.6/tests/modules/zset.c
redis-6.2.6/tests/sentinel/
redis-6.2.6/tests/sentinel/run.tcl
redis-6.2.6/tests/sentinel/tests/
redis-6.2.6/tests/sentinel/tests/00-base.tcl
redis-6.2.6/tests/sentinel/tests/01-conf-update.tcl
redis-6.2.6/tests/sentinel/tests/02-slaves-reconf.tcl
redis-6.2.6/tests/sentinel/tests/03-runtime-reconf.tcl
redis-6.2.6/tests/sentinel/tests/04-slave-selection.tcl
redis-6.2.6/tests/sentinel/tests/05-manual.tcl
redis-6.2.6/tests/sentinel/tests/06-ckquorum.tcl
redis-6.2.6/tests/sentinel/tests/07-down-conditions.tcl
redis-6.2.6/tests/sentinel/tests/08-hostname-conf.tcl
redis-6.2.6/tests/sentinel/tests/09-acl-support.tcl
redis-6.2.6/tests/sentinel/tests/10-replica-priority.tcl
redis-6.2.6/tests/sentinel/tests/helpers/
redis-6.2.6/tests/sentinel/tests/helpers/check_leaked_fds.tcl
redis-6.2.6/tests/sentinel/tests/includes/
redis-6.2.6/tests/sentinel/tests/includes/init-tests.tcl
redis-6.2.6/tests/sentinel/tests/includes/sentinel.conf
redis-6.2.6/tests/sentinel/tests/includes/start-init-tests.tcl
redis-6.2.6/tests/sentinel/tmp/
redis-6.2.6/tests/sentinel/tmp/.gitignore
redis-6.2.6/tests/support/
redis-6.2.6/tests/support/benchmark.tcl
redis-6.2.6/tests/support/cli.tcl
redis-6.2.6/tests/support/cluster.tcl
redis-6.2.6/tests/support/redis.tcl
redis-6.2.6/tests/support/server.tcl
redis-6.2.6/tests/support/test.tcl
redis-6.2.6/tests/support/tmpfile.tcl
redis-6.2.6/tests/support/util.tcl
redis-6.2.6/tests/test_helper.tcl
redis-6.2.6/tests/tmp/
redis-6.2.6/tests/tmp/.gitignore
redis-6.2.6/tests/unit/
redis-6.2.6/tests/unit/acl.tcl
redis-6.2.6/tests/unit/aofrw.tcl
redis-6.2.6/tests/unit/auth.tcl
redis-6.2.6/tests/unit/bitfield.tcl
redis-6.2.6/tests/unit/bitops.tcl
redis-6.2.6/tests/unit/dump.tcl
redis-6.2.6/tests/unit/expire.tcl
redis-6.2.6/tests/unit/geo.tcl
redis-6.2.6/tests/unit/hyperloglog.tcl
redis-6.2.6/tests/unit/info.tcl
redis-6.2.6/tests/unit/introspection-2.tcl
redis-6.2.6/tests/unit/introspection.tcl
redis-6.2.6/tests/unit/keyspace.tcl
redis-6.2.6/tests/unit/latency-monitor.tcl
redis-6.2.6/tests/unit/lazyfree.tcl
redis-6.2.6/tests/unit/limits.tcl
redis-6.2.6/tests/unit/maxmemory.tcl
redis-6.2.6/tests/unit/memefficiency.tcl
redis-6.2.6/tests/unit/moduleapi/
redis-6.2.6/tests/unit/moduleapi/auth.tcl
redis-6.2.6/tests/unit/moduleapi/basics.tcl
redis-6.2.6/tests/unit/moduleapi/blockedclient.tcl
redis-6.2.6/tests/unit/moduleapi/blockonbackground.tcl
redis-6.2.6/tests/unit/moduleapi/blockonkeys.tcl
redis-6.2.6/tests/unit/moduleapi/commandfilter.tcl
redis-6.2.6/tests/unit/moduleapi/datatype.tcl
redis-6.2.6/tests/unit/moduleapi/defrag.tcl
redis-6.2.6/tests/unit/moduleapi/fork.tcl
redis-6.2.6/tests/unit/moduleapi/getkeys.tcl
redis-6.2.6/tests/unit/moduleapi/hash.tcl
redis-6.2.6/tests/unit/moduleapi/hooks.tcl
redis-6.2.6/tests/unit/moduleapi/infotest.tcl
redis-6.2.6/tests/unit/moduleapi/keyspace_events.tcl
redis-6.2.6/tests/unit/moduleapi/misc.tcl
redis-6.2.6/tests/unit/moduleapi/propagate.tcl
redis-6.2.6/tests/unit/moduleapi/scan.tcl
redis-6.2.6/tests/unit/moduleapi/stream.tcl
redis-6.2.6/tests/unit/moduleapi/test_lazyfree.tcl
redis-6.2.6/tests/unit/moduleapi/testrdb.tcl
redis-6.2.6/tests/unit/moduleapi/timer.tcl
redis-6.2.6/tests/unit/moduleapi/zset.tcl
redis-6.2.6/tests/unit/multi.tcl
redis-6.2.6/tests/unit/networking.tcl
redis-6.2.6/tests/unit/obuf-limits.tcl
redis-6.2.6/tests/unit/oom-score-adj.tcl
redis-6.2.6/tests/unit/other.tcl
redis-6.2.6/tests/unit/pause.tcl
redis-6.2.6/tests/unit/pendingquerybuf.tcl
redis-6.2.6/tests/unit/printver.tcl
redis-6.2.6/tests/unit/protocol.tcl
redis-6.2.6/tests/unit/pubsub.tcl
redis-6.2.6/tests/unit/quit.tcl
redis-6.2.6/tests/unit/scan.tcl
redis-6.2.6/tests/unit/scripting.tcl
redis-6.2.6/tests/unit/shutdown.tcl
redis-6.2.6/tests/unit/slowlog.tcl
redis-6.2.6/tests/unit/sort.tcl
redis-6.2.6/tests/unit/tls.tcl
redis-6.2.6/tests/unit/tracking.tcl
redis-6.2.6/tests/unit/type/
redis-6.2.6/tests/unit/type/hash.tcl
redis-6.2.6/tests/unit/type/incr.tcl
redis-6.2.6/tests/unit/type/list-2.tcl
redis-6.2.6/tests/unit/type/list-3.tcl
redis-6.2.6/tests/unit/type/list-common.tcl
redis-6.2.6/tests/unit/type/list.tcl
redis-6.2.6/tests/unit/type/set.tcl
redis-6.2.6/tests/unit/type/stream-cgroups.tcl
redis-6.2.6/tests/unit/type/stream.tcl
redis-6.2.6/tests/unit/type/string.tcl
redis-6.2.6/tests/unit/type/zset.tcl
redis-6.2.6/tests/unit/violations.tcl
redis-6.2.6/tests/unit/wait.tcl
redis-6.2.6/utils/
redis-6.2.6/utils/build-static-symbols.tcl
redis-6.2.6/utils/cluster_fail_time.tcl
redis-6.2.6/utils/corrupt_rdb.c
redis-6.2.6/utils/create-cluster/
redis-6.2.6/utils/create-cluster/.gitignore
redis-6.2.6/utils/create-cluster/README
redis-6.2.6/utils/create-cluster/create-cluster
redis-6.2.6/utils/gen-test-certs.sh
redis-6.2.6/utils/generate-command-help.rb
redis-6.2.6/utils/graphs/
redis-6.2.6/utils/graphs/commits-over-time/
redis-6.2.6/utils/graphs/commits-over-time/README.md
redis-6.2.6/utils/graphs/commits-over-time/genhtml.tcl
redis-6.2.6/utils/hashtable/
redis-6.2.6/utils/hashtable/README
redis-6.2.6/utils/hashtable/rehashing.c
redis-6.2.6/utils/hyperloglog/
redis-6.2.6/utils/hyperloglog/.gitignore
redis-6.2.6/utils/hyperloglog/hll-err.rb
redis-6.2.6/utils/hyperloglog/hll-gnuplot-graph.rb
redis-6.2.6/utils/install_server.sh
redis-6.2.6/utils/lru/
redis-6.2.6/utils/lru/README
redis-6.2.6/utils/lru/lfu-simulation.c
redis-6.2.6/utils/lru/test-lru.rb
redis-6.2.6/utils/redis-copy.rb
redis-6.2.6/utils/redis-sha1.rb
redis-6.2.6/utils/redis_init_script
redis-6.2.6/utils/redis_init_script.tpl
redis-6.2.6/utils/releasetools/
redis-6.2.6/utils/releasetools/01_create_tarball.sh
redis-6.2.6/utils/releasetools/02_upload_tarball.sh
redis-6.2.6/utils/releasetools/03_test_release.sh
redis-6.2.6/utils/releasetools/04_release_hash.sh
redis-6.2.6/utils/releasetools/changelog.tcl
redis-6.2.6/utils/speed-regression.tcl
redis-6.2.6/utils/srandmember/
redis-6.2.6/utils/srandmember/README.md
redis-6.2.6/utils/srandmember/showdist.rb
redis-6.2.6/utils/srandmember/showfreq.rb
redis-6.2.6/utils/systemd-redis_multiple_servers@.service
redis-6.2.6/utils/systemd-redis_server.service
redis-6.2.6/utils/tracking_collisions.c
redis-6.2.6/utils/whatisdoing.sh
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cd redis-6.2.6/
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# make

Command 'make' not found, but can be installed with:

apt install make        # version 4.2.1-1.2, or
apt install make-guile  # version 4.2.1-1.2

root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# apt install make
Reading package lists... Done
Building dependency tree
Reading state information... Done
Suggested packages:
  make-doc
The following NEW packages will be installed:
  make
0 upgraded, 1 newly installed, 0 to remove and 18 not upgraded.
Need to get 162 kB of archives.
After this operation, 393 kB of additional disk space will be used.
Get:1 http://mirrors.digitalocean.com/ubuntu focal/main amd64 make amd64 4.2.1-1.2 [162 kB]
Fetched 162 kB in 0s (881 kB/s)
Selecting previously unselected package make.
(Reading database ... 63555 files and directories currently installed.)
Preparing to unpack .../make_4.2.1-1.2_amd64.deb ...
Unpacking make (4.2.1-1.2) ...
Setting up make (4.2.1-1.2) ...
Processing triggers for man-db (2.9.1-1) ...

root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# make
cd src && make all
make[1]: Entering directory '/root/redis-6.2.6/src'
/bin/sh: 1: pkg-config: not found
    CC Makefile.dep
/bin/sh: 1: pkg-config: not found
rm -rf redis-server redis-sentinel redis-cli redis-benchmark redis-check-rdb redis-check-aof *.o *.gcda *.gcno *.gcov redis.info lcov-html Makefile.dep
rm -f adlist.d quicklist.d ae.d anet.d dict.d server.d sds.d zmalloc.d lzf_c.d lzf_d.d pqsort.d zipmap.d sha1.d ziplist.d release.d networking.d util.d object.d db.d replication.d rdb.d t_string.d t_list.d t_set.d t_zset.d t_hash.d config.d aof.d pubsub.d multi.d debug.d sort.d intset.d syncio.d cluster.d crc16.d endianconv.d slowlog.d scripting.d bio.d rio.d rand.d memtest.d crcspeed.d crc64.d bitops.d sentinel.d notify.d setproctitle.d blocked.d hyperloglog.d latency.d sparkline.d redis-check-rdb.d redis-check-aof.d geo.d lazyfree.d module.d evict.d expire.d geohash.d geohash_helper.d childinfo.d defrag.d siphash.d rax.d t_stream.d listpack.d localtime.d lolwut.d lolwut5.d lolwut6.d acl.d gopher.d tracking.d connection.d tls.d sha256.d timeout.d setcpuaffinity.d monotonic.d mt19937-64.d anet.d adlist.d dict.d redis-cli.d zmalloc.d release.d ae.d crcspeed.d crc64.d siphash.d crc16.d monotonic.d cli_common.d mt19937-64.d ae.d anet.d redis-benchmark.d adlist.d dict.d zmalloc.d release.d crcspeed.d crc64.d siphash.d crc16.d monotonic.d cli_common.d mt19937-64.d
(cd ../deps && make distclean)
make[2]: Entering directory '/root/redis-6.2.6/deps'
(cd hiredis && make clean) > /dev/null || true
(cd linenoise && make clean) > /dev/null || true
(cd lua && make clean) > /dev/null || true
(cd jemalloc && [ -f Makefile ] && make distclean) > /dev/null || true
(cd hdr_histogram && make clean) > /dev/null || true
(rm -f .make-*)
make[2]: Leaving directory '/root/redis-6.2.6/deps'
(cd modules && make clean)
make[2]: Entering directory '/root/redis-6.2.6/src/modules'
rm -rf *.xo *.so
make[2]: Leaving directory '/root/redis-6.2.6/src/modules'
(cd ../tests/modules && make clean)
make[2]: Entering directory '/root/redis-6.2.6/tests/modules'
rm -f commandfilter.so basics.so testrdb.so fork.so infotest.so propagate.so misc.so hooks.so blockonkeys.so blockonbackground.so scan.so datatype.so auth.so keyspace_events.so blockedclient.so getkeys.so test_lazyfree.so timer.so defragtest.so hash.so zset.so stream.so commandfilter.xo basics.xo testrdb.xo fork.xo infotest.xo propagate.xo misc.xo hooks.xo blockonkeys.xo blockonbackground.xo scan.xo datatype.xo auth.xo keyspace_events.xo blockedclient.xo getkeys.xo test_lazyfree.xo timer.xo defragtest.xo hash.xo zset.xo stream.xo
make[2]: Leaving directory '/root/redis-6.2.6/tests/modules'
(rm -f .make-*)
echo STD=-pedantic -DREDIS_STATIC='' -std=c99 >> .make-settings
echo WARN=-Wall -W -Wno-missing-field-initializers >> .make-settings
echo OPT=-O2 >> .make-settings
echo MALLOC=jemalloc >> .make-settings
echo BUILD_TLS= >> .make-settings
echo USE_SYSTEMD= >> .make-settings
echo CFLAGS= >> .make-settings
echo LDFLAGS= >> .make-settings
echo REDIS_CFLAGS= >> .make-settings
echo REDIS_LDFLAGS= >> .make-settings
echo PREV_FINAL_CFLAGS=-pedantic -DREDIS_STATIC='' -std=c99 -Wall -W -Wno-missing-field-initializers -O2 -g -ggdb   -I../deps/hiredis -I../deps/linenoise -I../deps/lua/src -I../deps/hdr_histogram -DUSE_JEMALLOC -I../deps/jemalloc/include >> .make-settings
echo PREV_FINAL_LDFLAGS=  -g -ggdb -rdynamic >> .make-settings
(cd ../deps && make hiredis linenoise lua hdr_histogram jemalloc)
make[2]: Entering directory '/root/redis-6.2.6/deps'
(cd hiredis && make clean) > /dev/null || true
(cd linenoise && make clean) > /dev/null || true
(cd lua && make clean) > /dev/null || true
(cd jemalloc && [ -f Makefile ] && make distclean) > /dev/null || true
(cd hdr_histogram && make clean) > /dev/null || true
(rm -f .make-*)
(echo "" > .make-cflags)
(echo "" > .make-ldflags)
MAKE hiredis
cd hiredis && make static
make[3]: Entering directory '/root/redis-6.2.6/deps/hiredis'
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb alloc.c
make[3]: cc: Command not found
make[3]: *** [Makefile:228: alloc.o] Error 127
make[3]: Leaving directory '/root/redis-6.2.6/deps/hiredis'
make[2]: *** [Makefile:51: hiredis] Error 2
make[2]: Leaving directory '/root/redis-6.2.6/deps'
make[1]: [Makefile:326: persist-settings] Error 2 (ignored)
    CC adlist.o
/bin/sh: 1: cc: not found
make[1]: *** [Makefile:374: adlist.o] Error 127
make[1]: Leaving directory '/root/redis-6.2.6/src'
make: *** [Makefile:6: all] Error 2
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# apt install cc
Reading package lists... Done
Building dependency tree
Reading state information... Done
E: Unable to locate package cc
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# apt install gcc
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu cpp cpp-9 gcc-9 gcc-9-base libasan5 libatomic1 libbinutils libc-dev-bin
  libc6-dev libcc1-0 libcrypt-dev libctf-nobfd0 libctf0 libgcc-9-dev libgomp1 libisl22 libitm1 liblsan0 libmpc3 libquadmath0
  libtsan0 libubsan1 linux-libc-dev manpages-dev
Suggested packages:
  binutils-doc cpp-doc gcc-9-locales gcc-multilib autoconf automake libtool flex bison gdb gcc-doc gcc-9-multilib gcc-9-doc
  glibc-doc
The following NEW packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu cpp cpp-9 gcc gcc-9 gcc-9-base libasan5 libatomic1 libbinutils
  libc-dev-bin libc6-dev libcc1-0 libcrypt-dev libctf-nobfd0 libctf0 libgcc-9-dev libgomp1 libisl22 libitm1 liblsan0 libmpc3
  libquadmath0 libtsan0 libubsan1 linux-libc-dev manpages-dev
0 upgraded, 28 newly installed, 0 to remove and 18 not upgraded.
Need to get 31.6 MB of archives.
After this operation, 136 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 binutils-common amd64 2.34-6ubuntu1.3 [207 kB]
Get:2 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libbinutils amd64 2.34-6ubuntu1.3 [474 kB]
Get:3 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libctf-nobfd0 amd64 2.34-6ubuntu1.3 [47.4 kB]
Get:4 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libctf0 amd64 2.34-6ubuntu1.3 [46.6 kB]
Get:5 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 binutils-x86-64-linux-gnu amd64 2.34-6ubuntu1.3 [1613 kB]
Get:6 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 binutils amd64 2.34-6ubuntu1.3 [3380 B]
Get:7 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 gcc-9-base amd64 9.3.0-17ubuntu1~20.04 [19.1 kB]
Get:8 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libisl22 amd64 0.22.1-1 [592 kB]
Get:9 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libmpc3 amd64 1.1.0-1 [40.8 kB]
Get:10 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 cpp-9 amd64 9.3.0-17ubuntu1~20.04 [7494 kB]
Get:11 http://mirrors.digitalocean.com/ubuntu focal/main amd64 cpp amd64 4:9.3.0-1ubuntu2 [27.6 kB]
Get:12 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libcc1-0 amd64 10.3.0-1ubuntu1~20.04 [48.8 kB]
Get:13 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libgomp1 amd64 10.3.0-1ubuntu1~20.04 [102 kB]
Get:14 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libitm1 amd64 10.3.0-1ubuntu1~20.04 [26.2 kB]
Get:15 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libatomic1 amd64 10.3.0-1ubuntu1~20.04 [9284 B]
Get:16 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libasan5 amd64 9.3.0-17ubuntu1~20.04 [394 kB]
Get:17 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 liblsan0 amd64 10.3.0-1ubuntu1~20.04 [835 kB]
Get:18 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libtsan0 amd64 10.3.0-1ubuntu1~20.04 [2009 kB]
Get:19 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libubsan1 amd64 10.3.0-1ubuntu1~20.04 [784 kB]
Get:20 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libquadmath0 amd64 10.3.0-1ubuntu1~20.04 [146 kB]
Get:21 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libgcc-9-dev amd64 9.3.0-17ubuntu1~20.04 [2360 kB]
Get:22 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 gcc-9 amd64 9.3.0-17ubuntu1~20.04 [8241 kB]
Get:23 http://mirrors.digitalocean.com/ubuntu focal/main amd64 gcc amd64 4:9.3.0-1ubuntu2 [5208 B]
Get:24 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libc-dev-bin amd64 2.31-0ubuntu9.2 [71.8 kB]
Get:25 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 linux-libc-dev amd64 5.4.0-89.100 [1110 kB]
Get:26 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libcrypt-dev amd64 1:4.4.10-10ubuntu4 [104 kB]
Get:27 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libc6-dev amd64 2.31-0ubuntu9.2 [2520 kB]
Get:28 http://mirrors.digitalocean.com/ubuntu focal/main amd64 manpages-dev all 5.05-1 [2266 kB]
Fetched 31.6 MB in 5s (6512 kB/s)
Selecting previously unselected package binutils-common:amd64.
(Reading database ... 63571 files and directories currently installed.)
Preparing to unpack .../00-binutils-common_2.34-6ubuntu1.3_amd64.deb ...
Unpacking binutils-common:amd64 (2.34-6ubuntu1.3) ...
Selecting previously unselected package libbinutils:amd64.
Preparing to unpack .../01-libbinutils_2.34-6ubuntu1.3_amd64.deb ...
Unpacking libbinutils:amd64 (2.34-6ubuntu1.3) ...
Selecting previously unselected package libctf-nobfd0:amd64.
Preparing to unpack .../02-libctf-nobfd0_2.34-6ubuntu1.3_amd64.deb ...
Unpacking libctf-nobfd0:amd64 (2.34-6ubuntu1.3) ...
Selecting previously unselected package libctf0:amd64.
Preparing to unpack .../03-libctf0_2.34-6ubuntu1.3_amd64.deb ...
Unpacking libctf0:amd64 (2.34-6ubuntu1.3) ...
Selecting previously unselected package binutils-x86-64-linux-gnu.
Preparing to unpack .../04-binutils-x86-64-linux-gnu_2.34-6ubuntu1.3_amd64.deb ...
Unpacking binutils-x86-64-linux-gnu (2.34-6ubuntu1.3) ...
Selecting previously unselected package binutils.
Preparing to unpack .../05-binutils_2.34-6ubuntu1.3_amd64.deb ...
Unpacking binutils (2.34-6ubuntu1.3) ...
Selecting previously unselected package gcc-9-base:amd64.
Preparing to unpack .../06-gcc-9-base_9.3.0-17ubuntu1~20.04_amd64.deb ...
Unpacking gcc-9-base:amd64 (9.3.0-17ubuntu1~20.04) ...
Selecting previously unselected package libisl22:amd64.
Preparing to unpack .../07-libisl22_0.22.1-1_amd64.deb ...
Unpacking libisl22:amd64 (0.22.1-1) ...
Selecting previously unselected package libmpc3:amd64.
Preparing to unpack .../08-libmpc3_1.1.0-1_amd64.deb ...
Unpacking libmpc3:amd64 (1.1.0-1) ...
Selecting previously unselected package cpp-9.
Preparing to unpack .../09-cpp-9_9.3.0-17ubuntu1~20.04_amd64.deb ...
Unpacking cpp-9 (9.3.0-17ubuntu1~20.04) ...
Selecting previously unselected package cpp.
Preparing to unpack .../10-cpp_4%3a9.3.0-1ubuntu2_amd64.deb ...
Unpacking cpp (4:9.3.0-1ubuntu2) ...
Selecting previously unselected package libcc1-0:amd64.
Preparing to unpack .../11-libcc1-0_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking libcc1-0:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libgomp1:amd64.
Preparing to unpack .../12-libgomp1_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking libgomp1:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libitm1:amd64.
Preparing to unpack .../13-libitm1_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking libitm1:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libatomic1:amd64.
Preparing to unpack .../14-libatomic1_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking libatomic1:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libasan5:amd64.
Preparing to unpack .../15-libasan5_9.3.0-17ubuntu1~20.04_amd64.deb ...
Unpacking libasan5:amd64 (9.3.0-17ubuntu1~20.04) ...
Selecting previously unselected package liblsan0:amd64.
Preparing to unpack .../16-liblsan0_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking liblsan0:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libtsan0:amd64.
Preparing to unpack .../17-libtsan0_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking libtsan0:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libubsan1:amd64.
Preparing to unpack .../18-libubsan1_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking libubsan1:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libquadmath0:amd64.
Preparing to unpack .../19-libquadmath0_10.3.0-1ubuntu1~20.04_amd64.deb ...
Unpacking libquadmath0:amd64 (10.3.0-1ubuntu1~20.04) ...
Selecting previously unselected package libgcc-9-dev:amd64.
Preparing to unpack .../20-libgcc-9-dev_9.3.0-17ubuntu1~20.04_amd64.deb ...
Unpacking libgcc-9-dev:amd64 (9.3.0-17ubuntu1~20.04) ...
Selecting previously unselected package gcc-9.
Preparing to unpack .../21-gcc-9_9.3.0-17ubuntu1~20.04_amd64.deb ...
Unpacking gcc-9 (9.3.0-17ubuntu1~20.04) ...
Selecting previously unselected package gcc.
Preparing to unpack .../22-gcc_4%3a9.3.0-1ubuntu2_amd64.deb ...
Unpacking gcc (4:9.3.0-1ubuntu2) ...
Selecting previously unselected package libc-dev-bin.
Preparing to unpack .../23-libc-dev-bin_2.31-0ubuntu9.2_amd64.deb ...
Unpacking libc-dev-bin (2.31-0ubuntu9.2) ...
Selecting previously unselected package linux-libc-dev:amd64.
Preparing to unpack .../24-linux-libc-dev_5.4.0-89.100_amd64.deb ...
Unpacking linux-libc-dev:amd64 (5.4.0-89.100) ...
Selecting previously unselected package libcrypt-dev:amd64.
Preparing to unpack .../25-libcrypt-dev_1%3a4.4.10-10ubuntu4_amd64.deb ...
Unpacking libcrypt-dev:amd64 (1:4.4.10-10ubuntu4) ...
Selecting previously unselected package libc6-dev:amd64.
Preparing to unpack .../26-libc6-dev_2.31-0ubuntu9.2_amd64.deb ...
Unpacking libc6-dev:amd64 (2.31-0ubuntu9.2) ...
Selecting previously unselected package manpages-dev.
Preparing to unpack .../27-manpages-dev_5.05-1_all.deb ...
Unpacking manpages-dev (5.05-1) ...
Setting up manpages-dev (5.05-1) ...
Setting up binutils-common:amd64 (2.34-6ubuntu1.3) ...
Setting up linux-libc-dev:amd64 (5.4.0-89.100) ...
Setting up libctf-nobfd0:amd64 (2.34-6ubuntu1.3) ...
Setting up libgomp1:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up libquadmath0:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up libmpc3:amd64 (1.1.0-1) ...
Setting up libatomic1:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up libubsan1:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up libcrypt-dev:amd64 (1:4.4.10-10ubuntu4) ...
Setting up libisl22:amd64 (0.22.1-1) ...
Setting up libbinutils:amd64 (2.34-6ubuntu1.3) ...
Setting up libc-dev-bin (2.31-0ubuntu9.2) ...
Setting up libcc1-0:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up liblsan0:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up libitm1:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up gcc-9-base:amd64 (9.3.0-17ubuntu1~20.04) ...
Setting up libtsan0:amd64 (10.3.0-1ubuntu1~20.04) ...
Setting up libctf0:amd64 (2.34-6ubuntu1.3) ...
Setting up libasan5:amd64 (9.3.0-17ubuntu1~20.04) ...
Setting up cpp-9 (9.3.0-17ubuntu1~20.04) ...
Setting up libc6-dev:amd64 (2.31-0ubuntu9.2) ...
Setting up binutils-x86-64-linux-gnu (2.34-6ubuntu1.3) ...
Setting up binutils (2.34-6ubuntu1.3) ...
Setting up libgcc-9-dev:amd64 (9.3.0-17ubuntu1~20.04) ...
Setting up cpp (4:9.3.0-1ubuntu2) ...
Setting up gcc-9 (9.3.0-17ubuntu1~20.04) ...
Setting up gcc (4:9.3.0-1ubuntu2) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for libc-bin (2.31-0ubuntu9.2) ...
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# make
cd src && make all
make[1]: Entering directory '/root/redis-6.2.6/src'
/bin/sh: 1: pkg-config: not found
    CC Makefile.dep
/bin/sh: 1: pkg-config: not found
    CC adlist.o
In file included from adlist.c:34:
zmalloc.h:50:10: fatal error: jemalloc/jemalloc.h: No such file or directory
   50 | #include <jemalloc/jemalloc.h>
      |          ^~~~~~~~~~~~~~~~~~~~~
compilation terminated.
make[1]: *** [Makefile:374: adlist.o] Error 1
make[1]: Leaving directory '/root/redis-6.2.6/src'
make: *** [Makefile:6: all] Error 2
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:~# wget https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2
--2021-10-30 05:08:18--  https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2
Resolving github.com (github.com)... 13.234.210.38
Connecting to github.com (github.com)|13.234.210.38|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://github-releases.githubusercontent.com/13310527/12798d00-b785-11e9-9716-bb90fb781d2a?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20211030%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20211030T050818Z&X-Amz-Expires=300&X-Amz-Signature=12b78ec4a9b6c9afbf3bed4838d00edda64b5e7c1031fd4a1eeb55a20e40a87e&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=13310527&response-content-disposition=attachment%3B%20filename%3Djemalloc-5.2.1.tar.bz2&response-content-type=application%2Foctet-stream [following]
--2021-10-30 05:08:18--  https://github-releases.githubusercontent.com/13310527/12798d00-b785-11e9-9716-bb90fb781d2a?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20211030%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20211030T050818Z&X-Amz-Expires=300&X-Amz-Signature=12b78ec4a9b6c9afbf3bed4838d00edda64b5e7c1031fd4a1eeb55a20e40a87e&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=13310527&response-content-disposition=attachment%3B%20filename%3Djemalloc-5.2.1.tar.bz2&response-content-type=application%2Foctet-stream
Resolving github-releases.githubusercontent.com (github-releases.githubusercontent.com)... 185.199.111.154, 185.199.110.154, 185.199.109.154, ...
Connecting to github-releases.githubusercontent.com (github-releases.githubusercontent.com)|185.199.111.154|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 554279 (541K) [application/octet-stream]
Saving to: ‘jemalloc-5.2.1.tar.bz2’

jemalloc-5.2.1.tar.bz2          100%[=====================================================>] 541.29K  --.-KB/s    in 0.03s

2021-10-30 05:08:19 (19.3 MB/s) - ‘jemalloc-5.2.1.tar.bz2’ saved [554279/554279]

root@ubuntu-s-1vcpu-1gb-blr1-01:~# tar xvf jemalloc-5.2.1.tar.bz2
jemalloc-5.2.1/
jemalloc-5.2.1/.appveyor.yml
jemalloc-5.2.1/.autom4te.cfg
jemalloc-5.2.1/.cirrus.yml
jemalloc-5.2.1/.gitattributes
jemalloc-5.2.1/.gitignore
jemalloc-5.2.1/.travis.yml
jemalloc-5.2.1/COPYING
jemalloc-5.2.1/ChangeLog
jemalloc-5.2.1/INSTALL.md
jemalloc-5.2.1/Makefile.in
jemalloc-5.2.1/README
jemalloc-5.2.1/TUNING.md
jemalloc-5.2.1/autogen.sh
jemalloc-5.2.1/bin/
jemalloc-5.2.1/bin/jemalloc-config.in
jemalloc-5.2.1/bin/jemalloc.sh.in
jemalloc-5.2.1/bin/jeprof.in
jemalloc-5.2.1/build-aux/
jemalloc-5.2.1/build-aux/config.guess
jemalloc-5.2.1/build-aux/config.sub
jemalloc-5.2.1/build-aux/install-sh
jemalloc-5.2.1/config.stamp.in
jemalloc-5.2.1/configure.ac
jemalloc-5.2.1/doc/
jemalloc-5.2.1/doc/html.xsl.in
jemalloc-5.2.1/doc/jemalloc.xml.in
jemalloc-5.2.1/doc/manpages.xsl.in
jemalloc-5.2.1/doc/stylesheet.xsl
jemalloc-5.2.1/doc/jemalloc.html
jemalloc-5.2.1/doc/jemalloc.3
jemalloc-5.2.1/include/
jemalloc-5.2.1/include/jemalloc/
jemalloc-5.2.1/include/jemalloc/internal/
jemalloc-5.2.1/include/jemalloc/internal/arena_externs.h
jemalloc-5.2.1/include/jemalloc/internal/arena_inlines_a.h
jemalloc-5.2.1/include/jemalloc/internal/arena_inlines_b.h
jemalloc-5.2.1/include/jemalloc/internal/arena_stats.h
jemalloc-5.2.1/include/jemalloc/internal/arena_structs_a.h
jemalloc-5.2.1/include/jemalloc/internal/arena_structs_b.h
jemalloc-5.2.1/include/jemalloc/internal/arena_types.h
jemalloc-5.2.1/include/jemalloc/internal/assert.h
jemalloc-5.2.1/include/jemalloc/internal/atomic.h
jemalloc-5.2.1/include/jemalloc/internal/atomic_c11.h
jemalloc-5.2.1/include/jemalloc/internal/atomic_gcc_atomic.h
jemalloc-5.2.1/include/jemalloc/internal/atomic_gcc_sync.h
jemalloc-5.2.1/include/jemalloc/internal/atomic_msvc.h
jemalloc-5.2.1/include/jemalloc/internal/background_thread_externs.h
jemalloc-5.2.1/include/jemalloc/internal/background_thread_inlines.h
jemalloc-5.2.1/include/jemalloc/internal/background_thread_structs.h
jemalloc-5.2.1/include/jemalloc/internal/base_externs.h
jemalloc-5.2.1/include/jemalloc/internal/base_inlines.h
jemalloc-5.2.1/include/jemalloc/internal/base_structs.h
jemalloc-5.2.1/include/jemalloc/internal/base_types.h
jemalloc-5.2.1/include/jemalloc/internal/bin.h
jemalloc-5.2.1/include/jemalloc/internal/bin_stats.h
jemalloc-5.2.1/include/jemalloc/internal/bin_types.h
jemalloc-5.2.1/include/jemalloc/internal/bit_util.h
jemalloc-5.2.1/include/jemalloc/internal/bitmap.h
jemalloc-5.2.1/include/jemalloc/internal/cache_bin.h
jemalloc-5.2.1/include/jemalloc/internal/ckh.h
jemalloc-5.2.1/include/jemalloc/internal/ctl.h
jemalloc-5.2.1/include/jemalloc/internal/div.h
jemalloc-5.2.1/include/jemalloc/internal/emitter.h
jemalloc-5.2.1/include/jemalloc/internal/extent_dss.h
jemalloc-5.2.1/include/jemalloc/internal/extent_externs.h
jemalloc-5.2.1/include/jemalloc/internal/extent_inlines.h
jemalloc-5.2.1/include/jemalloc/internal/extent_mmap.h
jemalloc-5.2.1/include/jemalloc/internal/extent_structs.h
jemalloc-5.2.1/include/jemalloc/internal/extent_types.h
jemalloc-5.2.1/include/jemalloc/internal/hash.h
jemalloc-5.2.1/include/jemalloc/internal/hook.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_decls.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_defs.h.in
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_externs.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_includes.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_inlines_a.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_inlines_b.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_inlines_c.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_macros.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_internal_types.h
jemalloc-5.2.1/include/jemalloc/internal/jemalloc_preamble.h.in
jemalloc-5.2.1/include/jemalloc/internal/large_externs.h
jemalloc-5.2.1/include/jemalloc/internal/log.h
jemalloc-5.2.1/include/jemalloc/internal/malloc_io.h
jemalloc-5.2.1/include/jemalloc/internal/mutex.h
jemalloc-5.2.1/include/jemalloc/internal/mutex_pool.h
jemalloc-5.2.1/include/jemalloc/internal/mutex_prof.h
jemalloc-5.2.1/include/jemalloc/internal/nstime.h
jemalloc-5.2.1/include/jemalloc/internal/pages.h
jemalloc-5.2.1/include/jemalloc/internal/ph.h
jemalloc-5.2.1/include/jemalloc/internal/private_namespace.sh
jemalloc-5.2.1/include/jemalloc/internal/private_symbols.sh
jemalloc-5.2.1/include/jemalloc/internal/prng.h
jemalloc-5.2.1/include/jemalloc/internal/prof_externs.h
jemalloc-5.2.1/include/jemalloc/internal/prof_inlines_a.h
jemalloc-5.2.1/include/jemalloc/internal/prof_inlines_b.h
jemalloc-5.2.1/include/jemalloc/internal/prof_structs.h
jemalloc-5.2.1/include/jemalloc/internal/prof_types.h
jemalloc-5.2.1/include/jemalloc/internal/public_namespace.sh
jemalloc-5.2.1/include/jemalloc/internal/public_unnamespace.sh
jemalloc-5.2.1/include/jemalloc/internal/ql.h
jemalloc-5.2.1/include/jemalloc/internal/qr.h
jemalloc-5.2.1/include/jemalloc/internal/quantum.h
jemalloc-5.2.1/include/jemalloc/internal/rb.h
jemalloc-5.2.1/include/jemalloc/internal/rtree.h
jemalloc-5.2.1/include/jemalloc/internal/rtree_tsd.h
jemalloc-5.2.1/include/jemalloc/internal/safety_check.h
jemalloc-5.2.1/include/jemalloc/internal/sc.h
jemalloc-5.2.1/include/jemalloc/internal/seq.h
jemalloc-5.2.1/include/jemalloc/internal/smoothstep.h
jemalloc-5.2.1/include/jemalloc/internal/smoothstep.sh
jemalloc-5.2.1/include/jemalloc/internal/spin.h
jemalloc-5.2.1/include/jemalloc/internal/stats.h
jemalloc-5.2.1/include/jemalloc/internal/sz.h
jemalloc-5.2.1/include/jemalloc/internal/tcache_externs.h
jemalloc-5.2.1/include/jemalloc/internal/tcache_inlines.h
jemalloc-5.2.1/include/jemalloc/internal/tcache_structs.h
jemalloc-5.2.1/include/jemalloc/internal/tcache_types.h
jemalloc-5.2.1/include/jemalloc/internal/test_hooks.h
jemalloc-5.2.1/include/jemalloc/internal/ticker.h
jemalloc-5.2.1/include/jemalloc/internal/tsd.h
jemalloc-5.2.1/include/jemalloc/internal/tsd_generic.h
jemalloc-5.2.1/include/jemalloc/internal/tsd_malloc_thread_cleanup.h
jemalloc-5.2.1/include/jemalloc/internal/tsd_tls.h
jemalloc-5.2.1/include/jemalloc/internal/tsd_types.h
jemalloc-5.2.1/include/jemalloc/internal/tsd_win.h
jemalloc-5.2.1/include/jemalloc/internal/util.h
jemalloc-5.2.1/include/jemalloc/internal/witness.h
jemalloc-5.2.1/include/jemalloc/jemalloc.sh
jemalloc-5.2.1/include/jemalloc/jemalloc_defs.h.in
jemalloc-5.2.1/include/jemalloc/jemalloc_macros.h.in
jemalloc-5.2.1/include/jemalloc/jemalloc_mangle.sh
jemalloc-5.2.1/include/jemalloc/jemalloc_protos.h.in
jemalloc-5.2.1/include/jemalloc/jemalloc_rename.sh
jemalloc-5.2.1/include/jemalloc/jemalloc_typedefs.h.in
jemalloc-5.2.1/include/msvc_compat/
jemalloc-5.2.1/include/msvc_compat/C99/
jemalloc-5.2.1/include/msvc_compat/C99/stdbool.h
jemalloc-5.2.1/include/msvc_compat/C99/stdint.h
jemalloc-5.2.1/include/msvc_compat/strings.h
jemalloc-5.2.1/include/msvc_compat/windows_extra.h
jemalloc-5.2.1/jemalloc.pc.in
jemalloc-5.2.1/m4/
jemalloc-5.2.1/m4/ax_cxx_compile_stdcxx.m4
jemalloc-5.2.1/msvc/
jemalloc-5.2.1/msvc/ReadMe.txt
jemalloc-5.2.1/msvc/jemalloc_vc2015.sln
jemalloc-5.2.1/msvc/jemalloc_vc2017.sln
jemalloc-5.2.1/msvc/projects/
jemalloc-5.2.1/msvc/projects/vc2015/
jemalloc-5.2.1/msvc/projects/vc2015/jemalloc/
jemalloc-5.2.1/msvc/projects/vc2015/jemalloc/jemalloc.vcxproj
jemalloc-5.2.1/msvc/projects/vc2015/jemalloc/jemalloc.vcxproj.filters
jemalloc-5.2.1/msvc/projects/vc2015/test_threads/
jemalloc-5.2.1/msvc/projects/vc2015/test_threads/test_threads.vcxproj
jemalloc-5.2.1/msvc/projects/vc2015/test_threads/test_threads.vcxproj.filters
jemalloc-5.2.1/msvc/projects/vc2017/
jemalloc-5.2.1/msvc/projects/vc2017/jemalloc/
jemalloc-5.2.1/msvc/projects/vc2017/jemalloc/jemalloc.vcxproj
jemalloc-5.2.1/msvc/projects/vc2017/jemalloc/jemalloc.vcxproj.filters
jemalloc-5.2.1/msvc/projects/vc2017/test_threads/
jemalloc-5.2.1/msvc/projects/vc2017/test_threads/test_threads.vcxproj
jemalloc-5.2.1/msvc/projects/vc2017/test_threads/test_threads.vcxproj.filters
jemalloc-5.2.1/msvc/test_threads/
jemalloc-5.2.1/msvc/test_threads/test_threads.cpp
jemalloc-5.2.1/msvc/test_threads/test_threads.h
jemalloc-5.2.1/msvc/test_threads/test_threads_main.cpp
jemalloc-5.2.1/run_tests.sh
jemalloc-5.2.1/scripts/
jemalloc-5.2.1/scripts/gen_run_tests.py
jemalloc-5.2.1/scripts/gen_travis.py
jemalloc-5.2.1/src/
jemalloc-5.2.1/src/arena.c
jemalloc-5.2.1/src/background_thread.c
jemalloc-5.2.1/src/base.c
jemalloc-5.2.1/src/bin.c
jemalloc-5.2.1/src/bitmap.c
jemalloc-5.2.1/src/ckh.c
jemalloc-5.2.1/src/ctl.c
jemalloc-5.2.1/src/div.c
jemalloc-5.2.1/src/extent.c
jemalloc-5.2.1/src/extent_dss.c
jemalloc-5.2.1/src/extent_mmap.c
jemalloc-5.2.1/src/hash.c
jemalloc-5.2.1/src/hook.c
jemalloc-5.2.1/src/jemalloc.c
jemalloc-5.2.1/src/jemalloc_cpp.cpp
jemalloc-5.2.1/src/large.c
jemalloc-5.2.1/src/log.c
jemalloc-5.2.1/src/malloc_io.c
jemalloc-5.2.1/src/mutex.c
jemalloc-5.2.1/src/mutex_pool.c
jemalloc-5.2.1/src/nstime.c
jemalloc-5.2.1/src/pages.c
jemalloc-5.2.1/src/prng.c
jemalloc-5.2.1/src/prof.c
jemalloc-5.2.1/src/rtree.c
jemalloc-5.2.1/src/safety_check.c
jemalloc-5.2.1/src/sc.c
jemalloc-5.2.1/src/stats.c
jemalloc-5.2.1/src/sz.c
jemalloc-5.2.1/src/tcache.c
jemalloc-5.2.1/src/test_hooks.c
jemalloc-5.2.1/src/ticker.c
jemalloc-5.2.1/src/tsd.c
jemalloc-5.2.1/src/witness.c
jemalloc-5.2.1/src/zone.c
jemalloc-5.2.1/test/
jemalloc-5.2.1/test/include/
jemalloc-5.2.1/test/include/test/
jemalloc-5.2.1/test/include/test/SFMT-alti.h
jemalloc-5.2.1/test/include/test/SFMT-params.h
jemalloc-5.2.1/test/include/test/SFMT-params11213.h
jemalloc-5.2.1/test/include/test/SFMT-params1279.h
jemalloc-5.2.1/test/include/test/SFMT-params132049.h
jemalloc-5.2.1/test/include/test/SFMT-params19937.h
jemalloc-5.2.1/test/include/test/SFMT-params216091.h
jemalloc-5.2.1/test/include/test/SFMT-params2281.h
jemalloc-5.2.1/test/include/test/SFMT-params4253.h
jemalloc-5.2.1/test/include/test/SFMT-params44497.h
jemalloc-5.2.1/test/include/test/SFMT-params607.h
jemalloc-5.2.1/test/include/test/SFMT-params86243.h
jemalloc-5.2.1/test/include/test/SFMT-sse2.h
jemalloc-5.2.1/test/include/test/SFMT.h
jemalloc-5.2.1/test/include/test/btalloc.h
jemalloc-5.2.1/test/include/test/extent_hooks.h
jemalloc-5.2.1/test/include/test/jemalloc_test.h.in
jemalloc-5.2.1/test/include/test/jemalloc_test_defs.h.in
jemalloc-5.2.1/test/include/test/math.h
jemalloc-5.2.1/test/include/test/mq.h
jemalloc-5.2.1/test/include/test/mtx.h
jemalloc-5.2.1/test/include/test/test.h
jemalloc-5.2.1/test/include/test/thd.h
jemalloc-5.2.1/test/include/test/timer.h
jemalloc-5.2.1/test/integration/
jemalloc-5.2.1/test/integration/MALLOCX_ARENA.c
jemalloc-5.2.1/test/integration/aligned_alloc.c
jemalloc-5.2.1/test/integration/allocated.c
jemalloc-5.2.1/test/integration/cpp/
jemalloc-5.2.1/test/integration/cpp/basic.cpp
jemalloc-5.2.1/test/integration/extent.c
jemalloc-5.2.1/test/integration/extent.sh
jemalloc-5.2.1/test/integration/malloc.c
jemalloc-5.2.1/test/integration/mallocx.c
jemalloc-5.2.1/test/integration/mallocx.sh
jemalloc-5.2.1/test/integration/overflow.c
jemalloc-5.2.1/test/integration/posix_memalign.c
jemalloc-5.2.1/test/integration/rallocx.c
jemalloc-5.2.1/test/integration/sdallocx.c
jemalloc-5.2.1/test/integration/slab_sizes.c
jemalloc-5.2.1/test/integration/slab_sizes.sh
jemalloc-5.2.1/test/integration/smallocx.c
jemalloc-5.2.1/test/integration/smallocx.sh
jemalloc-5.2.1/test/integration/thread_arena.c
jemalloc-5.2.1/test/integration/thread_tcache_enabled.c
jemalloc-5.2.1/test/integration/xallocx.c
jemalloc-5.2.1/test/integration/xallocx.sh
jemalloc-5.2.1/test/src/
jemalloc-5.2.1/test/src/SFMT.c
jemalloc-5.2.1/test/src/btalloc.c
jemalloc-5.2.1/test/src/btalloc_0.c
jemalloc-5.2.1/test/src/btalloc_1.c
jemalloc-5.2.1/test/src/math.c
jemalloc-5.2.1/test/src/mq.c
jemalloc-5.2.1/test/src/mtx.c
jemalloc-5.2.1/test/src/test.c
jemalloc-5.2.1/test/src/thd.c
jemalloc-5.2.1/test/src/timer.c
jemalloc-5.2.1/test/stress/
jemalloc-5.2.1/test/stress/hookbench.c
jemalloc-5.2.1/test/stress/microbench.c
jemalloc-5.2.1/test/test.sh.in
jemalloc-5.2.1/test/unit/
jemalloc-5.2.1/test/unit/SFMT.c
jemalloc-5.2.1/test/unit/a0.c
jemalloc-5.2.1/test/unit/arena_reset.c
jemalloc-5.2.1/test/unit/arena_reset_prof.c
jemalloc-5.2.1/test/unit/arena_reset_prof.sh
jemalloc-5.2.1/test/unit/atomic.c
jemalloc-5.2.1/test/unit/background_thread.c
jemalloc-5.2.1/test/unit/background_thread_enable.c
jemalloc-5.2.1/test/unit/base.c
jemalloc-5.2.1/test/unit/binshard.c
jemalloc-5.2.1/test/unit/binshard.sh
jemalloc-5.2.1/test/unit/bit_util.c
jemalloc-5.2.1/test/unit/bitmap.c
jemalloc-5.2.1/test/unit/ckh.c
jemalloc-5.2.1/test/unit/decay.c
jemalloc-5.2.1/test/unit/decay.sh
jemalloc-5.2.1/test/unit/div.c
jemalloc-5.2.1/test/unit/emitter.c
jemalloc-5.2.1/test/unit/extent_quantize.c
jemalloc-5.2.1/test/unit/extent_util.c
jemalloc-5.2.1/test/unit/fork.c
jemalloc-5.2.1/test/unit/hash.c
jemalloc-5.2.1/test/unit/hook.c
jemalloc-5.2.1/test/unit/huge.c
jemalloc-5.2.1/test/unit/junk.c
jemalloc-5.2.1/test/unit/junk.sh
jemalloc-5.2.1/test/unit/junk_alloc.c
jemalloc-5.2.1/test/unit/junk_alloc.sh
jemalloc-5.2.1/test/unit/junk_free.c
jemalloc-5.2.1/test/unit/junk_free.sh
jemalloc-5.2.1/test/unit/log.c
jemalloc-5.2.1/test/unit/mallctl.c
jemalloc-5.2.1/test/unit/malloc_io.c
jemalloc-5.2.1/test/unit/math.c
jemalloc-5.2.1/test/unit/mq.c
jemalloc-5.2.1/test/unit/mtx.c
jemalloc-5.2.1/test/unit/nstime.c
jemalloc-5.2.1/test/unit/pack.c
jemalloc-5.2.1/test/unit/pack.sh
jemalloc-5.2.1/test/unit/pages.c
jemalloc-5.2.1/test/unit/ph.c
jemalloc-5.2.1/test/unit/prng.c
jemalloc-5.2.1/test/unit/prof_accum.c
jemalloc-5.2.1/test/unit/prof_accum.sh
jemalloc-5.2.1/test/unit/prof_active.c
jemalloc-5.2.1/test/unit/prof_active.sh
jemalloc-5.2.1/test/unit/prof_gdump.c
jemalloc-5.2.1/test/unit/prof_gdump.sh
jemalloc-5.2.1/test/unit/prof_idump.c
jemalloc-5.2.1/test/unit/prof_idump.sh
jemalloc-5.2.1/test/unit/prof_log.c
jemalloc-5.2.1/test/unit/prof_log.sh
jemalloc-5.2.1/test/unit/prof_reset.c
jemalloc-5.2.1/test/unit/prof_reset.sh
jemalloc-5.2.1/test/unit/prof_tctx.c
jemalloc-5.2.1/test/unit/prof_tctx.sh
jemalloc-5.2.1/test/unit/prof_thread_name.c
jemalloc-5.2.1/test/unit/prof_thread_name.sh
jemalloc-5.2.1/test/unit/ql.c
jemalloc-5.2.1/test/unit/qr.c
jemalloc-5.2.1/test/unit/rb.c
jemalloc-5.2.1/test/unit/retained.c
jemalloc-5.2.1/test/unit/rtree.c
jemalloc-5.2.1/test/unit/safety_check.c
jemalloc-5.2.1/test/unit/safety_check.sh
jemalloc-5.2.1/test/unit/sc.c
jemalloc-5.2.1/test/unit/seq.c
jemalloc-5.2.1/test/unit/size_classes.c
jemalloc-5.2.1/test/unit/slab.c
jemalloc-5.2.1/test/unit/smoothstep.c
jemalloc-5.2.1/test/unit/spin.c
jemalloc-5.2.1/test/unit/stats.c
jemalloc-5.2.1/test/unit/stats_print.c
jemalloc-5.2.1/test/unit/test_hooks.c
jemalloc-5.2.1/test/unit/ticker.c
jemalloc-5.2.1/test/unit/tsd.c
jemalloc-5.2.1/test/unit/witness.c
jemalloc-5.2.1/test/unit/zero.c
jemalloc-5.2.1/test/unit/zero.sh
jemalloc-5.2.1/VERSION
jemalloc-5.2.1/configure
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cd jemalloc-5.2.1/
root@ubuntu-s-1vcpu-1gb-blr1-01:~/jemalloc-5.2.1# ./configure
checking for xsltproc... false
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking whether compiler is cray... no
checking whether compiler supports -std=gnu11... yes
checking whether compiler supports -Wall... yes
checking whether compiler supports -Wextra... yes
checking whether compiler supports -Wshorten-64-to-32... no
checking whether compiler supports -Wsign-compare... yes
checking whether compiler supports -Wundef... yes
checking whether compiler supports -Wno-format-zero-length... yes
checking whether compiler supports -pipe... yes
checking whether compiler supports -g3... yes
checking how to run the C preprocessor... gcc -E
checking for g++... no
checking for c++... no
checking for gpp... no
checking for aCC... no
checking for CC... no
checking for cxx... no
checking for cc++... no
checking for cl.exe... no
checking for FCC... no
checking for KCC... no
checking for RCC... no
checking for xlC_r... no
checking for xlC... no
checking whether we are using the GNU C++ compiler... no
checking whether g++ accepts -g... no
checking whether g++ supports C++14 features by default... no
checking whether g++ supports C++14 features with -std=c++14... no
checking whether g++ supports C++14 features with -std=c++0x... no
checking whether g++ supports C++14 features with +std=c++14... no
checking whether g++ supports C++14 features with -h std=c++14... no
configure: No compiler with C++14 support was found
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking whether byte ordering is bigendian... no
checking size of void *... 8
checking size of int... 4
checking size of long... 8
checking size of long long... 8
checking size of intmax_t... 8
checking build system type... x86_64-pc-linux-gnu
checking host system type... x86_64-pc-linux-gnu
checking whether pause instruction is compilable... yes
checking number of significant virtual address bits... 48
checking for ar... ar
checking for nm... nm
checking for gawk... gawk
checking malloc.h usability... yes
checking malloc.h presence... yes
checking for malloc.h... yes
checking whether malloc_usable_size definition can use const argument... no
checking for library containing log... -lm
checking whether __attribute__ syntax is compilable... yes
checking whether compiler supports -fvisibility=hidden... yes
checking whether compiler supports -fvisibility=hidden... no
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether tls_model attribute is compilable... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether alloc_size attribute is compilable... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether format(gnu_printf, ...) attribute is compilable... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether format(printf, ...) attribute is compilable... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether format(printf, ...) attribute is compilable... yes
checking for a BSD-compatible install... /usr/bin/install -c
checking for ranlib... ranlib
checking for ld... /usr/bin/ld
checking for autoconf... false
checking for memalign... yes
checking for valloc... yes
checking for __libc_calloc... yes
checking for __libc_free... yes
checking for __libc_malloc... yes
checking for __libc_memalign... yes
checking for __libc_realloc... yes
checking for __libc_valloc... yes
checking for __posix_memalign... no
checking whether compiler supports -O3... yes
checking whether compiler supports -O3... no
checking whether compiler supports -funroll-loops... yes
checking configured backtracing method... N/A
checking for sbrk... yes
checking whether utrace(2) is compilable... no
checking whether a program using __builtin_unreachable is compilable... yes
checking whether a program using __builtin_ffsl is compilable... yes
checking whether a program using __builtin_popcountl is compilable... yes
checking LG_PAGE... 12
checking pthread.h usability... yes
checking pthread.h presence... yes
checking for pthread.h... yes
checking for pthread_create in -lpthread... yes
checking dlfcn.h usability... yes
checking dlfcn.h presence... yes
checking for dlfcn.h... yes
checking for dlsym... no
checking for dlsym in -ldl... yes
checking whether pthread_atfork(3) is compilable... yes
checking whether pthread_setname_np(3) is compilable... yes
checking for library containing clock_gettime... none required
checking whether clock_gettime(CLOCK_MONOTONIC_COARSE, ...) is compilable... yes
checking whether clock_gettime(CLOCK_MONOTONIC, ...) is compilable... yes
checking whether mach_absolute_time() is compilable... no
checking whether compiler supports -Werror... yes
checking whether syscall(2) is compilable... yes
checking for secure_getenv... yes
checking for sched_getcpu... yes
checking for sched_setaffinity... yes
checking for issetugid... no
checking for _malloc_thread_cleanup... no
checking for _pthread_mutex_init_calloc_cb... no
checking for TLS... yes
checking whether C11 atomics is compilable... yes
checking whether GCC __atomic atomics is compilable... yes
checking whether GCC 8-bit __atomic atomics is compilable... yes
checking whether GCC __sync atomics is compilable... yes
checking whether GCC 8-bit __sync atomics is compilable... yes
checking whether Darwin OSAtomic*() is compilable... no
checking whether madvise(2) is compilable... yes
checking whether madvise(..., MADV_FREE) is compilable... yes
checking whether madvise(..., MADV_DONTNEED) is compilable... yes
checking whether madvise(..., MADV_DO[NT]DUMP) is compilable... yes
checking whether madvise(..., MADV_[NO]HUGEPAGE) is compilable... yes
checking for __builtin_clz... yes
checking whether Darwin os_unfair_lock_*() is compilable... no
checking whether glibc malloc hook is compilable... yes
checking whether glibc memalign hook is compilable... yes
checking whether pthreads adaptive mutexes is compilable... yes
checking whether compiler supports -D_GNU_SOURCE... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether strerror_r returns char with gnu source is compilable... yes
checking for stdbool.h that conforms to C99... yes
checking for _Bool... yes
configure: creating ./config.status
config.status: creating Makefile
config.status: creating jemalloc.pc
config.status: creating doc/html.xsl
config.status: creating doc/manpages.xsl
config.status: creating doc/jemalloc.xml
config.status: creating include/jemalloc/jemalloc_macros.h
config.status: creating include/jemalloc/jemalloc_protos.h
config.status: creating include/jemalloc/jemalloc_typedefs.h
config.status: creating include/jemalloc/internal/jemalloc_preamble.h
config.status: creating test/test.sh
config.status: creating test/include/test/jemalloc_test.h
config.status: creating config.stamp
config.status: creating bin/jemalloc-config
config.status: creating bin/jemalloc.sh
config.status: creating bin/jeprof
config.status: creating include/jemalloc/jemalloc_defs.h
config.status: creating include/jemalloc/internal/jemalloc_internal_defs.h
config.status: creating test/include/test/jemalloc_test_defs.h
config.status: executing include/jemalloc/internal/public_symbols.txt commands
config.status: executing include/jemalloc/internal/private_symbols.awk commands
config.status: executing include/jemalloc/internal/private_symbols_jet.awk commands
config.status: executing include/jemalloc/internal/public_namespace.h commands
config.status: executing include/jemalloc/internal/public_unnamespace.h commands
config.status: executing include/jemalloc/jemalloc_protos_jet.h commands
config.status: executing include/jemalloc/jemalloc_rename.h commands
config.status: executing include/jemalloc/jemalloc_mangle.h commands
config.status: executing include/jemalloc/jemalloc_mangle_jet.h commands
config.status: executing include/jemalloc/jemalloc.h commands
===============================================================================
jemalloc version   : 5.2.1-0-gea6b3e973b477b8061e0076bb257dbd7f3faa756
library revision   : 2

CONFIG             :
CC                 : gcc
CONFIGURE_CFLAGS   : -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops
SPECIFIED_CFLAGS   :
EXTRA_CFLAGS       :
CPPFLAGS           : -D_GNU_SOURCE -D_REENTRANT
CXX                : g++
CONFIGURE_CXXFLAGS :
SPECIFIED_CXXFLAGS :
EXTRA_CXXFLAGS     :
LDFLAGS            :
EXTRA_LDFLAGS      :
DSO_LDFLAGS        : -shared -Wl,-soname,$(@F)
LIBS               : -lm  -pthread -ldl
RPATH_EXTRA        :

XSLTPROC           : false
XSLROOT            :

PREFIX             : /usr/local
BINDIR             : /usr/local/bin
DATADIR            : /usr/local/share
INCLUDEDIR         : /usr/local/include
LIBDIR             : /usr/local/lib
MANDIR             : /usr/local/share/man

srcroot            :
abs_srcroot        : /root/jemalloc-5.2.1/
objroot            :
abs_objroot        : /root/jemalloc-5.2.1/

JEMALLOC_PREFIX    :
JEMALLOC_PRIVATE_NAMESPACE
                   : je_
install_suffix     :
malloc_conf        :
documentation      : 1
shared libs        : 1
static libs        : 1
autogen            : 0
debug              : 0
stats              : 1
experimetal_smallocx : 0
prof               : 0
prof-libunwind     : 0
prof-libgcc        : 0
prof-gcc           : 0
fill               : 1
utrace             : 0
xmalloc            : 0
log                : 0
lazy_lock          : 0
cache-oblivious    : 1
cxx                : 0
===============================================================================
root@ubuntu-s-1vcpu-1gb-blr1-01:~/jemalloc-5.2.1# echo $?
0
root@ubuntu-s-1vcpu-1gb-blr1-01:~/jemalloc-5.2.1# make
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/jemalloc.sym.o src/jemalloc.c
src/jemalloc.c:2986:7: warning: ‘__libc_calloc’ specifies less restrictive attributes than its target ‘calloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2986 | void *__libc_calloc(size_t n, size_t size) PREALIAS(je_calloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:542:14: note: ‘__libc_calloc’ target declared here
  542 | extern void *calloc (size_t __nmemb, size_t __size)
      |              ^~~~~~
src/jemalloc.c:3001:7: warning: ‘__libc_valloc’ specifies less restrictive attributes than its target ‘valloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 3001 | void *__libc_valloc(size_t size) PREALIAS(je_valloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:574:14: note: ‘__libc_valloc’ target declared here
  574 | extern void *valloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2998:7: warning: ‘__libc_realloc’ specifies less restrictive attributes than its target ‘realloc’: ‘alloc_size’, ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2998 | void *__libc_realloc(void* ptr, size_t size) PREALIAS(je_realloc);
      |       ^~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:550:14: note: ‘__libc_realloc’ target declared here
  550 | extern void *realloc (void *__ptr, size_t __size)
      |              ^~~~~~~
src/jemalloc.c:2995:7: warning: ‘__libc_memalign’ specifies less restrictive attributes than its target ‘memalign’: ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2995 | void *__libc_memalign(size_t align, size_t s) PREALIAS(je_memalign);
      |       ^~~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_preamble.h:21,
                 from src/jemalloc.c:2:
include/jemalloc/internal/../jemalloc.h:83:23: note: ‘__libc_memalign’ target declared here
   83 | #  define je_memalign memalign
      |                       ^~~~~~~~
src/jemalloc.c:2885:1: note: in expansion of macro ‘je_memalign’
 2885 | je_memalign(size_t alignment, size_t size) {
      | ^~~~~~~~~~~
src/jemalloc.c:2992:7: warning: ‘__libc_malloc’ specifies less restrictive attributes than its target ‘malloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2992 | void *__libc_malloc(size_t size) PREALIAS(je_malloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:539:14: note: ‘__libc_malloc’ target declared here
  539 | extern void *malloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2989:6: warning: ‘__libc_free’ specifies less restrictive attributes than its target ‘free’: ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2989 | void __libc_free(void* ptr) PREALIAS(je_free);
      |      ^~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:565:13: note: ‘__libc_free’ target declared here
  565 | extern void free (void *__ptr) __THROW;
      |             ^~~~
nm -a src/jemalloc.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/jemalloc.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/arena.sym.o src/arena.c
nm -a src/arena.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/arena.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/background_thread.sym.o src/background_thread.c
nm -a src/background_thread.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/background_thread.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/base.sym.o src/base.c
nm -a src/base.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/base.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/bin.sym.o src/bin.c
nm -a src/bin.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/bin.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/bitmap.sym.o src/bitmap.c
nm -a src/bitmap.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/bitmap.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/ckh.sym.o src/ckh.c
nm -a src/ckh.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/ckh.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/ctl.sym.o src/ctl.c
nm -a src/ctl.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/ctl.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/div.sym.o src/div.c
nm -a src/div.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/div.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/extent.sym.o src/extent.c
nm -a src/extent.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/extent.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/extent_dss.sym.o src/extent_dss.c
nm -a src/extent_dss.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/extent_dss.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/extent_mmap.sym.o src/extent_mmap.c
nm -a src/extent_mmap.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/extent_mmap.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/hash.sym.o src/hash.c
nm -a src/hash.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/hash.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/hook.sym.o src/hook.c
nm -a src/hook.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/hook.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/large.sym.o src/large.c
nm -a src/large.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/large.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/log.sym.o src/log.c
nm -a src/log.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/log.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/malloc_io.sym.o src/malloc_io.c
nm -a src/malloc_io.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/malloc_io.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/mutex.sym.o src/mutex.c
nm -a src/mutex.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/mutex.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/mutex_pool.sym.o src/mutex_pool.c
nm -a src/mutex_pool.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/mutex_pool.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/nstime.sym.o src/nstime.c
nm -a src/nstime.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/nstime.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/pages.sym.o src/pages.c
nm -a src/pages.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/pages.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/prng.sym.o src/prng.c
nm -a src/prng.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/prng.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/prof.sym.o src/prof.c
nm -a src/prof.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/prof.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/rtree.sym.o src/rtree.c
nm -a src/rtree.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/rtree.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/safety_check.sym.o src/safety_check.c
nm -a src/safety_check.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/safety_check.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/stats.sym.o src/stats.c
nm -a src/stats.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/stats.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/sc.sym.o src/sc.c
nm -a src/sc.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/sc.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/sz.sym.o src/sz.c
nm -a src/sz.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/sz.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/tcache.sym.o src/tcache.c
nm -a src/tcache.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/tcache.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/test_hooks.sym.o src/test_hooks.c
nm -a src/test_hooks.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/test_hooks.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/ticker.sym.o src/ticker.c
nm -a src/ticker.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/ticker.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/tsd.sym.o src/tsd.c
nm -a src/tsd.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/tsd.sym
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/witness.sym.o src/witness.c
nm -a src/witness.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/witness.sym
/bin/sh include/jemalloc/internal/private_namespace.sh src/jemalloc.sym src/arena.sym src/background_thread.sym src/base.sym src/bin.sym src/bitmap.sym src/ckh.sym src/ctl.sym src/div.sym src/extent.sym src/extent_dss.sym src/extent_mmap.sym src/hash.sym src/hook.sym src/large.sym src/log.sym src/malloc_io.sym src/mutex.sym src/mutex_pool.sym src/nstime.sym src/pages.sym src/prng.sym src/prof.sym src/rtree.sym src/safety_check.sym src/stats.sym src/sc.sym src/sz.sym src/tcache.sym src/test_hooks.sym src/ticker.sym src/tsd.sym src/witness.sym > include/jemalloc/internal/private_namespace.gen.h
cp include/jemalloc/internal/private_namespace.gen.h include/jemalloc/internal/private_namespace.gen.h
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/jemalloc.pic.o src/jemalloc.c
src/jemalloc.c:2986:7: warning: ‘__libc_calloc’ specifies less restrictive attributes than its target ‘calloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2986 | void *__libc_calloc(size_t n, size_t size) PREALIAS(je_calloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:542:14: note: ‘__libc_calloc’ target declared here
  542 | extern void *calloc (size_t __nmemb, size_t __size)
      |              ^~~~~~
src/jemalloc.c:3001:7: warning: ‘__libc_valloc’ specifies less restrictive attributes than its target ‘valloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 3001 | void *__libc_valloc(size_t size) PREALIAS(je_valloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:574:14: note: ‘__libc_valloc’ target declared here
  574 | extern void *valloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2998:7: warning: ‘__libc_realloc’ specifies less restrictive attributes than its target ‘realloc’: ‘alloc_size’, ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2998 | void *__libc_realloc(void* ptr, size_t size) PREALIAS(je_realloc);
      |       ^~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:550:14: note: ‘__libc_realloc’ target declared here
  550 | extern void *realloc (void *__ptr, size_t __size)
      |              ^~~~~~~
src/jemalloc.c:2995:7: warning: ‘__libc_memalign’ specifies less restrictive attributes than its target ‘memalign’: ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2995 | void *__libc_memalign(size_t align, size_t s) PREALIAS(je_memalign);
      |       ^~~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_preamble.h:21,
                 from src/jemalloc.c:2:
include/jemalloc/internal/../jemalloc.h:83:23: note: ‘__libc_memalign’ target declared here
   83 | #  define je_memalign memalign
      |                       ^~~~~~~~
src/jemalloc.c:2885:1: note: in expansion of macro ‘je_memalign’
 2885 | je_memalign(size_t alignment, size_t size) {
      | ^~~~~~~~~~~
src/jemalloc.c:2992:7: warning: ‘__libc_malloc’ specifies less restrictive attributes than its target ‘malloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2992 | void *__libc_malloc(size_t size) PREALIAS(je_malloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:539:14: note: ‘__libc_malloc’ target declared here
  539 | extern void *malloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2989:6: warning: ‘__libc_free’ specifies less restrictive attributes than its target ‘free’: ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2989 | void __libc_free(void* ptr) PREALIAS(je_free);
      |      ^~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:565:13: note: ‘__libc_free’ target declared here
  565 | extern void free (void *__ptr) __THROW;
      |             ^~~~
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/arena.pic.o src/arena.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/background_thread.pic.o src/background_thread.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/base.pic.o src/base.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bin.pic.o src/bin.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bitmap.pic.o src/bitmap.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ckh.pic.o src/ckh.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ctl.pic.o src/ctl.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/div.pic.o src/div.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent.pic.o src/extent.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_dss.pic.o src/extent_dss.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_mmap.pic.o src/extent_mmap.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hash.pic.o src/hash.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hook.pic.o src/hook.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/large.pic.o src/large.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/log.pic.o src/log.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/malloc_io.pic.o src/malloc_io.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex.pic.o src/mutex.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex_pool.pic.o src/mutex_pool.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/nstime.pic.o src/nstime.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/pages.pic.o src/pages.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prng.pic.o src/prng.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prof.pic.o src/prof.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/rtree.pic.o src/rtree.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/safety_check.pic.o src/safety_check.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/stats.pic.o src/stats.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/sc.pic.o src/sc.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/sz.pic.o src/sz.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tcache.pic.o src/tcache.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/test_hooks.pic.o src/test_hooks.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ticker.pic.o src/ticker.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tsd.pic.o src/tsd.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/witness.pic.o src/witness.c
gcc -shared -Wl,-soname,libjemalloc.so.2  -o lib/libjemalloc.so.2 src/jemalloc.pic.o src/arena.pic.o src/background_thread.pic.o src/base.pic.o src/bin.pic.o src/bitmap.pic.o src/ckh.pic.o src/ctl.pic.o src/div.pic.o src/extent.pic.o src/extent_dss.pic.o src/extent_mmap.pic.o src/hash.pic.o src/hook.pic.o src/large.pic.o src/log.pic.o src/malloc_io.pic.o src/mutex.pic.o src/mutex_pool.pic.o src/nstime.pic.o src/pages.pic.o src/prng.pic.o src/prof.pic.o src/rtree.pic.o src/safety_check.pic.o src/stats.pic.o src/sc.pic.o src/sz.pic.o src/tcache.pic.o src/test_hooks.pic.o src/ticker.pic.o src/tsd.pic.o src/witness.pic.o  -lm  -pthread -ldl
ln -sf libjemalloc.so.2 lib/libjemalloc.so
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/jemalloc.o src/jemalloc.c
src/jemalloc.c:2986:7: warning: ‘__libc_calloc’ specifies less restrictive attributes than its target ‘calloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2986 | void *__libc_calloc(size_t n, size_t size) PREALIAS(je_calloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:542:14: note: ‘__libc_calloc’ target declared here
  542 | extern void *calloc (size_t __nmemb, size_t __size)
      |              ^~~~~~
src/jemalloc.c:3001:7: warning: ‘__libc_valloc’ specifies less restrictive attributes than its target ‘valloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 3001 | void *__libc_valloc(size_t size) PREALIAS(je_valloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:574:14: note: ‘__libc_valloc’ target declared here
  574 | extern void *valloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2998:7: warning: ‘__libc_realloc’ specifies less restrictive attributes than its target ‘realloc’: ‘alloc_size’, ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2998 | void *__libc_realloc(void* ptr, size_t size) PREALIAS(je_realloc);
      |       ^~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:550:14: note: ‘__libc_realloc’ target declared here
  550 | extern void *realloc (void *__ptr, size_t __size)
      |              ^~~~~~~
src/jemalloc.c:2995:7: warning: ‘__libc_memalign’ specifies less restrictive attributes than its target ‘memalign’: ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2995 | void *__libc_memalign(size_t align, size_t s) PREALIAS(je_memalign);
      |       ^~~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_preamble.h:21,
                 from src/jemalloc.c:2:
include/jemalloc/internal/../jemalloc.h:83:23: note: ‘__libc_memalign’ target declared here
   83 | #  define je_memalign memalign
      |                       ^~~~~~~~
src/jemalloc.c:2885:1: note: in expansion of macro ‘je_memalign’
 2885 | je_memalign(size_t alignment, size_t size) {
      | ^~~~~~~~~~~
src/jemalloc.c:2992:7: warning: ‘__libc_malloc’ specifies less restrictive attributes than its target ‘malloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2992 | void *__libc_malloc(size_t size) PREALIAS(je_malloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:539:14: note: ‘__libc_malloc’ target declared here
  539 | extern void *malloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2989:6: warning: ‘__libc_free’ specifies less restrictive attributes than its target ‘free’: ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2989 | void __libc_free(void* ptr) PREALIAS(je_free);
      |      ^~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:63,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:565:13: note: ‘__libc_free’ target declared here
  565 | extern void free (void *__ptr) __THROW;
      |             ^~~~
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/arena.o src/arena.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/background_thread.o src/background_thread.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/base.o src/base.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bin.o src/bin.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bitmap.o src/bitmap.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ckh.o src/ckh.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ctl.o src/ctl.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/div.o src/div.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent.o src/extent.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_dss.o src/extent_dss.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_mmap.o src/extent_mmap.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hash.o src/hash.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hook.o src/hook.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/large.o src/large.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/log.o src/log.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/malloc_io.o src/malloc_io.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex.o src/mutex.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex_pool.o src/mutex_pool.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/nstime.o src/nstime.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/pages.o src/pages.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prng.o src/prng.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prof.o src/prof.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/rtree.o src/rtree.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/safety_check.o src/safety_check.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/stats.o src/stats.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/sc.o src/sc.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/sz.o src/sz.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tcache.o src/tcache.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/test_hooks.o src/test_hooks.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ticker.o src/ticker.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tsd.o src/tsd.c
gcc -std=gnu11 -Wall -Wextra -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/witness.o src/witness.c
ar crus lib/libjemalloc.a src/jemalloc.o src/arena.o src/background_thread.o src/base.o src/bin.o src/bitmap.o src/ckh.o src/ctl.o src/div.o src/extent.o src/extent_dss.o src/extent_mmap.o src/hash.o src/hook.o src/large.o src/log.o src/malloc_io.o src/mutex.o src/mutex_pool.o src/nstime.o src/pages.o src/prng.o src/prof.o src/rtree.o src/safety_check.o src/stats.o src/sc.o src/sz.o src/tcache.o src/test_hooks.o src/ticker.o src/tsd.o src/witness.o
ar: `u' modifier ignored since `D' is the default (see `U')
ar crus lib/libjemalloc_pic.a src/jemalloc.pic.o src/arena.pic.o src/background_thread.pic.o src/base.pic.o src/bin.pic.o src/bitmap.pic.o src/ckh.pic.o src/ctl.pic.o src/div.pic.o src/extent.pic.o src/extent_dss.pic.o src/extent_mmap.pic.o src/hash.pic.o src/hook.pic.o src/large.pic.o src/log.pic.o src/malloc_io.pic.o src/mutex.pic.o src/mutex_pool.pic.o src/nstime.pic.o src/pages.pic.o src/prng.pic.o src/prof.pic.o src/rtree.pic.o src/safety_check.pic.o src/stats.pic.o src/sc.pic.o src/sz.pic.o src/tcache.pic.o src/test_hooks.pic.o src/ticker.pic.o src/tsd.pic.o src/witness.pic.o
ar: `u' modifier ignored since `D' is the default (see `U')
root@ubuntu-s-1vcpu-1gb-blr1-01:~/jemalloc-5.2.1# echo $?
0
root@ubuntu-s-1vcpu-1gb-blr1-01:~/jemalloc-5.2.1# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cd redis-6.2.6/^C
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:/# cd -
/root
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cd jemalloc-5.2.1/
root@ubuntu-s-1vcpu-1gb-blr1-01:~/jemalloc-5.2.1# make install
/usr/bin/install -c -d /usr/local/bin
/usr/bin/install -c -m 755 bin/jemalloc-config /usr/local/bin
/usr/bin/install -c -m 755 bin/jemalloc.sh /usr/local/bin
/usr/bin/install -c -m 755 bin/jeprof /usr/local/bin
/usr/bin/install -c -d /usr/local/include/jemalloc
/usr/bin/install -c -m 644 include/jemalloc/jemalloc.h /usr/local/include/jemalloc
/usr/bin/install -c -d /usr/local/lib
/usr/bin/install -c -m 755 lib/libjemalloc.so.2 /usr/local/lib
ln -sf libjemalloc.so.2 /usr/local/lib/libjemalloc.so
/usr/bin/install -c -d /usr/local/lib
/usr/bin/install -c -m 755 lib/libjemalloc.a /usr/local/lib
/usr/bin/install -c -m 755 lib/libjemalloc_pic.a /usr/local/lib
/usr/bin/install -c -d /usr/local/lib/pkgconfig
/usr/bin/install -c -m 644 jemalloc.pc /usr/local/lib/pkgconfig
Missing xsltproc.  doc/jemalloc.html not (re)built.
Missing xsltproc.  doc/jemalloc.3 not (re)built.
/usr/bin/install -c -d /usr/local/share/doc/jemalloc
/usr/bin/install -c -m 644 doc/jemalloc.html /usr/local/share/doc/jemalloc
/usr/bin/install -c -d /usr/local/share/man/man3
/usr/bin/install -c -m 644 doc/jemalloc.3 /usr/local/share/man/man3
root@ubuntu-s-1vcpu-1gb-blr1-01:~/jemalloc-5.2.1# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cd redis-6.2.6/
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# make
cd src && make all
make[1]: Entering directory '/root/redis-6.2.6/src'
/bin/sh: 1: pkg-config: not found
    CC adlist.o
    CC quicklist.o
    CC ae.o
    CC anet.o
    CC dict.o
    CC server.o
In file included from server.h:65,
                 from server.c:30:
server.c: In function ‘clientsCronTrackExpansiveClients’:
zmalloc.h:53:25: warning: implicit declaration of function ‘je_malloc_usable_size’; did you mean ‘malloc_usable_size’? [-Wimplicit-function-declaration]
   53 | #define zmalloc_size(p) je_malloc_usable_size(p)
      |                         ^~~~~~~~~~~~~~~~~~~~~
server.c:1733:27: note: in expansion of macro ‘zmalloc_size’
 1733 |                (c->argv ? zmalloc_size(c->argv) : 0);
      |                           ^~~~~~~~~~~~
    CC sds.o
    CC zmalloc.o
zmalloc.c: In function ‘ztrymalloc_usable’:
zmalloc.c:75:22: warning: implicit declaration of function ‘je_malloc’; did you mean ‘zmalloc’? [-Wimplicit-function-declaration]
   75 | #define malloc(size) je_malloc(size)
      |                      ^~~~~~~~~
zmalloc.c:101:17: note: in expansion of macro ‘malloc’
  101 |     void *ptr = malloc(MALLOC_MIN_SIZE(size)+PREFIX_SIZE);
      |                 ^~~~~~
zmalloc.c:75:22: warning: initialization of ‘void *’ from ‘int’ makes pointer from integer without a cast [-Wint-conversion]
   75 | #define malloc(size) je_malloc(size)
      |                      ^~~~~~~~~
zmalloc.c:101:17: note: in expansion of macro ‘malloc’
  101 |     void *ptr = malloc(MALLOC_MIN_SIZE(size)+PREFIX_SIZE);
      |                 ^~~~~~
In file included from zmalloc.c:48:
zmalloc.h:53:25: warning: implicit declaration of function ‘je_malloc_usable_size’; did you mean ‘malloc_usable_size’? [-Wimplicit-function-declaration]
   53 | #define zmalloc_size(p) je_malloc_usable_size(p)
      |                         ^~~~~~~~~~~~~~~~~~~~~
zmalloc.c:105:12: note: in expansion of macro ‘zmalloc_size’
  105 |     size = zmalloc_size(ptr);
      |            ^~~~~~~~~~~~
zmalloc.c: In function ‘ztrycalloc_usable’:
zmalloc.c:76:28: warning: implicit declaration of function ‘je_calloc’; did you mean ‘zcalloc’? [-Wimplicit-function-declaration]
   76 | #define calloc(count,size) je_calloc(count,size)
      |                            ^~~~~~~~~
zmalloc.c:161:17: note: in expansion of macro ‘calloc’
  161 |     void *ptr = calloc(1, MALLOC_MIN_SIZE(size)+PREFIX_SIZE);
      |                 ^~~~~~
zmalloc.c:76:28: warning: initialization of ‘void *’ from ‘int’ makes pointer from integer without a cast [-Wint-conversion]
   76 | #define calloc(count,size) je_calloc(count,size)
      |                            ^~~~~~~~~
zmalloc.c:161:17: note: in expansion of macro ‘calloc’
  161 |     void *ptr = calloc(1, MALLOC_MIN_SIZE(size)+PREFIX_SIZE);
      |                 ^~~~~~
zmalloc.c: In function ‘ztryrealloc_usable’:
zmalloc.c:77:27: warning: implicit declaration of function ‘je_realloc’; did you mean ‘zrealloc’? [-Wimplicit-function-declaration]
   77 | #define realloc(ptr,size) je_realloc(ptr,size)
      |                           ^~~~~~~~~~
zmalloc.c:220:14: note: in expansion of macro ‘realloc’
  220 |     newptr = realloc(ptr,size);
      |              ^~~~~~~
zmalloc.c:220:12: warning: assignment to ‘void *’ from ‘int’ makes pointer from integer without a cast [-Wint-conversion]
  220 |     newptr = realloc(ptr,size);
      |            ^
zmalloc.c: In function ‘zfree’:
zmalloc.c:78:19: warning: implicit declaration of function ‘je_free’; did you mean ‘zfree’? [-Wimplicit-function-declaration]
   78 | #define free(ptr) je_free(ptr)
      |                   ^~~~~~~
zmalloc.c:292:5: note: in expansion of macro ‘free’
  292 |     free(ptr);
      |     ^~~~
zmalloc.c: In function ‘zmalloc_get_allocator_info’:
zmalloc.c:485:5: warning: implicit declaration of function ‘je_mallctl’; did you mean ‘mallctl’? [-Wimplicit-function-declaration]
  485 |     je_mallctl("epoch", &epoch, &sz, &epoch, sz);
      |     ^~~~~~~~~~
      |     mallctl
    CC lzf_c.o
    CC lzf_d.o
    CC pqsort.o
    CC zipmap.o
    CC sha1.o
    CC ziplist.o
    CC release.o
    CC networking.o
In file included from server.h:65,
                 from networking.c:30:
networking.c: In function ‘sdsZmallocSize’:
zmalloc.h:53:25: warning: implicit declaration of function ‘je_malloc_usable_size’; did you mean ‘malloc_usable_size’? [-Wimplicit-function-declaration]
   53 | #define zmalloc_size(p) je_malloc_usable_size(p)
      |                         ^~~~~~~~~~~~~~~~~~~~~
networking.c:47:12: note: in expansion of macro ‘zmalloc_size’
   47 |     return zmalloc_size(sh);
      |            ^~~~~~~~~~~~
    CC util.o
    CC object.o
In file included from server.h:65,
                 from object.c:31:
object.c: In function ‘objectComputeSize’:
zmalloc.h:53:25: warning: implicit declaration of function ‘je_malloc_usable_size’; did you mean ‘malloc_usable_size’? [-Wimplicit-function-declaration]
   53 | #define zmalloc_size(p) je_malloc_usable_size(p)
      |                         ^~~~~~~~~~~~~~~~~~~~~
object.c:867:21: note: in expansion of macro ‘zmalloc_size’
  867 |                     zmalloc_size(zsl->header);
      |                     ^~~~~~~~~~~~
object.c: In function ‘memoryCommand’:
object.c:1454:9: warning: implicit declaration of function ‘je_malloc_stats_print’; did you mean ‘malloc_stats_print’? [-Wimplicit-function-declaration]
 1454 |         je_malloc_stats_print(inputCatSds, &info, NULL);
      |         ^~~~~~~~~~~~~~~~~~~~~
      |         malloc_stats_print
    CC db.o
    CC replication.o
    CC rdb.o
    CC t_string.o
    CC t_list.o
    CC t_set.o
    CC t_zset.o
    CC t_hash.o
    CC config.o
    CC aof.o
    CC pubsub.o
    CC multi.o
    CC debug.o
debug.c: In function ‘mallctl_int’:
debug.c:328:18: warning: implicit declaration of function ‘je_mallctl’; did you mean ‘mallctl’? [-Wimplicit-function-declaration]
  328 |         if ((ret=je_mallctl(argv[0]->ptr, &old, &sz, argc > 1? &val: NULL, argc > 1?sz: 0))) {
      |                  ^~~~~~~~~~
      |                  mallctl
    CC sort.o
    CC intset.o
    CC syncio.o
    CC cluster.o
    CC crc16.o
    CC endianconv.o
    CC slowlog.o
    CC scripting.o
    CC bio.o
    CC rio.o
    CC rand.o
    CC memtest.o
    CC crcspeed.o
    CC crc64.o
    CC bitops.o
    CC sentinel.o
    CC notify.o
    CC setproctitle.o
    CC blocked.o
    CC hyperloglog.o
    CC latency.o
    CC sparkline.o
    CC redis-check-rdb.o
    CC redis-check-aof.o
    CC geo.o
    CC lazyfree.o
    CC module.o
In file included from server.h:65,
                 from module.c:54:
module.c: In function ‘RM_MallocSize’:
zmalloc.h:53:25: warning: implicit declaration of function ‘je_malloc_usable_size’; did you mean ‘malloc_usable_size’? [-Wimplicit-function-declaration]
   53 | #define zmalloc_size(p) je_malloc_usable_size(p)
      |                         ^~~~~~~~~~~~~~~~~~~~~
module.c:7558:12: note: in expansion of macro ‘zmalloc_size’
 7558 |     return zmalloc_size(ptr);
      |            ^~~~~~~~~~~~
    CC evict.o
    CC expire.o
    CC geohash.o
    CC geohash_helper.o
    CC childinfo.o
    CC defrag.o
    CC siphash.o
    CC rax.o
    CC t_stream.o
    CC listpack.o
In file included from listpack_malloc.h:41,
                 from listpack.c:44:
listpack.c: In function ‘lpShrinkToFit’:
zmalloc.h:53:25: warning: implicit declaration of function ‘je_malloc_usable_size’; did you mean ‘malloc_usable_size’? [-Wimplicit-function-declaration]
   53 | #define zmalloc_size(p) je_malloc_usable_size(p)
      |                         ^~~~~~~~~~~~~~~~~~~~~
zmalloc.h:134:32: note: in expansion of macro ‘zmalloc_size’
  134 | #define zmalloc_usable_size(p) zmalloc_size(p)
      |                                ^~~~~~~~~~~~
listpack_malloc.h:45:24: note: in expansion of macro ‘zmalloc_usable_size’
   45 | #define lp_malloc_size zmalloc_usable_size
      |                        ^~~~~~~~~~~~~~~~~~~
listpack.c:245:16: note: in expansion of macro ‘lp_malloc_size’
  245 |     if (size < lp_malloc_size(lp)) {
      |                ^~~~~~~~~~~~~~
listpack.c:245:14: warning: comparison of integer expressions of different signedness: ‘size_t’ {aka ‘long unsigned int’} and ‘int’ [-Wsign-compare]
  245 |     if (size < lp_malloc_size(lp)) {
      |              ^
listpack.c: In function ‘lpInsert’:
listpack.c:722:28: warning: comparison of integer expressions of different signedness: ‘uint64_t’ {aka ‘long unsigned int’} and ‘int’ [-Wsign-compare]
  722 |         new_listpack_bytes > lp_malloc_size(lp)) {
      |                            ^
    CC localtime.o
    CC lolwut.o
    CC lolwut5.o
    CC lolwut6.o
    CC acl.o
    CC gopher.o
    CC tracking.o
    CC connection.o
    CC tls.o
    CC sha256.o
    CC timeout.o
    CC setcpuaffinity.o
    CC monotonic.o
    CC mt19937-64.o
    LINK redis-server
cc: error: ../deps/hiredis/libhiredis.a: No such file or directory
cc: error: ../deps/lua/src/liblua.a: No such file or directory
cc: error: ../deps/jemalloc/lib/libjemalloc.a: No such file or directory
make[1]: *** [Makefile:345: redis-server] Error 1
make[1]: Leaving directory '/root/redis-6.2.6/src'
make: *** [Makefile:6: all] Error 2
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# ls deps/
Makefile  README.md  hdr_histogram  hiredis  jemalloc  linenoise  lua  update-jemalloc.sh
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# ls deps/hiredis
CHANGELOG.md    alloc.c          dict.c                   hiredis.h                    net.h       sdscompat.h   win32.h
CMakeLists.txt  alloc.h          dict.h                   hiredis.pc.in                read.c      sockcompat.c
COPYING         appveyor.yml     examples                 hiredis_ssl-config.cmake.in  read.h      sockcompat.h
Makefile        async.c          fmacros.h                hiredis_ssl.h                sds.c       ssl.c
README.md       async.h          hiredis-config.cmake.in  hiredis_ssl.pc.in            sds.h       test.c
adapters        async_private.h  hiredis.c                net.c                        sdsalloc.h  test.sh
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# cd deps/hiredis/
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/hiredis# ls
CHANGELOG.md    alloc.c          dict.c                   hiredis.h                    net.h       sdscompat.h   win32.h
CMakeLists.txt  alloc.h          dict.h                   hiredis.pc.in                read.c      sockcompat.c
COPYING         appveyor.yml     examples                 hiredis_ssl-config.cmake.in  read.h      sockcompat.h
Makefile        async.c          fmacros.h                hiredis_ssl.h                sds.c       ssl.c
README.md       async.h          hiredis-config.cmake.in  hiredis_ssl.pc.in            sds.h       test.c
adapters        async_private.h  hiredis.c                net.c                        sdsalloc.h  test.sh
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/hiredis# make
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb alloc.c
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb net.c
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb hiredis.c
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb sds.c
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb async.c
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb read.c
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb sockcompat.c
cc -shared -Wl,-soname,libhiredis.so.1.0.0 -o libhiredis.so alloc.o net.o hiredis.o sds.o async.o read.o sockcompat.o
ar rcs libhiredis.a alloc.o net.o hiredis.o sds.o async.o read.o sockcompat.o
cc -std=c99 -pedantic -c -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb test.c
cc -o hiredis-test -O3 -fPIC   -Wall -W -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -g -ggdb -I. test.o libhiredis.a
Generating hiredis.pc for pkgconfig...
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/hiredis# ls libhiredis.
ls: cannot access 'libhiredis.': No such file or directory
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/hiredis# ls libhiredis.a
libhiredis.a
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/hiredis# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps# ls
Makefile  README.md  hdr_histogram  hiredis  jemalloc  linenoise  lua  update-jemalloc.sh
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps# cd jemalloc/
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc# ls
COPYING     Makefile.in  VERSION     build-aux        configure.ac  jemalloc.pc.in  run_tests.sh  test
ChangeLog   README       autogen.sh  config.stamp.in  doc           m4              scripts
INSTALL.md  TUNING.md    bin         configure        include       msvc            src
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc# ./configure
checking for xsltproc... false
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking whether compiler is cray... no
checking whether compiler supports -std=gnu11... yes
checking whether compiler supports -Wall... yes
checking whether compiler supports -Wshorten-64-to-32... no
checking whether compiler supports -Wsign-compare... yes
checking whether compiler supports -Wundef... yes
checking whether compiler supports -Wno-format-zero-length... yes
checking whether compiler supports -pipe... yes
checking whether compiler supports -g3... yes
checking how to run the C preprocessor... gcc -E
checking for g++... no
checking for c++... no
checking for gpp... no
checking for aCC... no
checking for CC... no
checking for cxx... no
checking for cc++... no
checking for cl.exe... no
checking for FCC... no
checking for KCC... no
checking for RCC... no
checking for xlC_r... no
checking for xlC... no
checking whether we are using the GNU C++ compiler... no
checking whether g++ accepts -g... no
checking whether g++ supports C++14 features by default... no
checking whether g++ supports C++14 features with -std=c++14... no
checking whether g++ supports C++14 features with -std=c++0x... no
checking whether g++ supports C++14 features with +std=c++14... no
checking whether g++ supports C++14 features with -h std=c++14... no
configure: No compiler with C++14 support was found
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking whether byte ordering is bigendian... no
checking size of void *... 8
checking size of int... 4
checking size of long... 8
checking size of long long... 8
checking size of intmax_t... 8
checking build system type... x86_64-pc-linux-gnu
checking host system type... x86_64-pc-linux-gnu
checking whether pause instruction is compilable... yes
checking number of significant virtual address bits... 48
checking for ar... ar
checking for nm... nm
checking for gawk... gawk
checking malloc.h usability... yes
checking malloc.h presence... yes
checking for malloc.h... yes
checking whether malloc_usable_size definition can use const argument... no
checking for library containing log... -lm
checking whether __attribute__ syntax is compilable... yes
checking whether compiler supports -fvisibility=hidden... yes
checking whether compiler supports -fvisibility=hidden... no
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether tls_model attribute is compilable... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether alloc_size attribute is compilable... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether format(gnu_printf, ...) attribute is compilable... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether format(printf, ...) attribute is compilable... yes
checking for a BSD-compatible install... /usr/bin/install -c
checking for ranlib... ranlib
checking for ld... /usr/bin/ld
checking for autoconf... false
checking for memalign... yes
checking for valloc... yes
checking for __libc_calloc... yes
checking for __libc_free... yes
checking for __libc_malloc... yes
checking for __libc_memalign... yes
checking for __libc_realloc... yes
checking for __libc_valloc... yes
checking for __posix_memalign... no
checking whether compiler supports -O3... yes
checking whether compiler supports -O3... no
checking whether compiler supports -funroll-loops... yes
checking configured backtracing method... N/A
checking for sbrk... yes
checking whether utrace(2) is compilable... no
checking whether a program using __builtin_unreachable is compilable... yes
checking whether a program using __builtin_ffsl is compilable... yes
checking LG_PAGE... 12
checking pthread.h usability... yes
checking pthread.h presence... yes
checking for pthread.h... yes
checking for pthread_create in -lpthread... yes
checking dlfcn.h usability... yes
checking dlfcn.h presence... yes
checking for dlfcn.h... yes
checking for dlsym... no
checking for dlsym in -ldl... yes
checking whether pthread_atfork(3) is compilable... yes
checking whether pthread_setname_np(3) is compilable... yes
checking for library containing clock_gettime... none required
checking whether clock_gettime(CLOCK_MONOTONIC_COARSE, ...) is compilable... yes
checking whether clock_gettime(CLOCK_MONOTONIC, ...) is compilable... yes
checking whether mach_absolute_time() is compilable... no
checking whether compiler supports -Werror... yes
checking whether syscall(2) is compilable... yes
checking for secure_getenv... yes
checking for sched_getcpu... yes
checking for sched_setaffinity... yes
checking for issetugid... no
checking for _malloc_thread_cleanup... no
checking for _pthread_mutex_init_calloc_cb... no
checking for TLS... yes
checking whether C11 atomics is compilable... yes
checking whether GCC __atomic atomics is compilable... yes
checking whether GCC __sync atomics is compilable... yes
checking whether Darwin OSAtomic*() is compilable... no
checking whether madvise(2) is compilable... yes
checking whether madvise(..., MADV_FREE) is compilable... yes
checking whether madvise(..., MADV_DONTNEED) is compilable... yes
checking whether madvise(..., MADV_DO[NT]DUMP) is compilable... yes
checking whether madvise(..., MADV_[NO]HUGEPAGE) is compilable... yes
checking whether to force 32-bit __sync_{add,sub}_and_fetch()... no
checking whether to force 64-bit __sync_{add,sub}_and_fetch()... no
checking for __builtin_clz... yes
checking whether Darwin os_unfair_lock_*() is compilable... no
checking whether Darwin OSSpin*() is compilable... no
checking whether glibc malloc hook is compilable... yes
checking whether glibc memalign hook is compilable... yes
checking whether pthreads adaptive mutexes is compilable... yes
checking whether compiler supports -D_GNU_SOURCE... yes
checking whether compiler supports -Werror... yes
checking whether compiler supports -herror_on_warning... no
checking whether strerror_r returns char with gnu source is compilable... yes
checking for stdbool.h that conforms to C99... yes
checking for _Bool... yes
configure: creating ./config.status
config.status: creating Makefile
config.status: creating jemalloc.pc
config.status: creating doc/html.xsl
config.status: creating doc/manpages.xsl
config.status: creating doc/jemalloc.xml
config.status: creating include/jemalloc/jemalloc_macros.h
config.status: creating include/jemalloc/jemalloc_protos.h
config.status: creating include/jemalloc/jemalloc_typedefs.h
config.status: creating include/jemalloc/internal/jemalloc_preamble.h
config.status: creating test/test.sh
config.status: creating test/include/test/jemalloc_test.h
config.status: creating config.stamp
config.status: creating bin/jemalloc-config
config.status: creating bin/jemalloc.sh
config.status: creating bin/jeprof
config.status: creating include/jemalloc/jemalloc_defs.h
config.status: creating include/jemalloc/internal/jemalloc_internal_defs.h
config.status: creating test/include/test/jemalloc_test_defs.h
config.status: executing include/jemalloc/internal/public_symbols.txt commands
config.status: executing include/jemalloc/internal/private_symbols.awk commands
config.status: executing include/jemalloc/internal/private_symbols_jet.awk commands
config.status: executing include/jemalloc/internal/public_namespace.h commands
config.status: executing include/jemalloc/internal/public_unnamespace.h commands
config.status: executing include/jemalloc/internal/size_classes.h commands
config.status: executing include/jemalloc/jemalloc_protos_jet.h commands
config.status: executing include/jemalloc/jemalloc_rename.h commands
config.status: executing include/jemalloc/jemalloc_mangle.h commands
config.status: executing include/jemalloc/jemalloc_mangle_jet.h commands
config.status: executing include/jemalloc/jemalloc.h commands
===============================================================================
jemalloc version   : 5.1.0-0-g0
library revision   : 2

CONFIG             :
CC                 : gcc
CONFIGURE_CFLAGS   : -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops
SPECIFIED_CFLAGS   :
EXTRA_CFLAGS       :
CPPFLAGS           : -D_GNU_SOURCE -D_REENTRANT
CXX                : g++
CONFIGURE_CXXFLAGS :
SPECIFIED_CXXFLAGS :
EXTRA_CXXFLAGS     :
LDFLAGS            :
EXTRA_LDFLAGS      :
DSO_LDFLAGS        : -shared -Wl,-soname,$(@F)
LIBS               : -lm  -lpthread -ldl
RPATH_EXTRA        :

XSLTPROC           : false
XSLROOT            :

PREFIX             : /usr/local
BINDIR             : /usr/local/bin
DATADIR            : /usr/local/share
INCLUDEDIR         : /usr/local/include
LIBDIR             : /usr/local/lib
MANDIR             : /usr/local/share/man

srcroot            :
abs_srcroot        : /root/redis-6.2.6/deps/jemalloc/
objroot            :
abs_objroot        : /root/redis-6.2.6/deps/jemalloc/

JEMALLOC_PREFIX    :
JEMALLOC_PRIVATE_NAMESPACE
                   : je_
install_suffix     :
malloc_conf        :
autogen            : 0
debug              : 0
stats              : 1
prof               : 0
prof-libunwind     : 0
prof-libgcc        : 0
prof-gcc           : 0
fill               : 1
utrace             : 0
xmalloc            : 0
log                : 0
lazy_lock          : 0
cache-oblivious    : 1
cxx                : 0
===============================================================================
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc# make
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/jemalloc.sym.o src/jemalloc.c
src/jemalloc.c:2513:7: warning: ‘__libc_calloc’ specifies less restrictive attributes than its target ‘calloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2513 | void *__libc_calloc(size_t n, size_t size) PREALIAS(je_calloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:542:14: note: ‘__libc_calloc’ target declared here
  542 | extern void *calloc (size_t __nmemb, size_t __size)
      |              ^~~~~~
src/jemalloc.c:2528:7: warning: ‘__libc_valloc’ specifies less restrictive attributes than its target ‘valloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2528 | void *__libc_valloc(size_t size) PREALIAS(je_valloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:574:14: note: ‘__libc_valloc’ target declared here
  574 | extern void *valloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2525:7: warning: ‘__libc_realloc’ specifies less restrictive attributes than its target ‘realloc’: ‘alloc_size’, ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2525 | void *__libc_realloc(void* ptr, size_t size) PREALIAS(je_realloc);
      |       ^~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:550:14: note: ‘__libc_realloc’ target declared here
  550 | extern void *realloc (void *__ptr, size_t __size)
      |              ^~~~~~~
src/jemalloc.c:2522:7: warning: ‘__libc_memalign’ specifies less restrictive attributes than its target ‘memalign’: ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2522 | void *__libc_memalign(size_t align, size_t s) PREALIAS(je_memalign);
      |       ^~~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_preamble.h:21,
                 from src/jemalloc.c:2:
include/jemalloc/internal/../jemalloc.h:79:23: note: ‘__libc_memalign’ target declared here
   79 | #  define je_memalign memalign
      |                       ^~~~~~~~
src/jemalloc.c:2419:1: note: in expansion of macro ‘je_memalign’
 2419 | je_memalign(size_t alignment, size_t size) {
      | ^~~~~~~~~~~
src/jemalloc.c:2519:7: warning: ‘__libc_malloc’ specifies less restrictive attributes than its target ‘malloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2519 | void *__libc_malloc(size_t size) PREALIAS(je_malloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:539:14: note: ‘__libc_malloc’ target declared here
  539 | extern void *malloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2516:6: warning: ‘__libc_free’ specifies less restrictive attributes than its target ‘free’: ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2516 | void __libc_free(void* ptr) PREALIAS(je_free);
      |      ^~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:565:13: note: ‘__libc_free’ target declared here
  565 | extern void free (void *__ptr) __THROW;
      |             ^~~~
nm -a src/jemalloc.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/jemalloc.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/arena.sym.o src/arena.c
nm -a src/arena.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/arena.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/background_thread.sym.o src/background_thread.c
nm -a src/background_thread.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/background_thread.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/base.sym.o src/base.c
nm -a src/base.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/base.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/bin.sym.o src/bin.c
nm -a src/bin.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/bin.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/bitmap.sym.o src/bitmap.c
nm -a src/bitmap.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/bitmap.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/ckh.sym.o src/ckh.c
nm -a src/ckh.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/ckh.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/ctl.sym.o src/ctl.c
nm -a src/ctl.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/ctl.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/div.sym.o src/div.c
nm -a src/div.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/div.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/extent.sym.o src/extent.c
nm -a src/extent.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/extent.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/extent_dss.sym.o src/extent_dss.c
nm -a src/extent_dss.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/extent_dss.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/extent_mmap.sym.o src/extent_mmap.c
nm -a src/extent_mmap.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/extent_mmap.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/hash.sym.o src/hash.c
nm -a src/hash.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/hash.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/hooks.sym.o src/hooks.c
nm -a src/hooks.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/hooks.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/large.sym.o src/large.c
nm -a src/large.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/large.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/log.sym.o src/log.c
nm -a src/log.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/log.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/malloc_io.sym.o src/malloc_io.c
nm -a src/malloc_io.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/malloc_io.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/mutex.sym.o src/mutex.c
nm -a src/mutex.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/mutex.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/mutex_pool.sym.o src/mutex_pool.c
nm -a src/mutex_pool.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/mutex_pool.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/nstime.sym.o src/nstime.c
nm -a src/nstime.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/nstime.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/pages.sym.o src/pages.c
nm -a src/pages.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/pages.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/prng.sym.o src/prng.c
nm -a src/prng.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/prng.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/prof.sym.o src/prof.c
nm -a src/prof.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/prof.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/rtree.sym.o src/rtree.c
nm -a src/rtree.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/rtree.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/stats.sym.o src/stats.c

nm -a src/stats.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/stats.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/sz.sym.o src/sz.c
nm -a src/sz.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/sz.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/tcache.sym.o src/tcache.c
nm -a src/tcache.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/tcache.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/ticker.sym.o src/ticker.c
nm -a src/ticker.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/ticker.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/tsd.sym.o src/tsd.c
nm -a src/tsd.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/tsd.sym
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -DJEMALLOC_NO_PRIVATE_NAMESPACE -o src/witness.sym.o src/witness.c
nm -a src/witness.sym.o | gawk -f include/jemalloc/internal/private_symbols.awk > src/witness.sym
/bin/sh include/jemalloc/internal/private_namespace.sh src/jemalloc.sym src/arena.sym src/background_thread.sym src/base.sym src/bin.sym src/bitmap.sym src/ckh.sym src/ctl.sym src/div.sym src/extent.sym src/extent_dss.sym src/extent_mmap.sym src/hash.sym src/hooks.sym src/large.sym src/log.sym src/malloc_io.sym src/mutex.sym src/mutex_pool.sym src/nstime.sym src/pages.sym src/prng.sym src/prof.sym src/rtree.sym src/stats.sym src/sz.sym src/tcache.sym src/ticker.sym src/tsd.sym src/witness.sym > include/jemalloc/internal/private_namespace.gen.h
cp include/jemalloc/internal/private_namespace.gen.h include/jemalloc/internal/private_namespace.gen.h
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/jemalloc.pic.o src/jemalloc.c
src/jemalloc.c:2513:7: warning: ‘__libc_calloc’ specifies less restrictive attributes than its target ‘calloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2513 | void *__libc_calloc(size_t n, size_t size) PREALIAS(je_calloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:542:14: note: ‘__libc_calloc’ target declared here
  542 | extern void *calloc (size_t __nmemb, size_t __size)
      |              ^~~~~~
src/jemalloc.c:2528:7: warning: ‘__libc_valloc’ specifies less restrictive attributes than its target ‘valloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2528 | void *__libc_valloc(size_t size) PREALIAS(je_valloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:574:14: note: ‘__libc_valloc’ target declared here
  574 | extern void *valloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2525:7: warning: ‘__libc_realloc’ specifies less restrictive attributes than its target ‘realloc’: ‘alloc_size’, ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2525 | void *__libc_realloc(void* ptr, size_t size) PREALIAS(je_realloc);
      |       ^~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:550:14: note: ‘__libc_realloc’ target declared here
  550 | extern void *realloc (void *__ptr, size_t __size)
      |              ^~~~~~~
src/jemalloc.c:2522:7: warning: ‘__libc_memalign’ specifies less restrictive attributes than its target ‘memalign’: ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2522 | void *__libc_memalign(size_t align, size_t s) PREALIAS(je_memalign);
      |       ^~~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_preamble.h:21,
                 from src/jemalloc.c:2:
include/jemalloc/internal/../jemalloc.h:79:23: note: ‘__libc_memalign’ target declared here
   79 | #  define je_memalign memalign
      |                       ^~~~~~~~
src/jemalloc.c:2419:1: note: in expansion of macro ‘je_memalign’
 2419 | je_memalign(size_t alignment, size_t size) {
      | ^~~~~~~~~~~
src/jemalloc.c:2519:7: warning: ‘__libc_malloc’ specifies less restrictive attributes than its target ‘malloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2519 | void *__libc_malloc(size_t size) PREALIAS(je_malloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:539:14: note: ‘__libc_malloc’ target declared here
  539 | extern void *malloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2516:6: warning: ‘__libc_free’ specifies less restrictive attributes than its target ‘free’: ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2516 | void __libc_free(void* ptr) PREALIAS(je_free);
      |      ^~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:565:13: note: ‘__libc_free’ target declared here
  565 | extern void free (void *__ptr) __THROW;
      |             ^~~~


gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/arena.pic.o src/arena.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/background_thread.pic.o src/background_thread.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/base.pic.o src/base.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bin.pic.o src/bin.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bitmap.pic.o src/bitmap.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ckh.pic.o src/ckh.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ctl.pic.o src/ctl.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/div.pic.o src/div.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent.pic.o src/extent.c

gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_dss.pic.o src/extent_dss.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_mmap.pic.o src/extent_mmap.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hash.pic.o src/hash.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hooks.pic.o src/hooks.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/large.pic.o src/large.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/log.pic.o src/log.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/malloc_io.pic.o src/malloc_io.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex.pic.o src/mutex.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex_pool.pic.o src/mutex_pool.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/nstime.pic.o src/nstime.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/pages.pic.o src/pages.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prng.pic.o src/prng.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prof.pic.o src/prof.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/rtree.pic.o src/rtree.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/stats.pic.o src/stats.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/sz.pic.o src/sz.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tcache.pic.o src/tcache.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ticker.pic.o src/ticker.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tsd.pic.o src/tsd.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -fPIC -DPIC -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/witness.pic.o src/witness.c
gcc -shared -Wl,-soname,libjemalloc.so.2  -o lib/libjemalloc.so.2 src/jemalloc.pic.o src/arena.pic.o src/background_thread.pic.o src/base.pic.o src/bin.pic.o src/bitmap.pic.o src/ckh.pic.o src/ctl.pic.o src/div.pic.o src/extent.pic.o src/extent_dss.pic.o src/extent_mmap.pic.o src/hash.pic.o src/hooks.pic.o src/large.pic.o src/log.pic.o src/malloc_io.pic.o src/mutex.pic.o src/mutex_pool.pic.o src/nstime.pic.o src/pages.pic.o src/prng.pic.o src/prof.pic.o src/rtree.pic.o src/stats.pic.o src/sz.pic.o src/tcache.pic.o src/ticker.pic.o src/tsd.pic.o src/witness.pic.o  -lm  -lpthread -ldl
ln -sf libjemalloc.so.2 lib/libjemalloc.so
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/jemalloc.o src/jemalloc.c
src/jemalloc.c:2513:7: warning: ‘__libc_calloc’ specifies less restrictive attributes than its target ‘calloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2513 | void *__libc_calloc(size_t n, size_t size) PREALIAS(je_calloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:542:14: note: ‘__libc_calloc’ target declared here
  542 | extern void *calloc (size_t __nmemb, size_t __size)
      |              ^~~~~~
src/jemalloc.c:2528:7: warning: ‘__libc_valloc’ specifies less restrictive attributes than its target ‘valloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2528 | void *__libc_valloc(size_t size) PREALIAS(je_valloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:574:14: note: ‘__libc_valloc’ target declared here
  574 | extern void *valloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2525:7: warning: ‘__libc_realloc’ specifies less restrictive attributes than its target ‘realloc’: ‘alloc_size’, ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2525 | void *__libc_realloc(void* ptr, size_t size) PREALIAS(je_realloc);
      |       ^~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:550:14: note: ‘__libc_realloc’ target declared here
  550 | extern void *realloc (void *__ptr, size_t __size)
      |              ^~~~~~~
src/jemalloc.c:2522:7: warning: ‘__libc_memalign’ specifies less restrictive attributes than its target ‘memalign’: ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2522 | void *__libc_memalign(size_t align, size_t s) PREALIAS(je_memalign);
      |       ^~~~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_preamble.h:21,
                 from src/jemalloc.c:2:
include/jemalloc/internal/../jemalloc.h:79:23: note: ‘__libc_memalign’ target declared here
   79 | #  define je_memalign memalign
      |                       ^~~~~~~~
src/jemalloc.c:2419:1: note: in expansion of macro ‘je_memalign’
 2419 | je_memalign(size_t alignment, size_t size) {
      | ^~~~~~~~~~~
src/jemalloc.c:2519:7: warning: ‘__libc_malloc’ specifies less restrictive attributes than its target ‘malloc’: ‘alloc_size’, ‘leaf’, ‘malloc’, ‘nothrow’ [-Wmissing-attributes]
 2519 | void *__libc_malloc(size_t size) PREALIAS(je_malloc);
      |       ^~~~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:539:14: note: ‘__libc_malloc’ target declared here
  539 | extern void *malloc (size_t __size) __THROW __attribute_malloc__
      |              ^~~~~~
src/jemalloc.c:2516:6: warning: ‘__libc_free’ specifies less restrictive attributes than its target ‘free’: ‘leaf’, ‘nothrow’ [-Wmissing-attributes]
 2516 | void __libc_free(void* ptr) PREALIAS(je_free);
      |      ^~~~~~~~~~~
In file included from include/jemalloc/internal/jemalloc_internal_decls.h:60,
                 from include/jemalloc/internal/jemalloc_preamble.h:5,
                 from src/jemalloc.c:2:
/usr/include/stdlib.h:565:13: note: ‘__libc_free’ target declared here
  565 | extern void free (void *__ptr) __THROW;
      |             ^~~~
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/arena.o src/arena.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/background_thread.o src/background_thread.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/base.o src/base.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bin.o src/bin.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/bitmap.o src/bitmap.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ckh.o src/ckh.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ctl.o src/ctl.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/div.o src/div.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent.o src/extent.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_dss.o src/extent_dss.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/extent_mmap.o src/extent_mmap.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hash.o src/hash.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/hooks.o src/hooks.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/large.o src/large.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/log.o src/log.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/malloc_io.o src/malloc_io.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex.o src/mutex.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/mutex_pool.o src/mutex_pool.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/nstime.o src/nstime.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/pages.o src/pages.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prng.o src/prng.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/prof.o src/prof.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/rtree.o src/rtree.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/stats.o src/stats.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/sz.o src/sz.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tcache.o src/tcache.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/ticker.o src/ticker.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/tsd.o src/tsd.c
gcc -std=gnu11 -Wall -Wsign-compare -Wundef -Wno-format-zero-length -pipe -g3 -fvisibility=hidden -O3 -funroll-loops -c -D_GNU_SOURCE -D_REENTRANT -Iinclude -Iinclude -o src/witness.o src/witness.c
ar crus lib/libjemalloc.a src/jemalloc.o src/arena.o src/background_thread.o src/base.o src/bin.o src/bitmap.o src/ckh.o src/ctl.o src/div.o src/extent.o src/extent_dss.o src/extent_mmap.o src/hash.o src/hooks.o src/large.o src/log.o src/malloc_io.o src/mutex.o src/mutex_pool.o src/nstime.o src/pages.o src/prng.o src/prof.o src/rtree.o src/stats.o src/sz.o src/tcache.o src/ticker.o src/tsd.o src/witness.o
ar: `u' modifier ignored since `D' is the default (see `U')
ar crus lib/libjemalloc_pic.a src/jemalloc.pic.o src/arena.pic.o src/background_thread.pic.o src/base.pic.o src/bin.pic.o src/bitmap.pic.o src/ckh.pic.o src/ctl.pic.o src/div.pic.o src/extent.pic.o src/extent_dss.pic.o src/extent_mmap.pic.o src/hash.pic.o src/hooks.pic.o src/large.pic.o src/log.pic.o src/malloc_io.pic.o src/mutex.pic.o src/mutex_pool.pic.o src/nstime.pic.o src/pages.pic.o src/prng.pic.o src/prof.pic.o src/rtree.pic.o src/stats.pic.o src/sz.pic.o src/tcache.pic.o src/ticker.pic.o src/tsd.pic.o src/witness.pic.o
ar: `u' modifier ignored since `D' is the default (see `U')
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc#
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc#
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc#
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc#
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc# make install
/usr/bin/install -c -d /usr/local/bin
/usr/bin/install -c -m 755 bin/jemalloc-config /usr/local/bin
/usr/bin/install -c -m 755 bin/jemalloc.sh /usr/local/bin
/usr/bin/install -c -m 755 bin/jeprof /usr/local/bin
/usr/bin/install -c -d /usr/local/include/jemalloc
/usr/bin/install -c -m 644 include/jemalloc/jemalloc.h /usr/local/include/jemalloc
/usr/bin/install -c -d /usr/local/lib
/usr/bin/install -c -m 755 lib/libjemalloc.so.2 /usr/local/lib
ln -sf libjemalloc.so.2 /usr/local/lib/libjemalloc.so
/usr/bin/install -c -d /usr/local/lib
/usr/bin/install -c -m 755 lib/libjemalloc.a /usr/local/lib
/usr/bin/install -c -m 755 lib/libjemalloc_pic.a /usr/local/lib
/usr/bin/install -c -d /usr/local/lib/pkgconfig
/usr/bin/install -c -m 644 jemalloc.pc /usr/local/lib/pkgconfig
/usr/bin/install -c -d /usr/local/share/doc/jemalloc
/usr/bin/install -c -m 644 doc/jemalloc.html /usr/local/share/doc/jemalloc
/usr/bin/install: cannot stat 'doc/jemalloc.html': No such file or directory
make: *** [Makefile:456: install_doc_html] Error 1
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/jemalloc# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps# ls
Makefile  README.md  hdr_histogram  hiredis  jemalloc  linenoise  lua  update-jemalloc.sh
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps# cd lua/
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# ls
COPYRIGHT  HISTORY  INSTALL  Makefile  README  doc  etc  src  test
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# make
Please do
   make PLATFORM
where PLATFORM is one of these:
   aix ansi bsd freebsd generic linux macosx mingw posix solaris
See INSTALL for complete instructions.
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# make linux
cd src && make linux
make[1]: Entering directory '/root/redis-6.2.6/deps/lua/src'
make all MYCFLAGS=-DLUA_USE_LINUX MYLIBS="-Wl,-E -ldl -lreadline -lhistory -lncurses"
make[2]: Entering directory '/root/redis-6.2.6/deps/lua/src'
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lapi.o lapi.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lcode.o lcode.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o ldebug.o ldebug.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o ldo.o ldo.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o ldump.o ldump.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lfunc.o lfunc.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lgc.o lgc.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o llex.o llex.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lmem.o lmem.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lobject.o lobject.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lopcodes.o lopcodes.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lparser.o lparser.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lstate.o lstate.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lstring.o lstring.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o ltable.o ltable.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o ltm.o ltm.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lundump.o lundump.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lvm.o lvm.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lzio.o lzio.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o strbuf.o strbuf.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o fpconv.o fpconv.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lauxlib.o lauxlib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lbaselib.o lbaselib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o ldblib.o ldblib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o liolib.o liolib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lmathlib.o lmathlib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o loslib.o loslib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o ltablib.o ltablib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lstrlib.o lstrlib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o loadlib.o loadlib.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o linit.o linit.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lua_cjson.o lua_cjson.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lua_struct.o lua_struct.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lua_cmsgpack.o lua_cmsgpack.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lua_bit.o lua_bit.c
ar rcu liblua.a lapi.o lcode.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o strbuf.o fpconv.o lauxlib.o lbaselib.o ldblib.o liolib.o lmathlib.o loslib.o ltablib.o lstrlib.o loadlib.o linit.o lua_cjson.o lua_struct.o lua_cmsgpack.o lua_bit.o	# DLL needs all object files
ar: `u' modifier ignored since `D' is the default (see `U')
ranlib liblua.a
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lua.o lua.c
In file included from lua.h:16,
                 from lua.c:15:
luaconf.h:275:10: fatal error: readline/readline.h: No such file or directory
  275 | #include <readline/readline.h>
      |          ^~~~~~~~~~~~~~~~~~~~~
compilation terminated.
make[2]: *** [<builtin>: lua.o] Error 1
make[2]: Leaving directory '/root/redis-6.2.6/deps/lua/src'
make[1]: *** [Makefile:100: linux] Error 2
make[1]: Leaving directory '/root/redis-6.2.6/deps/lua/src'
make: *** [Makefile:56: linux] Error 2
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# less INSTALL
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# sudo apt-get install -y build-essential pkg-config libssl-dev
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  dpkg-dev fakeroot g++ g++-9 libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libdpkg-perl
  libfakeroot libfile-fcntllock-perl libstdc++-9-dev
Suggested packages:
  debian-keyring g++-multilib g++-9-multilib gcc-9-doc bzr libssl-doc libstdc++-9-doc
The following NEW packages will be installed:
  build-essential dpkg-dev fakeroot g++ g++-9 libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl
  libdpkg-perl libfakeroot libfile-fcntllock-perl libssl-dev libstdc++-9-dev pkg-config
0 upgraded, 14 newly installed, 0 to remove and 18 not upgraded.
Need to get 12.9 MB of archives.
After this operation, 60.0 MB of additional disk space will be used.
Get:1 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libstdc++-9-dev amd64 9.3.0-17ubuntu1~20.04 [1714 kB]
Get:2 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 g++-9 amd64 9.3.0-17ubuntu1~20.04 [8405 kB]
Get:3 http://mirrors.digitalocean.com/ubuntu focal/main amd64 g++ amd64 4:9.3.0-1ubuntu2 [1604 B]
Get:4 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libdpkg-perl all 1.19.7ubuntu3 [230 kB]
Get:5 http://mirrors.digitalocean.com/ubuntu focal/main amd64 dpkg-dev all 1.19.7ubuntu3 [679 kB]
Get:6 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 build-essential amd64 12.8ubuntu1.1 [4664 B]
Get:7 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libfakeroot amd64 1.24-1 [25.7 kB]
Get:8 http://mirrors.digitalocean.com/ubuntu focal/main amd64 fakeroot amd64 1.24-1 [62.6 kB]
Get:9 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libalgorithm-diff-perl all 1.19.03-2 [46.6 kB]
Get:10 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libalgorithm-diff-xs-perl amd64 0.04-6 [11.3 kB]
Get:11 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libalgorithm-merge-perl all 0.08-3 [12.0 kB]
Get:12 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libfile-fcntllock-perl amd64 0.22-3build4 [33.1 kB]
Get:13 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 libssl-dev amd64 1.1.1f-1ubuntu2.8 [1584 kB]
Get:14 http://mirrors.digitalocean.com/ubuntu focal/main amd64 pkg-config amd64 0.29.1-0ubuntu4 [45.5 kB]
Fetched 12.9 MB in 2s (6183 kB/s)
Selecting previously unselected package libstdc++-9-dev:amd64.
(Reading database ... 67831 files and directories currently installed.)
Preparing to unpack .../00-libstdc++-9-dev_9.3.0-17ubuntu1~20.04_amd64.deb ...
Unpacking libstdc++-9-dev:amd64 (9.3.0-17ubuntu1~20.04) ...
Selecting previously unselected package g++-9.
Preparing to unpack .../01-g++-9_9.3.0-17ubuntu1~20.04_amd64.deb ...
Unpacking g++-9 (9.3.0-17ubuntu1~20.04) ...
Selecting previously unselected package g++.
Preparing to unpack .../02-g++_4%3a9.3.0-1ubuntu2_amd64.deb ...
Unpacking g++ (4:9.3.0-1ubuntu2) ...
Selecting previously unselected package libdpkg-perl.
Preparing to unpack .../03-libdpkg-perl_1.19.7ubuntu3_all.deb ...
Unpacking libdpkg-perl (1.19.7ubuntu3) ...
Selecting previously unselected package dpkg-dev.
Preparing to unpack .../04-dpkg-dev_1.19.7ubuntu3_all.deb ...
Unpacking dpkg-dev (1.19.7ubuntu3) ...
Selecting previously unselected package build-essential.
Preparing to unpack .../05-build-essential_12.8ubuntu1.1_amd64.deb ...
Unpacking build-essential (12.8ubuntu1.1) ...
Selecting previously unselected package libfakeroot:amd64.
Preparing to unpack .../06-libfakeroot_1.24-1_amd64.deb ...
Unpacking libfakeroot:amd64 (1.24-1) ...
Selecting previously unselected package fakeroot.
Preparing to unpack .../07-fakeroot_1.24-1_amd64.deb ...
Unpacking fakeroot (1.24-1) ...
Selecting previously unselected package libalgorithm-diff-perl.
Preparing to unpack .../08-libalgorithm-diff-perl_1.19.03-2_all.deb ...
Unpacking libalgorithm-diff-perl (1.19.03-2) ...
Selecting previously unselected package libalgorithm-diff-xs-perl.
Preparing to unpack .../09-libalgorithm-diff-xs-perl_0.04-6_amd64.deb ...
Unpacking libalgorithm-diff-xs-perl (0.04-6) ...
Selecting previously unselected package libalgorithm-merge-perl.
Preparing to unpack .../10-libalgorithm-merge-perl_0.08-3_all.deb ...
Unpacking libalgorithm-merge-perl (0.08-3) ...
Selecting previously unselected package libfile-fcntllock-perl.
Preparing to unpack .../11-libfile-fcntllock-perl_0.22-3build4_amd64.deb ...
Unpacking libfile-fcntllock-perl (0.22-3build4) ...
Selecting previously unselected package libssl-dev:amd64.
Preparing to unpack .../12-libssl-dev_1.1.1f-1ubuntu2.8_amd64.deb ...
Unpacking libssl-dev:amd64 (1.1.1f-1ubuntu2.8) ...
Selecting previously unselected package pkg-config.
Preparing to unpack .../13-pkg-config_0.29.1-0ubuntu4_amd64.deb ...
Unpacking pkg-config (0.29.1-0ubuntu4) ...
Setting up libstdc++-9-dev:amd64 (9.3.0-17ubuntu1~20.04) ...
Setting up libfile-fcntllock-perl (0.22-3build4) ...
Setting up libalgorithm-diff-perl (1.19.03-2) ...
Setting up libfakeroot:amd64 (1.24-1) ...
Setting up fakeroot (1.24-1) ...
update-alternatives: using /usr/bin/fakeroot-sysv to provide /usr/bin/fakeroot (fakeroot) in auto mode
Setting up libssl-dev:amd64 (1.1.1f-1ubuntu2.8) ...
Setting up g++-9 (9.3.0-17ubuntu1~20.04) ...
Setting up libdpkg-perl (1.19.7ubuntu3) ...
Setting up g++ (4:9.3.0-1ubuntu2) ...
update-alternatives: using /usr/bin/g++ to provide /usr/bin/c++ (c++) in auto mode
Setting up libalgorithm-diff-xs-perl (0.04-6) ...
Setting up libalgorithm-merge-perl (0.08-3) ...
Setting up dpkg-dev (1.19.7ubuntu3) ...
Setting up pkg-config (0.29.1-0ubuntu4) ...
Setting up build-essential (12.8ubuntu1.1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for libc-bin (2.31-0ubuntu9.2) ...
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# read
read         readarray    readelf      readlink     readonly     readprofile
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# make linux
cd src && make linux
make[1]: Entering directory '/root/redis-6.2.6/deps/lua/src'
make all MYCFLAGS=-DLUA_USE_LINUX MYLIBS="-Wl,-E -ldl -lreadline -lhistory -lncurses"
make[2]: Entering directory '/root/redis-6.2.6/deps/lua/src'
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lua.o lua.c
In file included from lua.h:16,
                 from lua.c:15:
luaconf.h:275:10: fatal error: readline/readline.h: No such file or directory
  275 | #include <readline/readline.h>
      |          ^~~~~~~~~~~~~~~~~~~~~
compilation terminated.
make[2]: *** [<builtin>: lua.o] Error 1
make[2]: Leaving directory '/root/redis-6.2.6/deps/lua/src'
make[1]: *** [Makefile:100: linux] Error 2
make[1]: Leaving directory '/root/redis-6.2.6/deps/lua/src'
make: *** [Makefile:56: linux] Error 2
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# apt search readline
Sorting... Done
Full Text Search... Done
beef/focal 1.0.2-3build1 amd64
  flexible Brainfuck interpreter

bpython/focal 0.18-3 all
  fancy interface to the Python 3 interpreter

cdecl/focal 2.5-13build2 amd64
  Turn English phrases to C or C++ declarations

clisp/focal 1:2.49.20180218+really2.49.92-3build3 amd64
  GNU CLISP, a Common Lisp implementation

cupt/focal 2.10.4ubuntu1 amd64
  flexible package manager -- console interface

fim/focal 0.5.3-2build1 amd64
  scriptable frame buffer, X.org and ascii art image viewer

golang-github-chzyer-readline-dev/focal 1.4+git20171103.a4d5111-1 all
  Readline is a pure go implementation for a GNU-Readline like library

golang-gopkg-readline.v1-dev/focal 1.4-1 all
  Pure Go implementation for GNU Readline-like library

lib32readline-dev/focal 8.0-4 amd64
  GNU readline and history libraries, development files (32-bit)

lib32readline8/focal 8.0-4 amd64
  GNU readline and history libraries, run-time libraries (32-bit)

libconfig-model-perl/focal 2.138-2 all
  module for describing and editing configuration data

libedit-dev/focal 3.1-20191231-1 amd64
  BSD editline and history libraries (development files)

libedit2/focal,now 3.1-20191231-1 amd64 [installed,automatic]
  BSD editline and history libraries

libeditline-dev/focal 1.12-6.1 amd64
  development files for libeditline

libeditline0/focal 1.12-6.1 amd64
  line editing library similar to readline

libenv-ps1-perl/focal 0.06-2 all
  prompt string formatter

libghc-readline-dev/focal 1.0.3.0-9build2 amd64
  Haskell bindings to GNU readline library

libghc-readline-doc/focal 1.0.3.0-9build2 all
  Haskell bindings to GNU readline library; documentation

libghc-readline-prof/focal 1.0.3.0-9build2 amd64
  Haskell bindings to GNU readline library; profiling libraries

libgnatcoll-readline18-dev/focal 19-2 amd64
  GNATColl, general purpose Ada library (readline)

libgnatcoll-readline19/focal 19-2 amd64
  GNATColl, general purpose Ada library (readline runtime)

libjline-java/focal 1.0-2 all
  Java library for handling console input

libjline-java-doc/focal 1.0-2 all
  Java library for handling console input - documentation

libjline2-java/focal 2.14.6-3 all
  console input handling in Java

libreadline-dev/focal 8.0-4 amd64
  GNU readline and history libraries, development files

libreadline-gplv2-dev/focal 5.2+dfsg-3build3 amd64
  GNU readline and history libraries, development files

libreadline-java/focal 0.8.0.1+dfsg-9build1 amd64
  GNU readline and BSD editline wrappers for Java

libreadline-java-doc/focal 0.8.0.1+dfsg-9build1 all
  API docs for readline/editline wrappers for Java

libreadline5/focal,now 5.2+dfsg-3build3 amd64 [installed,automatic]
  GNU readline and history libraries, run-time libraries

libreadline5-dbg/focal 5.2+dfsg-3build3 amd64
  GNU readline and history libraries, debugging libraries

libreadline8/focal,now 8.0-4 amd64 [installed,automatic]
  GNU readline and history libraries, run-time libraries

libreply-perl/focal 0.42-1 all
  lightweight extensible Perl REPL

librust-rustyline+dirs-dev/focal 6.0.0-1 amd64
  Readline implementation based on Linenoise - feature "dirs" and 2 more

librust-rustyline-dev/focal 6.0.0-1 amd64
  Readline implementation based on Linenoise - Rust source code

libterm-readline-gnu-perl/focal 1.36-2build1 amd64
  Perl extension for the GNU ReadLine/History Library

libterm-readline-perl-perl/focal 1.0303-2 all
  Perl implementation of Readline libraries

libterm-readline-ttytter-perl/focal 1.4-3 all
  Term::ReadLine driver with special features for microblogging

libterm-readline-zoid-perl/focal 0.07-3 all
  Pure Perl implementation of Readline libraries

libterm-shellui-perl/focal 0.92-2 all
  Perl module for fully-featured shell-like command line environment

libterm-ui-perl/focal 0.46-1 all
  Term::ReadLine UI made easy

libzed-ocaml/focal 2.0.5-1build1 amd64
  abstract engine for text edition in OCaml (runtime)

libzed-ocaml-dev/focal 2.0.5-1build1 amd64
  abstract engine for text edition in OCaml (development tools)

microdc2/focal 0.15.6-4build2 amd64
  command-line based Direct Connect client

ncftp/focal 2:3.2.5-2.1 amd64
  User-friendly and well-featured FTP client

node-getpass/focal 0.1.7-1 all
  get a password from terminal

node-keypress/focal 0.2.1-1 all
  Make any Node ReadableStream emit "keypress" events

node-read/focal 1.0.7-2 all
  Read user input from stdin module for Node.js

nwall/focal 1.32+debian-4.2build2 amd64
  version of wall that uses GNU readline

perl6-readline/focal 0.1.5-1 all
  Readline binding for Perl 6

perlconsole/focal 0.4-4 all
  small program that lets you evaluate Perl code interactively

php-readline/focal 2:7.4+75 all
  readline module for PHP [default]

php7.4-readline/focal-updates,focal-security 7.4.3-4ubuntu2.7 amd64
  readline module for PHP

python3-prompt-toolkit/focal 2.0.10-2 all
  library for building interactive command lines (Python 3)

python3-readlike/focal 0.1.3-1 all
  GNU Readline-like line editing module

readline-common/focal,now 8.0-4 all [installed,automatic]
  GNU readline and history libraries, common files

readline-doc/focal 8.0-4 all
  GNU readline and history libraries, documentation and examples

renameutils/focal 0.12.0-7 amd64
  Programs to make file renaming easier

rlfe/focal 8.0-4 amd64
  Front-end using readline to "cook" input lines for other programs

rlwrap/focal 0.43-1build3 amd64
  readline feature command line wrapper

sdcv/focal 0.5.2-2build2 amd64
  StarDict Console Version

swi-prolog/focal 7.6.4+dfsg-2ubuntu2 amd64
  ISO/Edinburgh-style Prolog interpreter

swi-prolog-bdb/focal 7.6.4+dfsg-2ubuntu2 amd64
  Berkeley DB interface for SWI-Prolog

swi-prolog-java/focal 7.6.4+dfsg-2ubuntu2 amd64
  Bidirectional interface between SWI-Prolog and Java

swi-prolog-nox/focal 7.6.4+dfsg-2ubuntu2 amd64
  ISO/Edinburgh-style Prolog interpreter (without X support)

swi-prolog-odbc/focal 7.6.4+dfsg-2ubuntu2 amd64
  ODBC library for SWI-Prolog

swi-prolog-x/focal 7.6.4+dfsg-2ubuntu2 amd64
  User interface library for SWI-Prolog (with X support)

tarantool-lts-client/focal 1.5.5.37.g1687c02-1build3 amd64
  Tarantool in-memory database - command line client

tcl-tclreadline/focal 2.3.8-1 amd64
  GNU Readline Extension for Tcl/Tk

tintin++/focal 2.01.5-2build1 amd64
  classic text-based MUD client

xmms2-client-cli/focal 0.8+dfsg-18.2ubuntu3 amd64
  XMMS2 - cli client

root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# apt install libreadline-dev
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  libncurses-dev
Suggested packages:
  ncurses-doc readline-doc
The following NEW packages will be installed:
  libncurses-dev libreadline-dev
0 upgraded, 2 newly installed, 0 to remove and 18 not upgraded.
Need to get 481 kB of archives.
After this operation, 3165 kB of additional disk space will be used.
Do you want to continue? [Y/n]
yGet:1 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libncurses-dev amd64 6.2-0ubuntu2 [339 kB]
Get:2 http://mirrors.digitalocean.com/ubuntu focal/main amd64 libreadline-dev amd64 8.0-4 [141 kB]
Fetched 481 kB in 0s (1079 kB/s)
Selecting previously unselected package libncurses-dev:amd64.
(Reading database ... 69310 files and directories currently installed.)
Preparing to unpack .../libncurses-dev_6.2-0ubuntu2_amd64.deb ...
Unpacking libncurses-dev:amd64 (6.2-0ubuntu2) ...
Selecting previously unselected package libreadline-dev:amd64.
Preparing to unpack .../libreadline-dev_8.0-4_amd64.deb ...
Unpacking libreadline-dev:amd64 (8.0-4) ...
Setting up libncurses-dev:amd64 (6.2-0ubuntu2) ...
Setting up libreadline-dev:amd64 (8.0-4) ...
Processing triggers for install-info (6.7.0.dfsg.2-5) ...
Processing triggers for man-db (2.9.1-1) ...
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# make linux
cd src && make linux
make[1]: Entering directory '/root/redis-6.2.6/deps/lua/src'
make all MYCFLAGS=-DLUA_USE_LINUX MYLIBS="-Wl,-E -ldl -lreadline -lhistory -lncurses"
make[2]: Entering directory '/root/redis-6.2.6/deps/lua/src'
cc -O2 -Wall -DLUA_USE_LINUX   -c -o lua.o lua.c
cc -o lua  lua.o liblua.a -lm -Wl,-E -ldl -lreadline -lhistory -lncurses
cc -O2 -Wall -DLUA_USE_LINUX   -c -o luac.o luac.c
cc -O2 -Wall -DLUA_USE_LINUX   -c -o print.o print.c
cc -o luac  luac.o print.o liblua.a -lm -Wl,-E -ldl -lreadline -lhistory -lncurses
make[2]: Leaving directory '/root/redis-6.2.6/deps/lua/src'
make[1]: Leaving directory '/root/redis-6.2.6/deps/lua/src'
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps/lua# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6/deps# cd ..
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# make
cd src && make all
make[1]: Entering directory '/root/redis-6.2.6/src'
    LINK redis-server
/usr/bin/ld: server.o: in function `clientsCronTrackExpansiveClients':
/root/redis-6.2.6/src/server.c:1733: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: server.o: in function `clientsCronTrackClientsMemUsage':
/root/redis-6.2.6/src/server.c:1753: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: /root/redis-6.2.6/src/server.c:1755: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: networking.o: in function `sdsZmallocSize':
/root/redis-6.2.6/src/networking.c:47: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: networking.o: in function `getStringObjectSdsUsedMemory':
/root/redis-6.2.6/src/networking.c:56: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: networking.o:/root/redis-6.2.6/src/networking.c:47: more undefined references to `je_malloc_usable_size' follow
/usr/bin/ld: object.o: in function `memoryCommand':
/root/redis-6.2.6/src/object.c:1454: undefined reference to `je_malloc_stats_print'
/usr/bin/ld: debug.o: in function `mallctl_int':
/root/redis-6.2.6/src/debug.c:328: undefined reference to `je_mallctl'
/usr/bin/ld: /root/redis-6.2.6/src/debug.c:331: undefined reference to `je_mallctl'
/usr/bin/ld: /root/redis-6.2.6/src/debug.c:328: undefined reference to `je_mallctl'
/usr/bin/ld: debug.o: in function `mallctl_string':
/root/redis-6.2.6/src/debug.c:362: undefined reference to `je_mallctl'
/usr/bin/ld: /root/redis-6.2.6/src/debug.c:374: undefined reference to `je_mallctl'
/usr/bin/ld: debug.o:/root/redis-6.2.6/src/debug.c:374: more undefined references to `je_mallctl' follow
/usr/bin/ld: module.o: in function `RM_MallocSize':
/root/redis-6.2.6/src/module.c:7558: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: zmalloc.o: in function `zfree':
/root/redis-6.2.6/src/zmalloc.c:291: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: zmalloc.o: in function `ztrymalloc_usable':
/root/redis-6.2.6/src/zmalloc.c:101: undefined reference to `je_malloc'
/usr/bin/ld: /root/redis-6.2.6/src/zmalloc.c:105: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: zmalloc.o: in function `ztrycalloc_usable':
/root/redis-6.2.6/src/zmalloc.c:161: undefined reference to `je_calloc'
/usr/bin/ld: /root/redis-6.2.6/src/zmalloc.c:165: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: zmalloc.o: in function `ztryrealloc_usable':
/root/redis-6.2.6/src/zmalloc.c:219: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: /root/redis-6.2.6/src/zmalloc.c:220: undefined reference to `je_realloc'
/usr/bin/ld: /root/redis-6.2.6/src/zmalloc.c:227: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: zmalloc.o: in function `zfree_usable':
/root/redis-6.2.6/src/zmalloc.c:310: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: zmalloc.o: in function `zmalloc_get_allocator_info':
/root/redis-6.2.6/src/zmalloc.c:485: undefined reference to `je_mallctl'
/usr/bin/ld: /root/redis-6.2.6/src/zmalloc.c:489: undefined reference to `je_mallctl'
/usr/bin/ld: /root/redis-6.2.6/src/zmalloc.c:492: undefined reference to `je_mallctl'
/usr/bin/ld: /root/redis-6.2.6/src/zmalloc.c:495: undefined reference to `je_mallctl'
/usr/bin/ld: zmalloc.o: in function `set_jemalloc_bg_thread':
/root/redis-6.2.6/src/zmalloc.c:503: undefined reference to `je_mallctl'
/usr/bin/ld: zmalloc.o:/root/redis-6.2.6/src/zmalloc.c:511: more undefined references to `je_mallctl' follow
/usr/bin/ld: zmalloc.o: in function `zfree':
/root/redis-6.2.6/src/zmalloc.c:292: undefined reference to `je_free'
/usr/bin/ld: zmalloc.o: in function `zfree_usable':
/root/redis-6.2.6/src/zmalloc.c:311: undefined reference to `je_free'
/usr/bin/ld: listpack.o: in function `lpShrinkToFit':
/root/redis-6.2.6/src/listpack.c:245: undefined reference to `je_malloc_usable_size'
/usr/bin/ld: listpack.o: in function `lpInsert':
/root/redis-6.2.6/src/listpack.c:722: undefined reference to `je_malloc_usable_size'
collect2: error: ld returned 1 exit status
make[1]: *** [Makefile:345: redis-server] Error 1
make[1]: Leaving directory '/root/redis-6.2.6/src'
make: *** [Makefile:6: all] Error 2
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6# ls
00-RELEASENOTES  CONTRIBUTING  MANIFESTO  TLS.md      runtest            runtest-sentinel  tests
BUGS             COPYING       Makefile   deps        runtest-cluster    sentinel.conf     utils
CONDUCT          INSTALL       README.md  redis.conf  runtest-moduleapi  src
root@ubuntu-s-1vcpu-1gb-blr1-01:~/redis-6.2.6#
```

https://packages.ubuntu.com/search?keywords=readline

```bash
root@ubuntu-s-1vcpu-1gb-blr1-01:~# sudo add-apt-repository ppa:redislabs/redis

 Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes with radius queries and streams.

Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.
 More info: https://launchpad.net/~redislabs/+archive/ubuntu/redis
Press [ENTER] to continue or Ctrl-c to cancel adding it.

Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease
Hit:3 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease
Hit:4 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease
Get:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease [18.0 kB]
Get:6 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Get:7 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 Packages [1016 B]
Get:8 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main Translation-en [584 B]
Fetched 133 kB in 1s (96.2 kB/s)
Reading package lists... Done
root@ubuntu-s-1vcpu-1gb-blr1-01:~#
root@ubuntu-s-1vcpu-1gb-blr1-01:~# apt update
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease
Hit:3 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease
Hit:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease
Hit:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease
Hit:6 http://security.ubuntu.com/ubuntu focal-security InRelease
Reading package lists... Done
Building dependency tree
Reading state information... Done
18 packages can be upgraded. Run 'apt list --upgradable' to see them.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# apt install redis-server
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  redis-tools
Suggested packages:
  ruby-redis
The following NEW packages will be installed:
  redis-server redis-tools
0 upgraded, 2 newly installed, 0 to remove and 18 not upgraded.
Need to get 1150 kB of archives.
After this operation, 6794 kB of additional disk space will be used.
Do you want to continue? [Y/n]
Get:1 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-tools amd64 6:6.2.6-1rl1~focal1 [1067 kB]
Get:2 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-server amd64 6:6.2.6-1rl1~focal1 [82.4 kB]
Fetched 1150 kB in 2s (572 kB/s)
Selecting previously unselected package redis-tools.
(Reading database ... 69414 files and directories currently installed.)
Preparing to unpack .../redis-tools_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-tools (6:6.2.6-1rl1~focal1) ...
Selecting previously unselected package redis-server.
Preparing to unpack .../redis-server_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-server (6:6.2.6-1rl1~focal1) ...
Setting up redis-tools (6:6.2.6-1rl1~focal1) ...
Setting up redis-server (6:6.2.6-1rl1~focal1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-server
29344:C 30 Oct 2021 05:32:18.920 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
29344:C 30 Oct 2021 05:32:18.920 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=29344, just started
29344:C 30 Oct 2021 05:32:18.920 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
29344:M 30 Oct 2021 05:32:18.922 * Increased maximum number of open files to 10032 (it was originally set to 1024).
29344:M 30 Oct 2021 05:32:18.922 * monotonic clock: POSIX clock_gettime
29344:M 30 Oct 2021 05:32:18.922 # Warning: Could not create server TCP listening socket *:6379: bind: Address already in use
29344:M 30 Oct 2021 05:32:18.922 # Failed listening on port 6379 (TCP), aborting.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# systemctl status redis
Unit redis.service could not be found.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sat 2021-10-30 05:32:10 UTC; 23s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 29156 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.2M
     CGroup: /system.slice/redis-server.service
             └─29156 /usr/bin/redis-server 127.0.0.1:6379

Oct 30 05:32:09 ubuntu-s-1vcpu-1gb-blr1-01 systemd[1]: Starting Advanced key-value store...
Oct 30 05:32:10 ubuntu-s-1vcpu-1gb-blr1-01 systemd[1]: Started Advanced key-value store.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-c
redis-check-aof  redis-check-rdb  redis-cli
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-cli
127.0.0.1:6379> info
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:29156
process_supervised:systemd
run_id:5a29f8a3d34e321cfb3fb5b33bd24c51f66c7172
tcp_port:6379
server_time_usec:1635572009907181
uptime_in_seconds:79
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:8182057
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0

# Clients
connected_clients:1
cluster_connections:0
maxclients:10000
client_recent_max_input_buffer:16
client_recent_max_output_buffer:0
blocked_clients:0
tracking_clients:0
clients_in_timeout_table:0

# Memory
used_memory:873736
used_memory_human:853.26K
used_memory_rss:8990720
used_memory_rss_human:8.57M
used_memory_peak:931888
used_memory_peak_human:910.05K
used_memory_peak_perc:93.76%
used_memory_overhead:830504
used_memory_startup:810008
used_memory_dataset:43232
used_memory_dataset_perc:67.84%
allocator_allocated:1034272
allocator_active:1359872
allocator_resident:3907584
total_system_memory:1028956160
total_system_memory_human:981.29M
used_memory_lua:37888
used_memory_lua_human:37.00K
used_memory_scripts:0
used_memory_scripts_human:0B
number_of_cached_scripts:0
maxmemory:0
maxmemory_human:0B
maxmemory_policy:noeviction
allocator_frag_ratio:1.31
allocator_frag_bytes:325600
allocator_rss_ratio:2.87
allocator_rss_bytes:2547712
rss_overhead_ratio:2.30
rss_overhead_bytes:5083136
mem_fragmentation_ratio:10.82
mem_fragmentation_bytes:8159752
mem_not_counted_for_evict:0
mem_replication_backlog:0
mem_clients_slaves:0
mem_clients_normal:20496
mem_aof_buffer:0
mem_allocator:jemalloc-5.1.0
active_defrag_running:0
lazyfree_pending_objects:0
lazyfreed_objects:0

# Persistence
loading:0
current_cow_size:0
current_cow_size_age:0
current_fork_perc:0.00
current_save_keys_processed:0
current_save_keys_total:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1635571930
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:-1
rdb_current_bgsave_time_sec:-1
rdb_last_cow_size:0
aof_enabled:0
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
aof_last_cow_size:0
module_fork_in_progress:0
module_fork_last_cow_size:0

# Stats
total_connections_received:1
total_commands_processed:1
instantaneous_ops_per_sec:0
total_net_input_bytes:31
total_net_output_bytes:20324
instantaneous_input_kbps:0.00
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:0
sync_partial_ok:0
sync_partial_err:0
expired_keys:0
expired_stale_perc:0.00
expired_time_cap_reached_count:0
expire_cycle_cpu_milliseconds:1
evicted_keys:0
keyspace_hits:0
keyspace_misses:0
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:0
total_forks:0
migrate_cached_sockets:0
slave_expires_tracked_keys:0
active_defrag_hits:0
active_defrag_misses:0
active_defrag_key_hits:0
active_defrag_key_misses:0
tracking_total_keys:0
tracking_total_items:0
tracking_total_prefixes:0
unexpected_error_replies:0
total_error_replies:0
dump_payload_sanitizations:0
total_reads_processed:2
total_writes_processed:1
io_threaded_reads_processed:0
io_threaded_writes_processed:0

# Replication
role:master
connected_slaves:0
master_failover_state:no-failover
master_replid:0d82b60f33bc3e2660d1cdb7fb0ad03c40031fb3
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# CPU
used_cpu_sys:0.142885
used_cpu_user:0.078108
used_cpu_sys_children:0.000000
used_cpu_user_children:0.000000
used_cpu_sys_main_thread:0.144897
used_cpu_user_main_thread:0.075998

# Modules

# Errorstats

# Cluster
cluster_enabled:0

# Keyspace
127.0.0.1:6379>
root@ubuntu-s-1vcpu-1gb-blr1-01:~# ifconfig

Command 'ifconfig' not found, but can be installed with:

apt install net-tools

root@ubuntu-s-1vcpu-1gb-blr1-01:~# apt install net-tools
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  net-tools
0 upgraded, 1 newly installed, 0 to remove and 18 not upgraded.
Need to get 196 kB of archives.
After this operation, 864 kB of additional disk space will be used.
Get:1 http://mirrors.digitalocean.com/ubuntu focal/main amd64 net-tools amd64 1.60+git20180626.aebd88e-1ubuntu1 [196 kB]
Fetched 196 kB in 0s (1083 kB/s)
Selecting previously unselected package net-tools.
(Reading database ... 69451 files and directories currently installed.)
Preparing to unpack .../net-tools_1.60+git20180626.aebd88e-1ubuntu1_amd64.deb ...
Unpacking net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Setting up net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Processing triggers for man-db (2.9.1-1) ...

root@ubuntu-s-1vcpu-1gb-blr1-01:~#
root@ubuntu-s-1vcpu-1gb-blr1-01:~# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 139.59.5.149  netmask 255.255.240.0  broadcast 139.59.15.255
        inet6 fe80::8c9e:8dff:fea5:eb6d  prefixlen 64  scopeid 0x20<link>
        ether 8e:9e:8d:a5:eb:6d  txqueuelen 1000  (Ethernet)
        RX packets 19020  bytes 60150647 (60.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 13832  bytes 1599511 (1.5 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.122.0.2  netmask 255.255.240.0  broadcast 10.122.15.255
        inet6 fe80::5861:aaff:fe8f:7646  prefixlen 64  scopeid 0x20<link>
        ether 5a:61:aa:8f:76:46  txqueuelen 1000  (Ethernet)
        RX packets 14  bytes 1056 (1.0 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15  bytes 1146 (1.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 322  bytes 52983 (52.9 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 322  bytes 52983 (52.9 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@ubuntu-s-1vcpu-1gb-blr1-01:~# curl ifconfig.me
139.59.5.149root@ubuntu-s-1vcpu-1gb-blr1-01:~#
```

```bash
~ $ telnet 139.59.5.149 6379
Trying 139.59.5.149...
telnet: connect to address 139.59.5.149: Connection refused
telnet: Unable to connect to remote host
```

https://duckduckgo.com/?t=ffab&q=find+which+malloc+is+used+in+redis&ia=web

```bash
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-cli
127.0.0.1:6379> memory
(error) ERR wrong number of arguments for 'memory' command
127.0.0.1:6379> memory stats
 1) "peak.allocated"
 2) (integer) 931888
 3) "total.allocated"
 4) (integer) 872024
 5) "startup.allocated"
 6) (integer) 810008
 7) "replication.backlog"
 8) (integer) 0
 9) "clients.slaves"
10) (integer) 0
11) "clients.normal"
12) (integer) 20496
13) "aof.buffer"
14) (integer) 0
15) "lua.caches"
16) (integer) 0
17) "overhead.total"
18) (integer) 830504
19) "keys.count"
20) (integer) 0
21) "keys.bytes-per-key"
22) (integer) 0
23) "dataset.bytes"
24) (integer) 41520
25) "dataset.percentage"
26) "66.950462341308594"
27) "peak.percentage"
28) "93.5760498046875"
29) "allocator.allocated"
30) (integer) 978528
31) "allocator.active"
32) (integer) 1277952
33) "allocator.resident"
34) (integer) 3514368
35) "allocator-fragmentation.ratio"
36) "1.3059942722320557"
37) "allocator-fragmentation.bytes"
38) (integer) 299424
39) "allocator-rss.ratio"
40) "2.75"
41) "allocator-rss.bytes"
42) (integer) 2236416
43) "rss-overhead.ratio"
44) "2.5419580936431885"
45) "rss-overhead.bytes"
46) (integer) 5419008
47) "fragmentation"
48) "10.750151634216309"
49) "fragmentation.bytes"
50) (integer) 8102376
127.0.0.1:6379>
root@ubuntu-s-1vcpu-1gb-blr1-01:~# ls /var/lo
local/ lock/  log/
root@ubuntu-s-1vcpu-1gb-blr1-01:~# ls /var/lo
local/ lock/  log/
root@ubuntu-s-1vcpu-1gb-blr1-01:~# ls /var/log/
alternatives.log          cloud-init.log            journal/                  redis/
apt/                      dist-upgrade/             kern.log                  syslog
auth.log                  dmesg                     landscape/                ubuntu-advantage.log
btmp                      dpkg.log                  lastlog                   unattended-upgrades/
cloud-init-output.log     droplet-agent.update.log  private/                  wtmp
root@ubuntu-s-1vcpu-1gb-blr1-01:~# ls /var/log/redis/redis-server.log
/var/log/redis/redis-server.log
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cat /var/log/redis/redis-server.log
29156:C 30 Oct 2021 05:32:10.037 * Supervised by systemd. Please make sure you set appropriate values for TimeoutStartSec and TimeoutStopSec in your service unit.
29156:C 30 Oct 2021 05:32:10.037 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
29156:C 30 Oct 2021 05:32:10.037 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=29156, just started
29156:C 30 Oct 2021 05:32:10.037 # Configuration loaded
29156:M 30 Oct 2021 05:32:10.038 * monotonic clock: POSIX clock_gettime
29156:M 30 Oct 2021 05:32:10.041 * Running mode=standalone, port=6379.
29156:M 30 Oct 2021 05:32:10.041 # Server initialized
29156:M 30 Oct 2021 05:32:10.041 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
29156:M 30 Oct 2021 05:32:10.044 * Ready to accept connections
root@ubuntu-s-1vcpu-1gb-blr1-01:~#
```

https://duckduckgo.com/?q=redis+memory+allocation&t=ffab&ia=web&iax=qa

https://redis.io/commands/#server

https://redis.io/commands/memory-malloc-stats - only works for jemalloc

```bash
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-cli
127.0.0.1:6379> memory malloc-stats
___ Begin jemalloc statistics ___
Version: "5.1.0-0-g0"
Build-time option settings
  config.cache_oblivious: true
  config.debug: false
  config.fill: true
  config.lazy_lock: false
  config.malloc_conf: ""
  config.prof: false
  config.prof_libgcc: false
  config.prof_libunwind: false
  config.stats: true
  config.utrace: false
  config.xmalloc: false
Run-time option settings
  opt.abort: false
  opt.abort_conf: false
  opt.retain: true
  opt.dss: "secondary"
  opt.narenas: 1
  opt.percpu_arena: "disabled"
  opt.metadata_thp: "disabled"
  opt.background_thread: false (background_thread: true)
  opt.dirty_decay_ms: 10000 (arenas.dirty_decay_ms: 10000)
  opt.muzzy_decay_ms: 10000 (arenas.muzzy_decay_ms: 10000)
  opt.junk: "false"
  opt.zero: false
  opt.tcache: true
  opt.lg_tcache_max: 15
  opt.thp: "default"
  opt.stats_print: false
  opt.stats_print_opts: ""
Arenas: 1
Quantum size: 8
Page size: 4096
Maximum thread-cached size class: 32768
Number of bin size classes: 39
Number of thread-cache bin size classes: 44
Number of large size classes: 196
Allocated: 992288, active: 1273856, metadata: 2263448 (n_thp 0), resident: 3510272, mapped: 7565312, retained: 823296
Background threads: 1, num_runs: 25, run_interval: 19713535560 ns
                           n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
background_thread                9939               0               0               1               0               0           0
ctl                             19871               0               0               1               0               0           0
prof                                0               0               0               0               0               0           0
arenas[0]:
assigned threads: 1
uptime: 498487536985
dss allocation precedence: "secondary"
decaying:  time       npages       sweeps     madvises       purged
   dirty: 10000            0           24           28          178
   muzzy: 10000            0           23           27          167
                            allocated     nmalloc     ndalloc   nrequests
small:                         295968       16295        3515       25036
large:                         696320          21          12          21
total:                         992288       16316        3527       25057

active:                       1273856
mapped:                       7565312
retained:                      823296
base:                         2230672
internal:                       32776
metadata_thp:                       0
tcache_bytes:                   67000
resident:                     3510272
                           n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
large                            4970               0               0               1               0               0           0
extent_avail                     5126               0               0              21               0               0           0
extents_dirty                    5252               0               0              51               0               0           0
extents_muzzy                    5117               0               0              31               0               0           0
extents_retained                 5188               0               0              29               0               0           0
decay_dirty                      5066               0               0              51               0               0           0
decay_muzzy                      5045               0               0              29               0               0           0
base                            10064               0               0               3               0               0           0
tcache_list                      4970               0               0               1               0               0           0
bins:           size ind    allocated      nmalloc      ndalloc    nrequests      curregs     curslabs regs pgs   util       nfills     nflushes       nslabs     nreslabs      n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
                   8   0         2584          801          478         4046          323            2  512   1  0.315            8            7            2            1            4987               0               0               1               0               0           0
                  16   1       171792        10800           63        12974        10737           42  256   1  0.998          108            1           43            0            5122               0               0               1               0               0           0
                  24   2        23688         1950          963         4372          987            3  512   3  0.642           23           10            3            5            5005               0               0               1               0               0           0
                  32   3         2080          200          135          404           65            2  128   1  0.253            2            3            2            1            4976               0               0               1               0               0           0
                  40   4         1920          100           52          204           48            1  512   5  0.093            1            4            1            0            4975               0               0               1               0               0           0
                  48   5         6768          175           34          821          141            1  256   3  0.550            4            3            1            0            4977               0               0               1               0               0           0
                  56   6         4816          125           39          249           86            1  512   7  0.167            2            3            1            0            4975               0               0               1               0               0           0
                  64   7         4928          320          243          418           77            2   64   1  0.601            6            4            5            3            4987               0               0               1               0               0           0
                  80   8        12400          850          695         1084          155            1  256   5  0.605            9            8            4            1            4993               0               0               1               0               0           0
                  96   9        10752          300          188          412          112            1  128   3  0.875            3            4            3            0            4981               0               0               1               0               0           0
                 112  10          224          100           98            6            2            1  256   7  0.007            1            4            1            0            4975               0               0               1               0               0           0
                 128  11            0           32           32            5            0            0   32   1      1            1            3            1            0            4975               0               0               1               0               0           0
                 160  12          320          100           98            3            2            1  128   5  0.015            1            3            1            0            4974               0               0               1               0               0           0
                 192  13          384           64           62            4            2            1   64   3  0.031            1            3            1            0            4974               0               0               1               0               0           0
                 224  14          448          100           98            2            2            1  128   7  0.015            1            3            1            0            4974               0               0               1               0               0           0
                 256  15            0           16           16            4            0            0   16   1      1            1            3            1            0            4975               0               0               1               0               0           0
                 320  16         5120           64           48            1           16            1   64   5  0.250            1            1            1            0            4972               0               0               1               0               0           0
                 384  17          384           32           31            1            1            1   32   3  0.031            1            3            1            0            4974               0               0               1               0               0           0
                 448  18            0            0            0            0            0            0   64   7      1            0            0            0            0            4969               0               0               1               0               0           0
                     ---
                 512  19          512           12           11            4            1            1    8   1  0.125            2            3            3            0            4979               0               0               1               0               0           0
                 640  20            0           32           32            3            0            0   32   5      1            1            3            1            0            4975               0               0               1               0               0           0
                 768  21            0            0            0            0            0            0   16   3      1            0            0            0            0            4969               0               0               1               0               0           0
                 896  22            0            0            0            0            0            0   32   7      1            0            0            0            0            4969               0               0               1               0               0           0
                     ---
                1024  23            0           10           10            3            0            0    4   1      1            1            3            3            0            4979               0               0               1               0               0           0
                1280  24         1280           16           15            3            1            1   16   5  0.062            1            3            1            0            4974               0               0               1               0               0           0
                1536  25            0           10           10            1            0            0    8   3      1            1            2            2            0            4976               0               0               1               0               0           0
                1792  26        28672           16            0            0           16            1   16   7      1            1            0            1            0            4971               0               0               1               0               0           0
                2048  27         6144           10            7            3            3            2    2   1  0.750            1            2            5            0            4980               0               0               1               0               0           0
                2560  28         2560           10            9            3            1            1    8   5  0.125            1            2            2            0            4975               0               0               1               0               0           0
                3072  29            0            0            0            0            0            0    4   3      1            0            0            0            0            4969               0               0               1               0               0           0
                     ---
                3584  30            0           10           10            1            0            0    8   7      1            1            2            2            0            4976               0               0               1               0               0           0
                4096  31         8192           10            8            2            2            2    1   1      1            1            2           10            0            4990               0               0               1               0               0           0
                5120  32            0           10           10            1            0            0    4   5      1            1            2            3            0            4978               0               0               1               0               0           0
                6144  33            0            0            0            0            0            0    2   3      1            0            0            0            0            4969               0               0               1               0               0           0
                7168  34            0            0            0            0            0            0    4   7      1            0            0            0            0            4969               0               0               1               0               0           0
                     ---
                8192  35            0           10           10            1            0            0    1   2      1            1            2           10            0            4992               0               0               1               0               0           0
               10240  36            0           10           10            1            0            0    2   5      1            1            2            5            0            4982               0               0               1               0               0           0
               12288  37            0            0            0            0            0            0    1   3      1            0            0            0            0            4969               0               0               1               0               0           0
               14336  38            0            0            0            0            0            0    2   7      1            0            0            0            0            4969               0               0               1               0               0           0
                     ---
large:          size ind    allocated      nmalloc      ndalloc    nrequests  curlextents
               16384  39            0            1            1            1            0
               20480  40        81920            5            1            5            4
                     ---
               32768  43        32768            1            0            1            1
               40960  44        40960            9            8            9            1
               49152  45            0            1            1            1            0
                     ---
               81920  48        81920            1            0            1            1
                     ---
              114688  50            0            1            1            1            0
              131072  51       131072            1            0            1            1
                     ---
              327680  56       327680            1            0            1            1
                     ---
--- End jemalloc statistics ---
127.0.0.1:6379>
```

```bash
root@ubuntu-s-1vcpu-1gb-blr1-01:~# systemctl status redis
Unit redis.service could not be found.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sat 2021-10-30 05:32:10 UTC; 1h 47min ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 29156 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.2M
     CGroup: /system.slice/redis-server.service
             └─29156 /usr/bin/redis-server 127.0.0.1:6379

Oct 30 05:32:09 ubuntu-s-1vcpu-1gb-blr1-01 systemd[1]: Starting Advanced key-value store...
Oct 30 05:32:10 ubuntu-s-1vcpu-1gb-blr1-01 systemd[1]: Started Advanced key-value store.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# cat /lib/systemd/system/redis-server.service
[Unit]
Description=Advanced key-value store
After=network.target
Documentation=http://redis.io/documentation, man:redis-server(1)

[Service]
Type=notify
ExecStart=/usr/bin/redis-server /etc/redis/redis.conf
ExecStop=/bin/kill -s TERM $MAINPID
PIDFile=/run/redis/redis-server.pid
TimeoutStopSec=0
Restart=always
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=2755

UMask=007
PrivateTmp=yes
LimitNOFILE=65535
PrivateDevices=yes
ProtectHome=yes
ReadOnlyDirectories=/
ReadWriteDirectories=-/var/lib/redis
ReadWriteDirectories=-/var/log/redis
ReadWriteDirectories=-/run/redis

NoNewPrivileges=true
CapabilityBoundingSet=CAP_SETGID CAP_SETUID CAP_SYS_RESOURCE
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
MemoryDenyWriteExecute=true
ProtectKernelModules=true
ProtectKernelTunables=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictNamespaces=true

# redis-server can write to its own config file when in cluster mode so we
# permit writing there by default. If you are not using this feature, it is
# recommended that you replace the following lines with "ProtectSystem=full".
ProtectSystem=true
ReadWriteDirectories=-/etc/redis

[Install]
WantedBy=multi-user.target
Alias=redis.service
root@ubuntu-s-1vcpu-1gb-blr1-01:~# vi /etc/redis/redis.conf
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-cli ACL GEN
(error) ERR Unknown subcommand or wrong number of arguments for 'GEN'. Try ACL HELP.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-cli ACL HELP
 1) ACL <subcommand> [<arg> [value] [opt] ...]. Subcommands are:
 2) CAT [<category>]
 3)     List all commands that belong to <category>, or all command categories
 4)     when no category is specified.
 5) DELUSER <username> [<username> ...]
 6)     Delete a list of users.
 7) GETUSER <username>
 8)     Get the user's details.
 9) GENPASS [<bits>]
10)     Generate a secure 256-bit user password. The optional `bits` argument can
11)     be used to specify a different size.
12) LIST
13)     Show users details in config file format.
14) LOAD
15)     Reload users from the ACL file.
16) LOG [<count> | RESET]
17)     Show the ACL log entries.
18) SAVE
19)     Save the current config to the ACL file.
20) SETUSER <username> <attribute> [<attribute> ...]
21)     Create or modify a user with the specified attributes.
22) USERS
23)     List all the registered usernames.
24) WHOAMI
25)     Return the current connection username.
26) HELP
27)     Prints this help.
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-cli ACL GENPASS
"e07298ecf7f56b7877d5f757ecc1faf6379baa6870b2511c52a33a80fad225aa"
root@ubuntu-s-1vcpu-1gb-blr1-01:~# redis-cli
127.0.0.1:6379> ACL GENPASS
"79ed52ffc63da1e60d77c41e8bc2c3fa303ad2de425b7f010bd7df1f160d2874"
127.0.0.1:6379>
root@ubuntu-s-1vcpu-1gb-blr1-01:~# vi /etc/redis/redis.conf
root@ubuntu-s-1vcpu-1gb-blr1-01:~# system
systemctl                       systemd-escape                  systemd-run
systemd                         systemd-hwdb                    systemd-socket-activate
systemd-analyze                 systemd-id128                   systemd-stdio-bridge
systemd-ask-password            systemd-inhibit                 systemd-sysusers
systemd-cat                     systemd-machine-id-setup        systemd-tmpfiles
systemd-cgls                    systemd-mount                   systemd-tty-ask-password-agent
systemd-cgtop                   systemd-notify                  systemd-umount
systemd-delta                   systemd-path
systemd-detect-virt             systemd-resolve
root@ubuntu-s-1vcpu-1gb-blr1-01:~# systemctl restart redis-server
root@ubuntu-s-1vcpu-1gb-blr1-01:~#
```

```bash
database-stuff $ telnet 139.59.5.149 6379
Trying 139.59.5.149...
telnet: connect to address 139.59.5.149: Connection refused
telnet: Unable to connect to remote host
^C
database-stuff $ telnet 139.59.5.149 56379
Trying 139.59.5.149...
Connected to 139.59.5.149.
Escape character is '^]'.
^]
telnet> Connection closed.
database-stuff $ redis-cli -h 139.59.5.149 -p 56379
139.59.5.149:56379> ping
(error) NOAUTH Authentication required.
139.59.5.149:56379> AUTH e07298ecf7f56b7877d5f757ecc1faf6379baa6870b2511c52a33a80fad225aa
OK
139.59.5.149:56379> PING
PONG
139.59.5.149:56379>
database-stuff $
```

```bash
root@ubuntu-s-1vcpu-1gb-blr1-01:~# df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            474M     0  474M   0% /dev
tmpfs            99M  968K   98M   1% /run
/dev/vda1        25G  2.3G   22G  10% /
tmpfs           491M     0  491M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           491M     0  491M   0% /sys/fs/cgroup
/dev/loop0       62M   62M     0 100% /snap/core20/1081
/dev/loop1       68M   68M     0 100% /snap/lxd/21545
/dev/loop2       33M   33M     0 100% /snap/snapd/13170
/dev/vda15      105M  5.2M  100M   5% /boot/efi
/dev/sda        9.8G   37M  9.3G   1% /mnt/volume_blr1_01
tmpfs            99M     0   99M   0% /run/user/0
root@ubuntu-s-1vcpu-1gb-blr1-01:~#
```

Below is the external disk that I had created

```
/dev/sda        9.8G   37M  9.3G   1% /mnt/volume_blr1_01
```

---

```bash
database-stuff $ doctl compute droplet
A Droplet is a DigitalOcean virtual machine. Use the subcommands of `doctl compute droplet` to list, create, or delete Droplets.

Usage:
  doctl compute droplet [command]

Aliases:
  droplet, d

Available Commands:
  1-click     Display commands that pertain to Droplet 1-click applications
  actions     List Droplet actions
  backups     List Droplet backups
  create      Create a new Droplet
  delete      Permanently delete a Droplet
  get         Retrieve information about a Droplet
  kernels     List available Droplet kernels
  list        List Droplets on your account
  neighbors   List a Droplet's neighbors on your account
  snapshots   List all snapshots for a Droplet
  tag         Add a tag to a Droplet
  untag       Remove a tag from a Droplet

Flags:
  -h, --help   help for droplet

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute droplet [command] --help" for more information about a command.
database-stuff $ doctl compute droplet list
Error: Unable to initialize DigitalOcean API client: access token is required. (hint: run 'doctl auth init')
database-stuff $ doctl auth init
Please authenticate doctl for use with your DigitalOcean account. You can generate a token in the control panel at https://cloud.digitalocean.com/account/api/tokens

Enter your access token: 
database-stuff $ doctl auth list
default (current)
database-stuff $ doctl auth init
Please authenticate doctl for use with your DigitalOcean account. You can generate a token in the control panel at https://cloud.digitalocean.com/account/api/tokens

Enter your access token: 
Validating token... OK

database-stuff $ doctl compute droplet list
ID    Name    Public IPv4    Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image    VPC UUID    Status    Tags    Features    Volumes
database-stuff $ doctl auth init
Using token [9c492891c52ccea39cab9abc0aedd7a2a87c0b37d90947aa897d0be2cea1e8e4]

Validating token... OK

database-stuff $ doctl auth init -g
Error: unknown shorthand flag: 'g' in -g
Usage:
  doctl auth init [flags]

Flags:
  -h, --help   help for init

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

unknown shorthand flag: 'g' in -g
database-stuff $ doctl auth init -h
This command allows you to initialize doctl with a token that allows it to query and manage your account details and resources.

You will need an API token, which you can generate in the control panel at https://cloud.digitalocean.com/account/api/tokens.

You can provide a name to this initialization via the `--context` flag, and then it will be saved as an "authentication context". Authentication contexts are accessible via `doctl auth switch`, which re-initializes doctl, or by providing the `--context` flag when using any doctl command (to specify that auth context for just one command). This enables you to use multiple DigitalOcean accounts with doctl, or tokens that have different authentication scopes.

If the `--context` flag is not specified, a default authentication context will be created during initialization.

If doctl is never initialized, you will need to specify an API token whenever you use a `doctl` command via the `--access-token` flag.

Usage:
  doctl auth init [flags]

Flags:
  -h, --help   help for init

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl auth list
default (current)
database-stuff $ doctl auth 
The `doctl auth` commands allow you to authenticate doctl for use with your DigitalOcean account using tokens that you generate in the control panel at https://cloud.digitalocean.com/account/api/tokens.

If you work with a just one account, you can call `doctl auth init` and supply the token when prompted. This creates an authentication context named `default`.

To switch between multiple DigitalOcean accounts, including team accounts, you can create named contexts by using `doctl auth init --context <name>`, then providing a token when prompted. This saves the token under the name you provide. To switch between accounts, use `doctl auth switch --context <name>`.,

To remove accounts from the configuration file, you can run `doctl auth remove --context <name>`. This removes the token under the name you provide.

Usage:
  doctl auth [command]

Available Commands:
  init        Initialize doctl to use a specific account
  list        List available authentication contexts
  remove      Remove authentication contexts 
  switch      Switches between authentication contexts

Flags:
  -h, --help   help for auth

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl auth [command] --help" for more information about a command.
database-stuff $ doctl auth init --context write
Please authenticate doctl for use with your DigitalOcean account. You can generate a token in the control panel at https://cloud.digitalocean.com/account/api/tokens

Enter your access token: 
Validating token... OK

database-stuff $ doctl auth list
default (current)
write
database-stuff $ doctl auth switch
Now using context [default] by default
database-stuff $ doctl auth switch write
Now using context [default] by default
database-stuff $ doctl auth list
default (current)
write
database-stuff $ doctl auth switch -h
This command allows you to switch between accounts with authentication contexts you've already created.

To see a list of available authentication contexts, call `doctl auth list`.

For details on creating an authentication context, see the help for `doctl auth init`.

Usage:
  doctl auth switch [flags]

Flags:
  -h, --help   help for switch

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl auth switch --context write
Now using context [write] by default
database-stuff $ doctl auth list
default
write (current)
database-stuff $ doctl compute droplet -h
A Droplet is a DigitalOcean virtual machine. Use the subcommands of `doctl compute droplet` to list, create, or delete Droplets.

Usage:
  doctl compute droplet [command]

Aliases:
  droplet, d

Available Commands:
  1-click     Display commands that pertain to Droplet 1-click applications
  actions     List Droplet actions
  backups     List Droplet backups
  create      Create a new Droplet
  delete      Permanently delete a Droplet
  get         Retrieve information about a Droplet
  kernels     List available Droplet kernels
  list        List Droplets on your account
  neighbors   List a Droplet's neighbors on your account
  snapshots   List all snapshots for a Droplet
  tag         Add a tag to a Droplet
  untag       Remove a tag from a Droplet

Flags:
  -h, --help   help for droplet

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute droplet [command] --help" for more information about a command.
database-stuff $ doctl compute droplet create -h
Use this command to create a new Droplet. Required values are name, region, size, and image. For example, to create an Ubuntu 20.04 with 1 vCPU and 1 GB of RAM in the NYC1 datacenter region, run:

	doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region nyc1 example.com

Usage:
  doctl compute droplet create <droplet-name>... [flags]

Aliases:
  create, c

Flags:
      --droplet-agent true          By default, the agent is installed on new Droplets but installation errors are ignored. Set --droplet-agent=false to prevent installation. Set true to make installation errors fatal.
      --enable-backups              Enables backups for the Droplet
      --enable-ipv6                 Enables IPv6 support and assigns an IPv6 address
      --enable-monitoring           Install the DigitalOcean agent for additional monitoring
      --enable-private-networking   Enables private networking for the Droplet by provisioning it inside of your account's default VPC for the region
      --format ID                   Columns for output in a comma-separated list. Possible values: ID, `Name`, `PublicIPv4`, `PrivateIPv4`, `PublicIPv6`, `Memory`, `VCPUs`, `Disk`, `Region`, `Image`, `VPCUUID`, `Status`, `Tags`, `Features`, `Volumes`
  -h, --help                        help for create
      --image ubuntu-20-04-x64      An ID or slug indicating the image the Droplet will be based-on (e.g. ubuntu-20-04-x64). Use the commands under `doctl compute image` to find additional images. (required)
      --no-header                   Return raw data with no headers
      --region nyc1                 A slug indicating the region where the Droplet will be created (e.g. nyc1). Run `doctl compute region list` for a list of valid regions. (required)
      --size s-1vcpu-1gb            A slug indicating the size of the Droplet (e.g. s-1vcpu-1gb). Run `doctl compute size list` for a list of valid sizes. (required)
      --ssh-keys strings            A list of SSH key fingerprints or IDs of the SSH keys to embed in the Droplet's root account upon creation
      --tag-name string             A tag name to be applied to the Droplet
      --tag-names strings           A list of tag names to be applied to the Droplet
      --user-data string            User-data to configure the Droplet on first boot
      --user-data-file string       The path to a file containing user-data to configure the Droplet on first boot
      --volumes strings             A list of block storage volume IDs to attach to the Droplet
      --vpc-uuid string             The UUID of a non-default VPC to create the Droplet in
      --wait                        Wait for Droplet creation to complete before returning

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute region list
Slug    Name               Available
nyc1    New York 1         true
sfo1    San Francisco 1    false
nyc2    New York 2         false
ams2    Amsterdam 2        false
sgp1    Singapore 1        true
lon1    London 1           true
nyc3    New York 3         true
ams3    Amsterdam 3        true
fra1    Frankfurt 1        true
tor1    Toronto 1          true
sfo2    San Francisco 2    false
blr1    Bangalore 1        true
sfo3    San Francisco 3    true
database-stuff $ doctl compute size list
Slug                  Memory    VCPUs    Disk    Price Monthly    Price Hourly
s-1vcpu-1gb           1024      1        25      5.00             0.007440
s-1vcpu-1gb-amd       1024      1        25      6.00             0.008930
s-1vcpu-1gb-intel     1024      1        25      6.00             0.008930
s-1vcpu-2gb           2048      1        50      10.00            0.014880
s-1vcpu-2gb-amd       2048      1        50      12.00            0.017860
s-1vcpu-2gb-intel     2048      1        50      12.00            0.017860
s-2vcpu-2gb           2048      2        60      15.00            0.022320
s-2vcpu-2gb-amd       2048      2        60      18.00            0.026790
s-2vcpu-2gb-intel     2048      2        60      18.00            0.026790
s-2vcpu-4gb           4096      2        80      20.00            0.029760
s-2vcpu-4gb-amd       4096      2        80      24.00            0.035710
s-2vcpu-4gb-intel     4096      2        80      24.00            0.035710
s-4vcpu-8gb           8192      4        160     40.00            0.059520
c-2                   4096      2        25      40.00            0.059520
c2-2vcpu-4gb          4096      2        50      45.00            0.066960
s-4vcpu-8gb-amd       8192      4        160     48.00            0.071430
s-4vcpu-8gb-intel     8192      4        160     48.00            0.071430
g-2vcpu-8gb           8192      2        25      60.00            0.089290
gd-2vcpu-8gb          8192      2        50      65.00            0.096730
s-8vcpu-16gb          16384     8        320     80.00            0.119050
m-2vcpu-16gb          16384     2        50      80.00            0.119050
c-4                   8192      4        50      80.00            0.119050
c2-4vcpu-8gb          8192      4        100     90.00            0.133930
s-8vcpu-16gb-amd      16384     8        320     96.00            0.142860
s-8vcpu-16gb-intel    16384     8        320     96.00            0.142860
m3-2vcpu-16gb         16384     2        150     100.00           0.148810
g-4vcpu-16gb          16384     4        50      120.00           0.178570
so-2vcpu-16gb         16384     2        300     125.00           0.186010
m6-2vcpu-16gb         16384     2        300     125.00           0.186010
gd-4vcpu-16gb         16384     4        100     130.00           0.193450
so1_5-2vcpu-16gb      16384     2        450     155.00           0.230650
m-4vcpu-32gb          32768     4        100     160.00           0.238100
c-8                   16384     8        100     160.00           0.238100
c2-8vcpu-16gb         16384     8        200     180.00           0.267860
m3-4vcpu-32gb         32768     4        300     195.00           0.290180
g-8vcpu-32gb          32768     8        100     240.00           0.357140
so-4vcpu-32gb         32768     4        600     250.00           0.372020
m6-4vcpu-32gb         32768     4        600     250.00           0.372020
gd-8vcpu-32gb         32768     8        200     260.00           0.386900
so1_5-4vcpu-32gb      32768     4        900     310.00           0.461310
m-8vcpu-64gb          65536     8        200     320.00           0.476190
c-16                  32768     16       200     320.00           0.476190
c2-16vcpu-32gb        32768     16       400     360.00           0.535710
m3-8vcpu-64gb         65536     8        600     390.00           0.580360
g-16vcpu-64gb         65536     16       200     480.00           0.714290
so-8vcpu-64gb         65536     8        1200    500.00           0.744050
m6-8vcpu-64gb         65536     8        1200    500.00           0.744050
gd-16vcpu-64gb        65536     16       400     520.00           0.773810
so1_5-8vcpu-64gb      65536     8        1800    620.00           0.922620
m-16vcpu-128gb        131072    16       400     640.00           0.952380
c-32                  65536     32       400     640.00           0.952380
c2-32vcpu-64gb        65536     32       800     720.00           1.071430
m3-16vcpu-128gb       131072    16       1200    785.00           1.168150
m-24vcpu-192gb        196608    24       600     960.00           1.428570
g-32vcpu-128gb        131072    32       400     960.00           1.428570
so-16vcpu-128gb       131072    16       2400    1000.00          1.488100
m6-16vcpu-128gb       131072    16       2400    1000.00          1.488100
gd-32vcpu-128gb       131072    32       800     1040.00          1.547620
m3-24vcpu-192gb       196608    24       1800    1175.00          1.748510
g-40vcpu-160gb        163840    40       500     1200.00          1.785710
so1_5-16vcpu-128gb    131072    16       3600    1240.00          1.845240
m-32vcpu-256gb        262144    32       800     1280.00          1.904760
gd-40vcpu-160gb       163840    40       1000    1300.00          1.934520
so-24vcpu-192gb       196608    24       3600    1500.00          2.232140
m6-24vcpu-192gb       196608    24       3600    1500.00          2.232140
m3-32vcpu-256gb       262144    32       2400    1565.00          2.328870
so1_5-24vcpu-192gb    196608    24       5400    1850.00          2.752980
so-32vcpu-256gb       262144    32       4800    2000.00          2.976190
m6-32vcpu-256gb       262144    32       4800    2000.00          2.976190
so1_5-32vcpu-256gb    262144    32       7200    2480.00          3.690480
database-stuff $ doctl compute 
The subcommands under `doctl compute` are for managing DigitalOcean resources.

Usage:
  doctl compute [command]

Available Commands:
  action             Display commands for retrieving resource action history
  cdn                Display commands that manage CDNs
  certificate        Display commands that manage SSL certificates and private keys
  domain             Display commands that manage domains
  droplet            Manage virtual machines (Droplets)
  droplet-action     Display Droplet action commands
  firewall           Display commands to manage cloud firewalls
  floating-ip        Display commands to manage floating IP addresses
  floating-ip-action Display commands to associate floating IP addresses with Droplets
  image              Display commands to manage images
  image-action       Display commands to perform actions on images
  load-balancer      Display commands to manage load balancers
  region             Display commands to list datacenter regions
  size               List available Droplet sizes
  snapshot           Access and manage snapshots
  ssh                Access a Droplet using SSH
  ssh-key            Display commands to manage SSH keys on your account
  tag                Display commands to manage tags
  volume             Display commands to manage block storage volumes
  volume-action      Display commands to perform actions on a volume

Flags:
  -h, --help   help for compute

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute [command] --help" for more information about a command.
database-stuff $ doctl compute ssh-key
The sub-commands of `doctl compute ssh-key` manage the SSH keys on your account.

DigitalOcean allows you to add SSH public keys to the interface so that you can embed your public key into a Droplet at the time of creation. Only the public key is required to take advantage of this functionality. Note that this command does not add, delete, or otherwise modify any ssh keys that may be on existing Droplets.

Usage:
  doctl compute ssh-key [command]

Aliases:
  ssh-key, k

Available Commands:
  create      Create a new SSH key on your account
  delete      Permanently delete an SSH key from your account
  get         Retrieve information about an SSH key on your account
  import      Import an SSH key from your computer to your account
  list        List all SSH keys on your account
  update      Update an SSH key's name

Flags:
  -h, --help   help for ssh-key

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute ssh-key [command] --help" for more information about a command.
database-stuff $ doctl compute ssh-key list
ID          Name                             FingerPrint
32221856    VMware laptop - Digital Ocean    2b:7d:36:8d:fe:fe:59:90:59:10:b6:39:be:45:e9:44
8916213     Ubuntu Desktop                   d9:ba:72:f8:47:a9:53:a7:59:8f:de:53:25:18:b7:3e
database-stuff $ 
```

---

```bash
doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
```

```bash
database-stuff $ doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
271925149    redis-server    143.110.245.39    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ ssh -i ~/.ssh/digital_ocean root@143.110.245.39
The authenticity of host '143.110.245.39 (143.110.245.39)' can't be established.
ECDSA key fingerprint is SHA256:rKfwmkzZGC99rkboFfLGBBe2+kCeaaekDcqn5fqoRzE.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '143.110.245.39' (ECDSA) to the list of known hosts.
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue Nov  2 15:58:06 UTC 2021

  System load:  0.76              Users logged in:       0
  Usage of /:   6.0% of 24.06GB   IPv4 address for eth0: 143.110.245.39
  Memory usage: 19%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    104

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@redis-server:~# {
>     sudo add-apt-repository ppa:redislabs/redis;
>     apt install redis-server;
>     systemctl status redis-server;
>     redis-cli PING;
>     redis-cli MEMORY MALLOC-STATS;
>     redis-cli ACL GENPASS;
> }
 Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes with radius queries and streams.

Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.
 More info: https://launchpad.net/~redislabs/+archive/ubuntu/redis
Press [ENTER] to continue or Ctrl-c to cancel adding it.

Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:2 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                                
Get:3 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease [114 kB]                                                
Get:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease [101 kB]                                              
Get:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease [18.0 kB]                  
Get:6 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]                 
Get:7 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 Packages [1302 kB]
Get:8 http://mirrors.digitalocean.com/ubuntu focal-updates/main Translation-en [270 kB]                                      
Get:9 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 c-n-f Metadata [14.4 kB]                               
Get:10 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 Packages [1016 B]                   
Get:11 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 Packages [524 kB]              
Get:12 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted Translation-en [75.0 kB]                              
Get:13 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [504 B]
Get:14 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main Translation-en [584 B]
Get:15 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 Packages [867 kB]
Get:16 http://mirrors.digitalocean.com/ubuntu focal-updates/universe Translation-en [187 kB]
Get:17 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [949 kB]   
Get:18 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [19.4 kB]
Get:19 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 Packages [24.6 kB]
Get:20 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse Translation-en [6856 B]
Get:21 http://security.ubuntu.com/ubuntu focal-security/main Translation-en [178 kB]
Get:22 http://security.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [8844 B]
Get:23 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [483 kB]
Get:24 http://security.ubuntu.com/ubuntu focal-security/restricted Translation-en [69.2 kB]
Get:25 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [647 kB]
Get:26 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [106 kB]
Get:27 http://security.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [12.8 kB]
Fetched 6091 kB in 3s (1786 kB/s)                               
Reading package lists... Done
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  redis-tools
Suggested packages:
  ruby-redis
The following NEW packages will be installed:
  redis-server redis-tools
0 upgraded, 2 newly installed, 0 to remove and 18 not upgraded.
Need to get 1150 kB of archives.
After this operation, 6794 kB of additional disk space will be used.
Do you want to continue? [Y/n] 
Get:1 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-tools amd64 6:6.2.6-1rl1~focal1 [1067 kB]
Get:2 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-server amd64 6:6.2.6-1rl1~focal1 [82.4 kB]
Fetched 1150 kB in 3s (458 kB/s)   
Selecting previously unselected package redis-tools.
(Reading database ... 63555 files and directories currently installed.)
Preparing to unpack .../redis-tools_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-tools (6:6.2.6-1rl1~focal1) ...
Selecting previously unselected package redis-server.
Preparing to unpack .../redis-server_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-server (6:6.2.6-1rl1~focal1) ...
Setting up redis-tools (6:6.2.6-1rl1~focal1) ...
Setting up redis-server (6:6.2.6-1rl1~focal1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Tue 2021-11-02 15:58:40 UTC; 2s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 2374 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.2M
     CGroup: /system.slice/redis-server.service
             └─2374 /usr/bin/redis-server 127.0.0.1:6379

Nov 02 15:58:40 redis-server systemd[1]: Starting Advanced key-value store...
Nov 02 15:58:40 redis-server systemd[1]: Started Advanced key-value store.
PONG
___ Begin jemalloc statistics ___
Version: "5.1.0-0-g0"
Build-time option settings
  config.cache_oblivious: true
  config.debug: false
  config.fill: true
  config.lazy_lock: false
  config.malloc_conf: ""
  config.prof: false
  config.prof_libgcc: false
  config.prof_libunwind: false
  config.stats: true
  config.utrace: false
  config.xmalloc: false
Run-time option settings
  opt.abort: false
  opt.abort_conf: false
  opt.retain: true
  opt.dss: "secondary"
  opt.narenas: 1
  opt.percpu_arena: "disabled"
  opt.metadata_thp: "disabled"
  opt.background_thread: false (background_thread: true)
  opt.dirty_decay_ms: 10000 (arenas.dirty_decay_ms: 10000)
  opt.muzzy_decay_ms: 10000 (arenas.muzzy_decay_ms: 10000)
  opt.junk: "false"
  opt.zero: false
  opt.tcache: true
  opt.lg_tcache_max: 15
  opt.thp: "default"
  opt.stats_print: false
  opt.stats_print_opts: ""
Arenas: 1
Quantum size: 8
Page size: 4096
Maximum thread-cached size class: 32768
Number of bin size classes: 39
Number of thread-cache bin size classes: 44
Number of large size classes: 196
Allocated: 1348088, active: 1646592, metadata: 2263320 (n_thp 0), resident: 3883008, mapped: 7938048, retained: 450560
Background threads: 1, num_runs: 2, run_interval: 1444619500 ns
                           n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
background_thread                  63               0               0               1               0               0           0
ctl                               119               0               0               1               0               0           0
prof                                0               0               0               0               0               0           0
arenas[0]:
assigned threads: 1
uptime: 2915651251
dss allocation precedence: "secondary"
decaying:  time       npages       sweeps     madvises       purged
   dirty: 10000            0            1            1            2
   muzzy: 10000            0            1            1            2
                            allocated     nmalloc     ndalloc   nrequests
small:                         655864       14987        1933       17489
large:                         692224          13           4          13
total:                        1348088       15000        1937       17502
                                     
active:                       1646592
mapped:                       7938048
retained:                      450560
base:                         2230544
internal:                       32776
metadata_thp:                       0
tcache_bytes:                  426928
resident:                     3883008
                           n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
large                              31               0               0               1               0               0           0
extent_avail                      148               0               0               3               0               0           0
extents_dirty                     210               0               0               5               0               0           0
extents_muzzy                     114               0               0               5               0               0           0
extents_retained                  194               0               0               5               0               0           0
decay_dirty                        39               0               0               5               0               0           0
decay_muzzy                        38               0               0               5               0               0           0
base                              187               0               0               3               0               0           0
tcache_list                        32               0               0               1               0               0           0
bins:           size ind    allocated      nmalloc      ndalloc    nrequests      curregs     curslabs regs pgs   util       nfills     nflushes       nslabs     nreslabs      n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
                   8   0         3088          801          415         2535          386            2  512   1  0.376            8            5            2            1              47               0               0               1               0               0           0
                  16   1       172800        10800            0        11956        10800           43  256   1  0.981          108            0           43            0             182               0               0               1               0               0           0
                  24   2        22488         1000           63         1193          937            2  512   3  0.915           10            1            2            0              44               0               0               1               0               0           0
                  32   3         5664          200           23          360          177            2  128   1  0.691            2            1            2            0              36               0               0               1               0               0           0
                  40   4         3480          100           13          132           87            1  512   5  0.169            1            2            1            0              35               0               0               1               0               0           0
                  48   5         3312          100           31           84           69            1  256   3  0.269            1            2            1            0              35               0               0               1               0               0           0
                  56   6         3752          100           33           91           67            1  512   7  0.130            1            2            1            0              35               0               0               1               0               0           0
                  64   7         4928          128           51           87           77            2   64   1  0.601            2            1            2            0              36               0               0               1               0               0           0
                  80   8        10000          800          675          729          125            1  256   5  0.488            8            7            4            0              53               0               0               1               0               0           0
                  96   9        12000          300          175          291          125            1  128   3  0.976            3            2            3            0              41               0               0               1               0               0           0
                 112  10          784          100           93            3            7            1  256   7  0.027            1            2            1            0              35               0               0               1               0               0           0
                 128  11          256           32           30            5            2            1   32   1  0.062            1            2            1            0              35               0               0               1               0               0           0
                 160  12         4000          100           75            3           25            1  128   5  0.195            1            1            1            0              34               0               0               1               0               0           0
                 192  13         3072           64           48            2           16            1   64   3  0.250            1            1            1            0              34               0               0               1               0               0           0
                 224  14         5600          100           75            2           25            1  128   7  0.195            1            1            1            0              34               0               0               1               0               0           0
                 256  15          256           16           15            3            1            1   16   1  0.062            1            2            1            0              35               0               0               1               0               0           0
                 320  16         5120           64           48            1           16            1   64   5  0.250            1            1            1            0              34               0               0               1               0               0           0
                 384  17         3072           32           24            1            8            1   32   3  0.250            1            1            1            0              34               0               0               1               0               0           0
                 448  18            0            0            0            0            0            0   64   7      1            0            0            0            0              31               0               0               1               0               0           0
                     ---
                 512  19         1024           12           10            3            2            1    8   1  0.250            2            2            3            0              40               0               0               1               0               0           0
                 640  20         5120           32           24            2            8            1   32   5  0.250            1            1            1            0              34               0               0               1               0               0           0
                 768  21            0            0            0            0            0            0   16   3      1            0            0            0            0              31               0               0               1               0               0           0
                 896  22            0            0            0            0            0            0   32   7      1            0            0            0            0              31               0               0               1               0               0           0
                     ---
                1024  23         4096           10            6            3            4            1    4   1      1            1            1            3            0              38               0               0               1               0               0           0
                1280  24        20480           16            0            0           16            1   16   5      1            1            0            1            0              33               0               0               1               0               0           0
                1536  25        15360           10            0            0           10            2    8   3  0.625            1            0            2            0              34               0               0               1               0               0           0
                1792  26            0            0            0            0            0            0   16   7      1            0            0            0            0              31               0               0               1               0               0           0
                     ---
                2048  27         8192           10            6            3            4            2    2   1      1            1            1            5            0              41               0               0               1               0               0           0
                2560  28        25600           10            0            0           10            2    8   5  0.625            1            0            2            0              34               0               0               1               0               0           0
                3072  29            0            0            0            0            0            0    4   3      1            0            0            0            0              31               0               0               1               0               0           0
                     ---
                3584  30        35840           10            0            0           10            2    8   7  0.625            1            0            2            0              34               0               0               1               0               0           0
                4096  31        40960           10            0            0           10           10    1   1      1            1            0           10            0              42               0               0               1               0               0           0
                5120  32        51200           10            0            0           10            3    4   5  0.833            1            0            3            0              35               0               0               1               0               0           0
                6144  33            0            0            0            0            0            0    2   3      1            0            0            0            0              31               0               0               1               0               0           0
                7168  34            0            0            0            0            0            0    4   7      1            0            0            0            0              31               0               0               1               0               0           0
                     ---
                8192  35        81920           10            0            0           10           10    1   2      1            1            0           10            0              42               0               0               1               0               0           0
               10240  36       102400           10            0            0           10            5    2   5      1            1            0            5            0              37               0               0               1               0               0           0
               12288  37            0            0            0            0            0            0    1   3      1            0            0            0            0              31               0               0               1               0               0           0
               14336  38            0            0            0            0            0            0    2   7      1            0            0            0            0              31               0               0               1               0               0           0
                     ---
large:          size ind    allocated      nmalloc      ndalloc    nrequests  curlextents
               16384  39        16384            1            0            1            1
               20480  40        61440            4            1            4            3
                     ---
               32768  43        32768            1            0            1            1
               40960  44        40960            2            1            2            1
               49152  45            0            1            1            1            0
                     ---
               81920  48        81920            1            0            1            1
                     ---
              114688  50            0            1            1            1            0
              131072  51       131072            1            0            1            1
                     ---
              327680  56       327680            1            0            1            1
                     ---
--- End jemalloc statistics ---
"add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea"
root@redis-server:~# {
>     vi /etc/redis/redis.conf;
> }
root@redis-server:~# redis-cli PING PING
"PING"
root@redis-server:~# redis-cli 
127.0.0.1:6379> 
root@redis-server:~# redis-cli -h
redis-cli 6.2.6

Usage: redis-cli [OPTIONS] [cmd [arg [arg ...]]]
  -h <hostname>      Server hostname (default: 127.0.0.1).
  -p <port>          Server port (default: 6379).
  -s <socket>        Server socket (overrides hostname and port).
  -a <password>      Password to use when connecting to the server.
                     You can also use the REDISCLI_AUTH environment
                     variable to pass this password more safely
                     (if both are used, this argument takes precedence).
  --user <username>  Used to send ACL style 'AUTH username pass'. Needs -a.
  --pass <password>  Alias of -a for consistency with the new --user option.
  --askpass          Force user to input password with mask from STDIN.
                     If this argument is used, '-a' and REDISCLI_AUTH
                     environment variable will be ignored.
  -u <uri>           Server URI.
  -r <repeat>        Execute specified command N times.
  -i <interval>      When -r is used, waits <interval> seconds per command.
                     It is possible to specify sub-second times like -i 0.1.
  -n <db>            Database number.
  -3                 Start session in RESP3 protocol mode.
  -x                 Read last argument from STDIN.
  -d <delimiter>     Delimiter between response bulks for raw formatting (default: \n).
  -D <delimiter>     Delimiter between responses for raw formatting (default: \n).
  -c                 Enable cluster mode (follow -ASK and -MOVED redirections).
  -e                 Return exit error code when command execution fails.
  --tls              Establish a secure TLS connection.
  --sni <host>       Server name indication for TLS.
  --cacert <file>    CA Certificate file to verify with.
  --cacertdir <dir>  Directory where trusted CA certificates are stored.
                     If neither cacert nor cacertdir are specified, the default
                     system-wide trusted root certs configuration will apply.
  --insecure         Allow insecure TLS connection by skipping cert validation.
  --cert <file>      Client certificate to authenticate with.
  --key <file>       Private key file to authenticate with.
  --tls-ciphers <list> Sets the list of prefered ciphers (TLSv1.2 and below)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string.
  --tls-ciphersuites <list> Sets the list of prefered ciphersuites (TLSv1.3)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string,
                     and specifically for TLSv1.3 ciphersuites.
  --raw              Use raw formatting for replies (default when STDOUT is
                     not a tty).
  --no-raw           Force formatted output even when STDOUT is not a tty.
  --quoted-input     Force input to be handled as quoted strings.
  --csv              Output in CSV format.
  --show-pushes <yn> Whether to print RESP3 PUSH messages.  Enabled by default when
                     STDOUT is a tty but can be overriden with --show-pushes no.
  --stat             Print rolling stats about server: mem, clients, ...
  --latency          Enter a special mode continuously sampling latency.
                     If you use this mode in an interactive session it runs
                     forever displaying real-time stats. Otherwise if --raw or
                     --csv is specified, or if you redirect the output to a non
                     TTY, it samples the latency for 1 second (you can use
                     -i to change the interval), then produces a single output
                     and exits.
  --latency-history  Like --latency but tracking latency changes over time.
                     Default time interval is 15 sec. Change it using -i.
  --latency-dist     Shows latency as a spectrum, requires xterm 256 colors.
                     Default time interval is 1 sec. Change it using -i.
  --lru-test <keys>  Simulate a cache workload with an 80-20 distribution.
  --replica          Simulate a replica showing commands received from the master.
  --rdb <filename>   Transfer an RDB dump from remote server to local file.
                     Use filename of "-" to write to stdout.
  --pipe             Transfer raw Redis protocol from stdin to server.
  --pipe-timeout <n> In --pipe mode, abort with error if after sending all data.
                     no reply is received within <n> seconds.
                     Default timeout: 30. Use 0 to wait forever.
  --bigkeys          Sample Redis keys looking for keys with many elements (complexity).
  --memkeys          Sample Redis keys looking for keys consuming a lot of memory.
  --memkeys-samples <n> Sample Redis keys looking for keys consuming a lot of memory.
                     And define number of key elements to sample
  --hotkeys          Sample Redis keys looking for hot keys.
                     only works when maxmemory-policy is *lfu.
  --scan             List all keys using the SCAN command.
  --pattern <pat>    Keys pattern when using the --scan, --bigkeys or --hotkeys
                     options (default: *).
  --quoted-pattern <pat> Same as --pattern, but the specified string can be
                         quoted, in order to pass an otherwise non binary-safe string.
  --intrinsic-latency <sec> Run a test to measure intrinsic system latency.
                     The test will run for the specified amount of seconds.
  --eval <file>      Send an EVAL command using the Lua script at <file>.
  --ldb              Used with --eval enable the Redis Lua debugger.
  --ldb-sync-mode    Like --ldb but uses the synchronous Lua debugger, in
                     this mode the server is blocked and script changes are
                     not rolled back from the server memory.
  --cluster <command> [args...] [opts...]
                     Cluster Manager command and arguments (see below).
  --verbose          Verbose mode.
  --no-auth-warning  Don't show warning message when using password on command
                     line interface.
  --help             Output this help and exit.
  --version          Output version and exit.

Cluster Manager Commands:
  Use --cluster help to list all available cluster manager commands.

Examples:
  cat /etc/passwd | redis-cli -x set mypasswd
  redis-cli get mypasswd
  redis-cli -r 100 lpush mylist x
  redis-cli -r 100 -i 1 info | grep used_memory_human:
  redis-cli --quoted-input set '"null-\x00-separated"' value
  redis-cli --eval myscript.lua key1 key2 , arg1 arg2 arg3
  redis-cli --scan --pattern '*:12345*'

  (Note: when using --eval the comma separates KEYS[] from ARGV[] items)

When no command is given, redis-cli starts in interactive mode.
Type "help" in interactive mode for information on available commands
and settings.

root@redis-server:~# redis-cli < echo "PING\nPING\n"
-bash: echo: No such file or directory
root@redis-server:~# echo "PING\nPING\n" | redis-cli
(error) ERR unknown command `PING\nPING\n`, with args beginning with: 
root@redis-server:~# echo -e "PING\nPING\n" | redis-cli
PONG
PONG
root@redis-server:~# echo -e "AUTH add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea\nPING\n" | redis-cli
(error) ERR AUTH <password> called without any password configured for the default user. Are you sure your configuration is correct?
PONG
root@redis-server:~# redis-cli -h
redis-cli 6.2.6

Usage: redis-cli [OPTIONS] [cmd [arg [arg ...]]]
  -h <hostname>      Server hostname (default: 127.0.0.1).
  -p <port>          Server port (default: 6379).
  -s <socket>        Server socket (overrides hostname and port).
  -a <password>      Password to use when connecting to the server.
                     You can also use the REDISCLI_AUTH environment
                     variable to pass this password more safely
                     (if both are used, this argument takes precedence).
  --user <username>  Used to send ACL style 'AUTH username pass'. Needs -a.
  --pass <password>  Alias of -a for consistency with the new --user option.
  --askpass          Force user to input password with mask from STDIN.
                     If this argument is used, '-a' and REDISCLI_AUTH
                     environment variable will be ignored.
  -u <uri>           Server URI.
  -r <repeat>        Execute specified command N times.
  -i <interval>      When -r is used, waits <interval> seconds per command.
                     It is possible to specify sub-second times like -i 0.1.
  -n <db>            Database number.
  -3                 Start session in RESP3 protocol mode.
  -x                 Read last argument from STDIN.
  -d <delimiter>     Delimiter between response bulks for raw formatting (default: \n).
  -D <delimiter>     Delimiter between responses for raw formatting (default: \n).
  -c                 Enable cluster mode (follow -ASK and -MOVED redirections).
  -e                 Return exit error code when command execution fails.
  --tls              Establish a secure TLS connection.
  --sni <host>       Server name indication for TLS.
  --cacert <file>    CA Certificate file to verify with.
  --cacertdir <dir>  Directory where trusted CA certificates are stored.
                     If neither cacert nor cacertdir are specified, the default
                     system-wide trusted root certs configuration will apply.
  --insecure         Allow insecure TLS connection by skipping cert validation.
  --cert <file>      Client certificate to authenticate with.
  --key <file>       Private key file to authenticate with.
  --tls-ciphers <list> Sets the list of prefered ciphers (TLSv1.2 and below)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string.
  --tls-ciphersuites <list> Sets the list of prefered ciphersuites (TLSv1.3)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string,
                     and specifically for TLSv1.3 ciphersuites.
  --raw              Use raw formatting for replies (default when STDOUT is
                     not a tty).
  --no-raw           Force formatted output even when STDOUT is not a tty.
  --quoted-input     Force input to be handled as quoted strings.
  --csv              Output in CSV format.
  --show-pushes <yn> Whether to print RESP3 PUSH messages.  Enabled by default when
                     STDOUT is a tty but can be overriden with --show-pushes no.
  --stat             Print rolling stats about server: mem, clients, ...
  --latency          Enter a special mode continuously sampling latency.
                     If you use this mode in an interactive session it runs
                     forever displaying real-time stats. Otherwise if --raw or
                     --csv is specified, or if you redirect the output to a non
                     TTY, it samples the latency for 1 second (you can use
                     -i to change the interval), then produces a single output
                     and exits.
  --latency-history  Like --latency but tracking latency changes over time.
                     Default time interval is 15 sec. Change it using -i.
  --latency-dist     Shows latency as a spectrum, requires xterm 256 colors.
                     Default time interval is 1 sec. Change it using -i.
  --lru-test <keys>  Simulate a cache workload with an 80-20 distribution.
  --replica          Simulate a replica showing commands received from the master.
  --rdb <filename>   Transfer an RDB dump from remote server to local file.
                     Use filename of "-" to write to stdout.
  --pipe             Transfer raw Redis protocol from stdin to server.
  --pipe-timeout <n> In --pipe mode, abort with error if after sending all data.
                     no reply is received within <n> seconds.
                     Default timeout: 30. Use 0 to wait forever.
  --bigkeys          Sample Redis keys looking for keys with many elements (complexity).
  --memkeys          Sample Redis keys looking for keys consuming a lot of memory.
  --memkeys-samples <n> Sample Redis keys looking for keys consuming a lot of memory.
                     And define number of key elements to sample
  --hotkeys          Sample Redis keys looking for hot keys.
                     only works when maxmemory-policy is *lfu.
  --scan             List all keys using the SCAN command.
  --pattern <pat>    Keys pattern when using the --scan, --bigkeys or --hotkeys
                     options (default: *).
  --quoted-pattern <pat> Same as --pattern, but the specified string can be
                         quoted, in order to pass an otherwise non binary-safe string.
  --intrinsic-latency <sec> Run a test to measure intrinsic system latency.
                     The test will run for the specified amount of seconds.
  --eval <file>      Send an EVAL command using the Lua script at <file>.
  --ldb              Used with --eval enable the Redis Lua debugger.
  --ldb-sync-mode    Like --ldb but uses the synchronous Lua debugger, in
                     this mode the server is blocked and script changes are
                     not rolled back from the server memory.
  --cluster <command> [args...] [opts...]
                     Cluster Manager command and arguments (see below).
  --verbose          Verbose mode.
  --no-auth-warning  Don't show warning message when using password on command
                     line interface.
  --help             Output this help and exit.
  --version          Output version and exit.

Cluster Manager Commands:
  Use --cluster help to list all available cluster manager commands.

Examples:
  cat /etc/passwd | redis-cli -x set mypasswd
  redis-cli get mypasswd
  redis-cli -r 100 lpush mylist x
  redis-cli -r 100 -i 1 info | grep used_memory_human:
  redis-cli --quoted-input set '"null-\x00-separated"' value
  redis-cli --eval myscript.lua key1 key2 , arg1 arg2 arg3
  redis-cli --scan --pattern '*:12345*'

  (Note: when using --eval the comma separates KEYS[] from ARGV[] items)

When no command is given, redis-cli starts in interactive mode.
Type "help" in interactive mode for information on available commands
and settings.

root@redis-server:~# {
>     systemctl restart redis-server;
>     systemctl status redis-server;
>     redis-cli -p 56679 PING;
>     echo -e "AUTH add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea\nPING\n" | redis-cli -p 56679;
>     REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea"
>     redis-cli -p 56679 PING;
> }
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Tue 2021-11-02 16:05:34 UTC; 11ms ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 2597 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.1M
     CGroup: /system.slice/redis-server.service
             └─2597 /usr/bin/redis-server *:56679

Nov 02 16:05:34 redis-server systemd[1]: Starting Advanced key-value store...
Nov 02 16:05:34 redis-server systemd[1]: Started Advanced key-value store.
(error) NOAUTH Authentication required.
OK
PONG
(error) NOAUTH Authentication required.
root@redis-server:~# echo $REDISCLI_AUTH 
add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea
root@redis-server:~# redis-cli -h | grep AUTH
redis-cli 6.2.6

Usage: redis-cli [OPTIONS] [cmd [arg [arg ...]]]
  -h <hostname>      Server hostname (default: 127.0.0.1).
  -p <port>          Server port (default: 6379).
  -s <socket>        Server socket (overrides hostname and port).
  -a <password>      Password to use when connecting to the server.
                     You can also use the REDISCLI_AUTH environment
                     variable to pass this password more safely
                     (if both are used, this argument takes precedence).
  --user <username>  Used to send ACL style 'AUTH username pass'. Needs -a.
  --pass <password>  Alias of -a for consistency with the new --user option.
  --askpass          Force user to input password with mask from STDIN.
                     If this argument is used, '-a' and REDISCLI_AUTH
                     environment variable will be ignored.
  -u <uri>           Server URI.
  -r <repeat>        Execute specified command N times.
  -i <interval>      When -r is used, waits <interval> seconds per command.
                     It is possible to specify sub-second times like -i 0.1.
  -n <db>            Database number.
  -3                 Start session in RESP3 protocol mode.
  -x                 Read last argument from STDIN.
  -d <delimiter>     Delimiter between response bulks for raw formatting (default: \n).
  -D <delimiter>     Delimiter between responses for raw formatting (default: \n).
  -c                 Enable cluster mode (follow -ASK and -MOVED redirections).
  -e                 Return exit error code when command execution fails.
  --tls              Establish a secure TLS connection.
  --sni <host>       Server name indication for TLS.
  --cacert <file>    CA Certificate file to verify with.
  --cacertdir <dir>  Directory where trusted CA certificates are stored.
                     If neither cacert nor cacertdir are specified, the default
                     system-wide trusted root certs configuration will apply.
  --insecure         Allow insecure TLS connection by skipping cert validation.
  --cert <file>      Client certificate to authenticate with.
  --key <file>       Private key file to authenticate with.
  --tls-ciphers <list> Sets the list of prefered ciphers (TLSv1.2 and below)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string.
  --tls-ciphersuites <list> Sets the list of prefered ciphersuites (TLSv1.3)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string,
                     and specifically for TLSv1.3 ciphersuites.
  --raw              Use raw formatting for replies (default when STDOUT is
                     not a tty).
  --no-raw           Force formatted output even when STDOUT is not a tty.
  --quoted-input     Force input to be handled as quoted strings.
  --csv              Output in CSV format.
  --show-pushes <yn> Whether to print RESP3 PUSH messages.  Enabled by default when
                     STDOUT is a tty but can be overriden with --show-pushes no.
  --stat             Print rolling stats about server: mem, clients, ...
  --latency          Enter a special mode continuously sampling latency.
                     If you use this mode in an interactive session it runs
                     forever displaying real-time stats. Otherwise if --raw or
                     --csv is specified, or if you redirect the output to a non
                     TTY, it samples the latency for 1 second (you can use
                     -i to change the interval), then produces a single output
                     and exits.
  --latency-history  Like --latency but tracking latency changes over time.
                     Default time interval is 15 sec. Change it using -i.
  --latency-dist     Shows latency as a spectrum, requires xterm 256 colors.
                     Default time interval is 1 sec. Change it using -i.
  --lru-test <keys>  Simulate a cache workload with an 80-20 distribution.
  --replica          Simulate a replica showing commands received from the master.
  --rdb <filename>   Transfer an RDB dump from remote server to local file.
                     Use filename of "-" to write to stdout.
  --pipe             Transfer raw Redis protocol from stdin to server.
  --pipe-timeout <n> In --pipe mode, abort with error if after sending all data.
                     no reply is received within <n> seconds.
                     Default timeout: 30. Use 0 to wait forever.
  --bigkeys          Sample Redis keys looking for keys with many elements (complexity).
  --memkeys          Sample Redis keys looking for keys consuming a lot of memory.
  --memkeys-samples <n> Sample Redis keys looking for keys consuming a lot of memory.
                     And define number of key elements to sample
  --hotkeys          Sample Redis keys looking for hot keys.
                     only works when maxmemory-policy is *lfu.
  --scan             List all keys using the SCAN command.
  --pattern <pat>    Keys pattern when using the --scan, --bigkeys or --hotkeys
                     options (default: *).
  --quoted-pattern <pat> Same as --pattern, but the specified string can be
                         quoted, in order to pass an otherwise non binary-safe string.
  --intrinsic-latency <sec> Run a test to measure intrinsic system latency.
                     The test will run for the specified amount of seconds.
  --eval <file>      Send an EVAL command using the Lua script at <file>.
  --ldb              Used with --eval enable the Redis Lua debugger.
  --ldb-sync-mode    Like --ldb but uses the synchronous Lua debugger, in
                     this mode the server is blocked and script changes are
                     not rolled back from the server memory.
  --cluster <command> [args...] [opts...]
                     Cluster Manager command and arguments (see below).
  --verbose          Verbose mode.
  --no-auth-warning  Don't show warning message when using password on command
                     line interface.
  --help             Output this help and exit.
  --version          Output version and exit.

Cluster Manager Commands:
  Use --cluster help to list all available cluster manager commands.

Examples:
  cat /etc/passwd | redis-cli -x set mypasswd
  redis-cli get mypasswd
  redis-cli -r 100 lpush mylist x
  redis-cli -r 100 -i 1 info | grep used_memory_human:
  redis-cli --quoted-input set '"null-\x00-separated"' value
  redis-cli --eval myscript.lua key1 key2 , arg1 arg2 arg3
  redis-cli --scan --pattern '*:12345*'

  (Note: when using --eval the comma separates KEYS[] from ARGV[] items)

When no command is given, redis-cli starts in interactive mode.
Type "help" in interactive mode for information on available commands
and settings.

root@redis-server:~# redis-cli -p 55679 PING
Could not connect to Redis at 127.0.0.1:55679: Connection refused
root@redis-server:~# redis-cli -p 56679 PING
(error) NOAUTH Authentication required.
root@redis-server:~# redis-cli -a add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea -p 56679 PING
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
PONG
root@redis-server:~# REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea" redis-cli -p 56679 PING
PONG
root@redis-server:~# REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea" redis-cli -p 56679 PING
PONG
root@redis-server:~# redis-cli -p 56679 PING
(error) NOAUTH Authentication required.
root@redis-server:~# export REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea" 
root@redis-server:~# redis-cli -p 56679 PING
PONG
root@redis-server:~# ifconfig

Command 'ifconfig' not found, but can be installed with:

apt install net-tools

root@redis-server:~# logout
Connection to 143.110.245.39 closed.
database-stuff $ doctl 
doctl is a command line interface (CLI) for the DigitalOcean API.

Usage:
  doctl [command]

Available Commands:
  1-click         Display commands that pertain to 1-click applications
  account         Display commands that retrieve account details
  apps            Display commands for working with apps
  auth            Display commands for authenticating doctl with an account
  balance         Display commands for retrieving your account balance
  billing-history Display commands for retrieving your billing history
  completion      Modify your shell so doctl commands autocomplete with TAB
  compute         Display commands that manage infrastructure
  databases       Display commands that manage databases
  help            Help about any command
  invoice         Display commands for retrieving invoices for your account
  kubernetes      Displays commands to manage Kubernetes clusters and configurations
  monitoring      [Beta] Display commands to manage monitoring
  projects        Manage projects and assign resources to them
  registry        Display commands for working with container registries
  version         Show the current version
  vpcs            Display commands that manage VPCs

Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -h, --help                  help for doctl
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl [command] --help" for more information about a command.
database-stuff $ doctl compute droplte
The subcommands under `doctl compute` are for managing DigitalOcean resources.

Usage:
  doctl compute [command]

Available Commands:
  action             Display commands for retrieving resource action history
  cdn                Display commands that manage CDNs
  certificate        Display commands that manage SSL certificates and private keys
  domain             Display commands that manage domains
  droplet            Manage virtual machines (Droplets)
  droplet-action     Display Droplet action commands
  firewall           Display commands to manage cloud firewalls
  floating-ip        Display commands to manage floating IP addresses
  floating-ip-action Display commands to associate floating IP addresses with Droplets
  image              Display commands to manage images
  image-action       Display commands to perform actions on images
  load-balancer      Display commands to manage load balancers
  region             Display commands to list datacenter regions
  size               List available Droplet sizes
  snapshot           Access and manage snapshots
  ssh                Access a Droplet using SSH
  ssh-key            Display commands to manage SSH keys on your account
  tag                Display commands to manage tags
  volume             Display commands to manage block storage volumes
  volume-action      Display commands to perform actions on a volume

Flags:
  -h, --help   help for compute

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute [command] --help" for more information about a command.
database-stuff $ doctl compute droplet
A Droplet is a DigitalOcean virtual machine. Use the subcommands of `doctl compute droplet` to list, create, or delete Droplets.

Usage:
  doctl compute droplet [command]

Aliases:
  droplet, d

Available Commands:
  1-click     Display commands that pertain to Droplet 1-click applications
  actions     List Droplet actions
  backups     List Droplet backups
  create      Create a new Droplet
  delete      Permanently delete a Droplet
  get         Retrieve information about a Droplet
  kernels     List available Droplet kernels
  list        List Droplets on your account
  neighbors   List a Droplet's neighbors on your account
  snapshots   List all snapshots for a Droplet
  tag         Add a tag to a Droplet
  untag       Remove a tag from a Droplet

Flags:
  -h, --help   help for droplet

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute droplet [command] --help" for more information about a command.
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
271925149    redis-server    143.110.245.39    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ doctl compute droplet delete -h
Use this command to permanently delete a Droplet. This is irreversible.

Usage:
  doctl compute droplet delete <droplet-id|droplet-name>... [flags]

Aliases:
  delete, d, del, rm

Flags:
  -f, --force             Delete the Droplet without a confirmation prompt
  -h, --help              help for delete
      --tag-name string   Tag name

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute droplet delete redis-server
Warning: Are you sure you want to delete this Droplet? (y/N) ? y
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
271925149    redis-server    143.110.245.39    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ doctl compute droplet list
ID    Name    Public IPv4    Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image    VPC UUID    Status    Tags    Features    Volumes
database-stuff $ 
```

```bash
database-stuff $ export REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea"
database-stuff $ redis-cli -p 56679 -h 143.110.245.39 PING
PONG
database-stuff $ redis-cli -p 56679 -h 143.110.245.39 PING
database-stuff $ unset REDISCLI_AUTH
database-stuff $ redis-cli -p 56679 -h 143.110.245.39 PING
(error) NOAUTH Authentication required.
database-stuff $ export REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea"
database-stuff $ unset REDISCLI_AUTH
REDISCLI_AUTH
database-stuff $ export REDISCLI_AUTH="add913f939e06dd90128d40c86c5d2522bec26a822bf73eccffd3d3182e34dea"
database-stuff $ redis-cli -p 56679 -h 143.110.245.39 PING
PONG
database-stuff $ redis-cli -p 56679 -h 143.110.245.39 INFO
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:2597
process_supervised:systemd
run_id:b0b9c5ed5ceb20b8c493ed41bfb35a767ad9517f
tcp_port:56679
server_time_usec:1635869344343239
uptime_in_seconds:210
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:8479392
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0

# Clients
connected_clients:1
cluster_connections:0
maxclients:10000
client_recent_max_input_buffer:0
client_recent_max_output_buffer:0
blocked_clients:0
tracking_clients:0
clients_in_timeout_table:0

# Memory
used_memory:873936
used_memory_human:853.45K
used_memory_rss:9146368
used_memory_rss_human:8.72M
used_memory_peak:873936
used_memory_peak_human:853.45K
used_memory_peak_perc:100.19%
used_memory_overhead:810168
used_memory_startup:810168
used_memory_dataset:63768
used_memory_dataset_perc:100.00%
allocator_allocated:1276376
allocator_active:1605632
allocator_resident:3842048
total_system_memory:1028956160
total_system_memory_human:981.29M
used_memory_lua:37888
used_memory_lua_human:37.00K
used_memory_scripts:0
used_memory_scripts_human:0B
number_of_cached_scripts:0
maxmemory:0
maxmemory_human:0B
maxmemory_policy:noeviction
allocator_frag_ratio:1.26
allocator_frag_bytes:329256
allocator_rss_ratio:2.39
allocator_rss_bytes:2236416
rss_overhead_ratio:2.38
rss_overhead_bytes:5304320
mem_fragmentation_ratio:11.29
mem_fragmentation_bytes:8336144
mem_not_counted_for_evict:0
mem_replication_backlog:0
mem_clients_slaves:0
mem_clients_normal:0
mem_aof_buffer:0
mem_allocator:jemalloc-5.1.0
active_defrag_running:0
lazyfree_pending_objects:0
lazyfreed_objects:0

# Persistence
loading:0
current_cow_size:0
current_cow_size_age:0
current_fork_perc:0.00
current_save_keys_processed:0
current_save_keys_total:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1635869134
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:-1
rdb_current_bgsave_time_sec:-1
rdb_last_cow_size:0
aof_enabled:0
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
aof_last_cow_size:0
module_fork_in_progress:0
module_fork_last_cow_size:0

# Stats
total_connections_received:13
total_commands_processed:15
instantaneous_ops_per_sec:0
total_net_input_bytes:879
total_net_output_bytes:293
instantaneous_input_kbps:0.00
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:0
sync_partial_ok:0
sync_partial_err:0
expired_keys:0
expired_stale_perc:0.00
expired_time_cap_reached_count:0
expire_cycle_cpu_milliseconds:4
evicted_keys:0
keyspace_hits:0
keyspace_misses:0
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:0
total_forks:0
migrate_cached_sockets:0
slave_expires_tracked_keys:0
active_defrag_hits:0
active_defrag_misses:0
active_defrag_key_hits:0
active_defrag_key_misses:0
tracking_total_keys:0
tracking_total_items:0
tracking_total_prefixes:0
unexpected_error_replies:0
total_error_replies:6
dump_payload_sanitizations:0
total_reads_processed:34
total_writes_processed:21
io_threaded_reads_processed:0
io_threaded_writes_processed:0

# Replication
role:master
connected_slaves:0
master_failover_state:no-failover
master_replid:30f6b56baf846b2a55a3456ca471f421fb83b89a
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# CPU
used_cpu_sys:0.226734
used_cpu_user:0.226734
used_cpu_sys_children:0.000000
used_cpu_user_children:0.000000
used_cpu_sys_main_thread:0.226330
used_cpu_user_main_thread:0.226330

# Modules

# Errorstats
errorstat_NOAUTH:count=6

# Cluster
cluster_enabled:0

# Keyspace
database-stuff $ 
```

---

[TODO]

- Have a script and process to deploy Redis to digital ocean
  - create a digital ocean droplet using doctl
  - manually SSH into the digital ocean droplet
  - have a list of commands to run to install and configure and run redis


- Can we do all the configuration using `CONFIG` commands? Hmm. Check and configure with `CONFIG` commands!
  - Yup! From Redis 6.2.1 onwards we can I guess!
    - https://github.com/redis/redis/releases/tag/6.2.1 see improvements section
    - https://github.com/redis/redis/pull/8510

- Implement TLS/SSL support for the Redis deployment

- Deploy 2 droplets - one droplet runs the Redis server and any monitoring agents required to monitor it. Another droplet instance to run redis benchmark tool and benchmark the redis server. Maybe monitoring agents can also run on other droplets. All droplets will be of size 1 GB RAM and 1 vCPU

--

https://redis.io/topics/lru-cache

---

https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04

https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04

---

https://redis.io/commands/config-get

https://redis.io/commands/config-set

https://duckduckgo.com/?t=ffab&q=redis%3A+use+config+set+to+reset+a+config+to+default+value+or+remove+it&ia=web

---

```bash
database-stuff $ doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
272085344    redis-server    142.93.221.126    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
272085344    redis-server    142.93.221.126    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ ssh -i ~/.ssh/digital_ocean root@142.93.221.126
The authenticity of host '142.93.221.126 (142.93.221.126)' can't be established.
ECDSA key fingerprint is SHA256:8NkbIlAnvK5C9QmD4hgPwySB5zD+p4sFfk6LMcWOTg4.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '142.93.221.126' (ECDSA) to the list of known hosts.
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed Nov  3 17:47:02 UTC 2021

  System load:  0.0               Users logged in:       0
  Usage of /:   6.0% of 24.06GB   IPv4 address for eth0: 142.93.221.126
  Memory usage: 19%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    101

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@redis-server:~# 
root@redis-server:~# {
>     sudo add-apt-repository ppa:redislabs/redis;
>     apt install redis-server;
>     systemctl status redis-server;
>     redis-cli PING;
>     redis-cli MEMORY MALLOC-STATS;
>     redis-cli ACL GENPASS;
> }
 Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes with radius queries and streams.

Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.
 More info: https://launchpad.net/~redislabs/+archive/ubuntu/redis
Press [ENTER] to continue or Ctrl-c to cancel adding it.

Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Get:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease [114 kB]                                                
Hit:3 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                                
Get:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease [101 kB]                                              
Get:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease [18.0 kB]
Get:6 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Get:7 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 Packages [1302 kB]
Get:8 http://mirrors.digitalocean.com/ubuntu focal-updates/main Translation-en [270 kB]                                      
Get:9 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 c-n-f Metadata [14.4 kB]                               
Get:10 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 Packages [1016 B]                              
Get:11 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 Packages [524 kB]                               
Get:12 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted Translation-en [75.0 kB]                              
Get:13 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [504 B]                     
Get:14 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main Translation-en [584 B]
Get:15 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 Packages [867 kB]
Get:16 http://mirrors.digitalocean.com/ubuntu focal-updates/universe Translation-en [187 kB]
Get:17 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [19.4 kB]
Get:18 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 Packages [24.6 kB]
Get:19 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse Translation-en [6856 B]
Get:20 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [949 kB]
Get:21 http://security.ubuntu.com/ubuntu focal-security/main Translation-en [178 kB]
Get:22 http://security.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [8844 B]
Get:23 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [483 kB]
Get:24 http://security.ubuntu.com/ubuntu focal-security/restricted Translation-en [69.2 kB]
Get:25 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [647 kB]
Get:26 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [106 kB]
Get:27 http://security.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [12.8 kB]
Fetched 6091 kB in 3s (1855 kB/s)                                 
Reading package lists... Done
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  redis-tools
Suggested packages:
  ruby-redis
The following NEW packages will be installed:
  redis-server redis-tools
0 upgraded, 2 newly installed, 0 to remove and 19 not upgraded.
Need to get 1150 kB of archives.
After this operation, 6794 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-tools amd64 6:6.2.6-1rl1~focal1 [1067 kB]
Get:2 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-server amd64 6:6.2.6-1rl1~focal1 [82.4 kB]
Fetched 1150 kB in 2s (586 kB/s)   
Selecting previously unselected package redis-tools.
(Reading database ... 63555 files and directories currently installed.)
Preparing to unpack .../redis-tools_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-tools (6:6.2.6-1rl1~focal1) ...
Selecting previously unselected package redis-server.
Preparing to unpack .../redis-server_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-server (6:6.2.6-1rl1~focal1) ...
Setting up redis-tools (6:6.2.6-1rl1~focal1) ...
Setting up redis-server (6:6.2.6-1rl1~focal1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-11-03 17:47:56 UTC; 3s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 2419 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.2M
     CGroup: /system.slice/redis-server.service
             └─2419 /usr/bin/redis-server 127.0.0.1:6379

Nov 03 17:47:56 redis-server systemd[1]: Starting Advanced key-value store...
Nov 03 17:47:56 redis-server systemd[1]: Started Advanced key-value store.
PONG
___ Begin jemalloc statistics ___
Version: "5.1.0-0-g0"
Build-time option settings
  config.cache_oblivious: true
  config.debug: false
  config.fill: true
  config.lazy_lock: false
  config.malloc_conf: ""
  config.prof: false
  config.prof_libgcc: false
  config.prof_libunwind: false
  config.stats: true
  config.utrace: false
  config.xmalloc: false
Run-time option settings
  opt.abort: false
  opt.abort_conf: false
  opt.retain: true
  opt.dss: "secondary"
  opt.narenas: 1
  opt.percpu_arena: "disabled"
  opt.metadata_thp: "disabled"
  opt.background_thread: false (background_thread: true)
  opt.dirty_decay_ms: 10000 (arenas.dirty_decay_ms: 10000)
  opt.muzzy_decay_ms: 10000 (arenas.muzzy_decay_ms: 10000)
  opt.junk: "false"
  opt.zero: false
  opt.tcache: true
  opt.lg_tcache_max: 15
  opt.thp: "default"
  opt.stats_print: false
  opt.stats_print_opts: ""
Arenas: 1
Quantum size: 8
Page size: 4096
Maximum thread-cached size class: 32768
Number of bin size classes: 39
Number of thread-cache bin size classes: 44
Number of large size classes: 196
Allocated: 1348088, active: 1646592, metadata: 2263320 (n_thp 0), resident: 3883008, mapped: 7938048, retained: 450560
Background threads: 1, num_runs: 2, run_interval: 1573038000 ns
                           n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
background_thread                  69               0               0               1               0               0           0
ctl                               131               0               0               1               0               0           0
prof                                0               0               0               0               0               0           0
arenas[0]:
assigned threads: 1
uptime: 3175998953
dss allocation precedence: "secondary"
decaying:  time       npages       sweeps     madvises       purged
   dirty: 10000            0            1            1            2
   muzzy: 10000            0            1            1            2
                            allocated     nmalloc     ndalloc   nrequests
small:                         655864       14987        1933       17489
large:                         692224          13           4          13
total:                        1348088       15000        1937       17502
                                     
active:                       1646592
mapped:                       7938048
retained:                      450560
base:                         2230544
internal:                       32776
metadata_thp:                       0
tcache_bytes:                  426928
resident:                     3883008
                           n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
large                              34               0               0               1               0               0           0
extent_avail                      151               0               0               3               0               0           0
extents_dirty                     213               0               0               5               0               0           0
extents_muzzy                     117               0               0               5               0               0           0
extents_retained                  197               0               0               5               0               0           0
decay_dirty                        42               0               0               5               0               0           0
decay_muzzy                        41               0               0               5               0               0           0
base                              193               0               0               3               0               0           0
tcache_list                        35               0               0               1               0               0           0
bins:           size ind    allocated      nmalloc      ndalloc    nrequests      curregs     curslabs regs pgs   util       nfills     nflushes       nslabs     nreslabs      n_lock_ops       n_waiting      n_spin_acq  n_owner_switch   total_wait_ns     max_wait_ns  max_n_thds
                   8   0         3088          801          415         2535          386            2  512   1  0.376            8            5            2            1              50               0               0               1               0               0           0
                  16   1       172800        10800            0        11956        10800           43  256   1  0.981          108            0           43            0             185               0               0               1               0               0           0
                  24   2        22488         1000           63         1193          937            2  512   3  0.915           10            1            2            0              47               0               0               1               0               0           0
                  32   3         5664          200           23          360          177            2  128   1  0.691            2            1            2            0              39               0               0               1               0               0           0
                  40   4         3480          100           13          132           87            1  512   5  0.169            1            2            1            0              38               0               0               1               0               0           0
                  48   5         3312          100           31           84           69            1  256   3  0.269            1            2            1            0              38               0               0               1               0               0           0
                  56   6         3752          100           33           91           67            1  512   7  0.130            1            2            1            0              38               0               0               1               0               0           0
                  64   7         4928          128           51           87           77            2   64   1  0.601            2            1            2            0              39               0               0               1               0               0           0
                  80   8        10000          800          675          729          125            1  256   5  0.488            8            7            4            0              56               0               0               1               0               0           0
                  96   9        12000          300          175          291          125            1  128   3  0.976            3            2            3            0              44               0               0               1               0               0           0
                 112  10          784          100           93            3            7            1  256   7  0.027            1            2            1            0              38               0               0               1               0               0           0
                 128  11          256           32           30            5            2            1   32   1  0.062            1            2            1            0              38               0               0               1               0               0           0
                 160  12         4000          100           75            3           25            1  128   5  0.195            1            1            1            0              37               0               0               1               0               0           0
                 192  13         3072           64           48            2           16            1   64   3  0.250            1            1            1            0              37               0               0               1               0               0           0
                 224  14         5600          100           75            2           25            1  128   7  0.195            1            1            1            0              37               0               0               1               0               0           0
                 256  15          256           16           15            3            1            1   16   1  0.062            1            2            1            0              38               0               0               1               0               0           0
                 320  16         5120           64           48            1           16            1   64   5  0.250            1            1            1            0              37               0               0               1               0               0           0
                 384  17         3072           32           24            1            8            1   32   3  0.250            1            1            1            0              37               0               0               1               0               0           0
                 448  18            0            0            0            0            0            0   64   7      1            0            0            0            0              34               0               0               1               0               0           0
                     ---
                 512  19         1024           12           10            3            2            1    8   1  0.250            2            2            3            0              43               0               0               1               0               0           0
                 640  20         5120           32           24            2            8            1   32   5  0.250            1            1            1            0              37               0               0               1               0               0           0
                 768  21            0            0            0            0            0            0   16   3      1            0            0            0            0              34               0               0               1               0               0           0
                 896  22            0            0            0            0            0            0   32   7      1            0            0            0            0              34               0               0               1               0               0           0
                     ---
                1024  23         4096           10            6            3            4            1    4   1      1            1            1            3            0              41               0               0               1               0               0           0
                1280  24        20480           16            0            0           16            1   16   5      1            1            0            1            0              36               0               0               1               0               0           0
                1536  25        15360           10            0            0           10            2    8   3  0.625            1            0            2            0              37               0               0               1               0               0           0
                1792  26            0            0            0            0            0            0   16   7      1            0            0            0            0              34               0               0               1               0               0           0
                     ---
                2048  27         8192           10            6            3            4            2    2   1      1            1            1            5            0              44               0               0               1               0               0           0
                2560  28        25600           10            0            0           10            2    8   5  0.625            1            0            2            0              37               0               0               1               0               0           0
                3072  29            0            0            0            0            0            0    4   3      1            0            0            0            0              34               0               0               1               0               0           0
                     ---
                3584  30        35840           10            0            0           10            2    8   7  0.625            1            0            2            0              37               0               0               1               0               0           0
                4096  31        40960           10            0            0           10           10    1   1      1            1            0           10            0              45               0               0               1               0               0           0
                5120  32        51200           10            0            0           10            3    4   5  0.833            1            0            3            0              38               0               0               1               0               0           0
                6144  33            0            0            0            0            0            0    2   3      1            0            0            0            0              34               0               0               1               0               0           0
                7168  34            0            0            0            0            0            0    4   7      1            0            0            0            0              34               0               0               1               0               0           0
                     ---
                8192  35        81920           10            0            0           10           10    1   2      1            1            0           10            0              45               0               0               1               0               0           0
               10240  36       102400           10            0            0           10            5    2   5      1            1            0            5            0              40               0               0               1               0               0           0
               12288  37            0            0            0            0            0            0    1   3      1            0            0            0            0              34               0               0               1               0               0           0
               14336  38            0            0            0            0            0            0    2   7      1            0            0            0            0              34               0               0               1               0               0           0
                     ---
large:          size ind    allocated      nmalloc      ndalloc    nrequests  curlextents
               16384  39        16384            1            0            1            1
               20480  40        61440            4            1            4            3
                     ---
               32768  43        32768            1            0            1            1
               40960  44        40960            2            1            2            1
               49152  45            0            1            1            1            0
                     ---
               81920  48        81920            1            0            1            1
                     ---
              114688  50            0            1            1            1            0
              131072  51       131072            1            0            1            1
                     ---
              327680  56       327680            1            0            1            1
                     ---
--- End jemalloc statistics ---
"cc74479075ce7d4717300ea6a31998fb8e66f47a0d666f6f1ee5b48139cafb2c"
root@redis-server:~# man add-apt-repository 
root@redis-server:~# man add-apt-repository 
root@redis-server:~# man add-apt-repository 
root@redis-server:~# man apt
root@redis-server:~# man apt install
--Man-- next: install(1) [ view (return) | skip (Ctrl-D) | quit (Ctrl-C) ]

root@redis-server:~# man apt 
root@redis-server:~# man apt-get
root@redis-server:~# 
root@redis-server:~# redis-cli
127.0.0.1:6379> CONFIG GET port
1) "port"
2) "6379"
127.0.0.1:6379> CONFIG SET port 56679
OK
127.0.0.1:6379> 
root@redis-server:~# redis-cli
Could not connect to Redis at 127.0.0.1:6379: Connection refused
not connected> 
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> 
root@redis-server:~# cat /etc/redis/redis.conf | grep port
# are already in use will always fail, and unsupported protocols will always BE
# Accept connections on the specified port, default is 6379 (IANA #815344).
# If port 0 is specified Redis will not listen on a TCP socket.
port 6379
# By default, TLS/SSL is disabled. To enable it, the "tls-port" configuration
# directive can be used to define TLS-listening ports. To enable TLS on the
# default port, use:
# port 0
# tls-port 6379
# By default, clients (including replica servers) on a TLS port are required
# You can explicitly specify TLS versions to support.
# reconnections by clients that support it. Use the following directive to disable
# warning (only very important / critical messages are logged)
# supported:
# {listen-addr}     Bind address or '*' followed by TCP or TLS port listening on, or
# {port}            TCP port listening on, or 0.
# {tls-port}        TLS port listening on, or 0.
# replicaof <masterip> <masterport>
# Still a read only replica exports by default all the administrative commands
# This is important since once the transfer starts, it is not possible to serve
# It is important to make sure that this value is greater than the value
# partial resync is enough, just passing the portion of data the replica
# By default, Redis Sentinel includes all replicas in its reports. A replica
# A Redis master is able to list the address and port of the attached
# The listed IP address and port normally reported by a replica is
#   Port: The port is communicated by the replica during the replication
#   handshake, and is normally the port that the replica is using to
# However when port forwarding or Network Address Translation (NAT) is
# used, the replica may actually be reachable via different IP and port
# report to its master a specific set of IP and port, so that both INFO
# and ROLE will report those values.
# the port or the IP address.
# replica-announce-port 1234
# Redis implements server assisted support for client side caching of values.
# connections, one incoming and another outgoing. It is important to size the
# FLUSHDB, FLUSHALL, and SCRIPT FLUSH support both asynchronous and synchronous
# Redis supports three options:
# Redis supports three different modes:
# cluster node enable the cluster support uncommenting the following:
#    of the failover a delay proportional to their rank.
# (However they'll always try to apply a delay proportional to their
########################## CLUSTER DOCKER/NAT support  ########################
# addresses are NAT-ted or because ports are forwarded (the typical case is
# * cluster-announce-port
# * cluster-announce-tls-port
# * cluster-announce-bus-port
# Each instructs the node about its address, client ports (for connections
# without and with TLS) and cluster message bus port. The information is then
# If cluster-tls is set to yes and cluster-announce-tls-port is omitted or set
# to zero, then cluster-announce-port refers to the TLS port. Note also that
# cluster-announce-tls-port has no effect if cluster-tls is set to no.
# Note that when remapped, the bus port may not be at the fixed offset of
# clients port + 10000, so you can specify any port and bus-port depending
# on how they get remapped. If the bus-port is not set, a fixed offset of
# cluster-announce-tls-port 6379
# cluster-announce-port 0
# cluster-announce-bus-port 6380
# print graphs and obtain reports.
# support.
# The Redis Gopher support uses the inline protocol of Redis, and specifically
# Note that Gopher is not currently supported when 'io-threads-do-reads'
# To enable Gopher support, uncomment the following line and set the option
# Normally it is useful to have an HZ value which is proportional to the
# counter logarithm factor and the counter decay time. It is important to
# Important things to understand:
root@redis-server:~# cat /etc/redis/redis.conf | grep port 63
grep: 63: No such file or directory
root@redis-server:~# cat /etc/redis/redis.conf | grep "port 63"
port 6379
# tls-port 6379
# cluster-announce-tls-port 6379
# cluster-announce-bus-port 6380
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG
(error) ERR wrong number of arguments for 'config' command
127.0.0.1:56679> CONFIG help
 1) CONFIG <subcommand> [<arg> [value] [opt] ...]. Subcommands are:
 2) GET <pattern>
 3)     Return parameters matching the glob-like <pattern> and their values.
 4) SET <directive> <value>
 5)     Set the configuration <directive> to <value>.
 6) RESETSTAT
 7)     Reset statistics reported by the INFO command.
 8) REWRITE
 9)     Rewrite the configuration file.
10) HELP
11)     Prints this help.
127.0.0.1:56679> CONFIG REWRITE
OK
127.0.0.1:56679> 
root@redis-server:~# cat /etc/redis/redis.conf | grep "port 63"
# tls-port 6379
# cluster-announce-tls-port 6379
# cluster-announce-bus-port 6380
root@redis-server:~# cat /etc/redis/redis.conf | grep "port 566"
port 56679
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG GET bind
1) "bind"
2) "127.0.0.1 -::1"
127.0.0.1:56679> CONFIG GET requirepass
1) "requirepass"
2) ""
127.0.0.1:56679> ACL GENPASS;
(error) ERR Unknown subcommand or wrong number of arguments for 'GENPASS;'. Try ACL HELP.
127.0.0.1:56679> ACL GENPASS
"db376693cf0a9d38d571fb1d1d3be9f847f6ea0a736eadd8ceaa1de3fbdc9d44"
127.0.0.1:56679> CONFIG SET requirepass db376693cf0a9d38d571fb1d1d3be9f847f6ea0a736eadd8ceaa1de3fbdc9d44
OK
127.0.0.1:56679> 
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> ping
(error) NOAUTH Authentication required.
127.0.0.1:56679> 
root@redis-server:~# export REDISCLI_AUTH="db376693cf0a9d38d571fb1d1d3be9f847f6ea0a736eadd8ceaa1de3fbdc9d44"
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> ping
PONG
127.0.0.1:56679> 
root@redis-server:~# cat /etc/redis/redis.conf | grep "requirepass"
# If the master is password protected (using the "requirepass" configuration
# IMPORTANT NOTE: starting with Redis 6 "requirepass" is just a compatibility
# The requirepass is not compatable with aclfile option and the ACL LOAD
# command, these will cause requirepass to be ignored.
# requirepass foobared
# So use the 'requirepass' option to protect your instance.
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG REWRITE
OK
127.0.0.1:56679> 
root@redis-server:~# cat /etc/redis/redis.conf | grep "requirepass"
# If the master is password protected (using the "requirepass" configuration
# IMPORTANT NOTE: starting with Redis 6 "requirepass" is just a compatibility
# The requirepass is not compatable with aclfile option and the ACL LOAD
# command, these will cause requirepass to be ignored.
# requirepass foobared
# So use the 'requirepass' option to protect your instance.
requirepass "db376693cf0a9d38d571fb1d1d3be9f847f6ea0a736eadd8ceaa1de3fbdc9d44"
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> ping
PONG
127.0.0.1:56679> CONFIG GET bind
1) "bind"
2) "127.0.0.1 -::1"
127.0.0.1:56679> CONFIG SET bind 
(error) ERR Unknown subcommand or wrong number of arguments for 'SET'. Try CONFIG HELP.
127.0.0.1:56679> CONFIG SET bind ""
(error) ERR Too many bind addresses specified.
127.0.0.1:56679> CONFIG 
(error) ERR wrong number of arguments for 'config' command
127.0.0.1:56679> CONFIG HELP
 1) CONFIG <subcommand> [<arg> [value] [opt] ...]. Subcommands are:
 2) GET <pattern>
 3)     Return parameters matching the glob-like <pattern> and their values.
 4) SET <directive> <value>
 5)     Set the configuration <directive> to <value>.
 6) RESETSTAT
 7)     Reset statistics reported by the INFO command.
 8) REWRITE
 9)     Rewrite the configuration file.
10) HELP
11)     Prints this help.
127.0.0.1:56679> CONFIG SET bind " "
(error) ERR Failed to bind to specified addresses.
127.0.0.1:56679> CONFIG SET bind ""
(error) ERR Too many bind addresses specified.
127.0.0.1:56679> 
root@redis-server:~#     vi /etc/redis/redis.conf;
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG GET bind
1) "bind"
2) "127.0.0.1 -::1"
127.0.0.1:56679> CONFIG SET bind "* -::*"
OK
127.0.0.1:56679> CONFIG GET bind
1) "bind"
2) "* -::*"
127.0.0.1:56679> 
root@redis-server:~# ifconfig

Command 'ifconfig' not found, but can be installed with:

apt install net-tools

root@redis-server:~# apt install net-tools
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  net-tools
0 upgraded, 1 newly installed, 0 to remove and 19 not upgraded.
Need to get 196 kB of archives.
After this operation, 864 kB of additional disk space will be used.
Get:1 http://mirrors.digitalocean.com/ubuntu focal/main amd64 net-tools amd64 1.60+git20180626.aebd88e-1ubuntu1 [196 kB]
Fetched 196 kB in 0s (1044 kB/s)
Selecting previously unselected package net-tools.
(Reading database ... 63592 files and directories currently installed.)
Preparing to unpack .../net-tools_1.60+git20180626.aebd88e-1ubuntu1_amd64.deb ...
Unpacking net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Setting up net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Processing triggers for man-db (2.9.1-1) ...
root@redis-server:~# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 142.93.221.126  netmask 255.255.240.0  broadcast 142.93.223.255
        inet6 fe80::a05b:abff:fe28:22e0  prefixlen 64  scopeid 0x20<link>
        ether a2:5b:ab:28:22:e0  txqueuelen 1000  (Ethernet)
        RX packets 5425  bytes 10167395 (10.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4051  bytes 516592 (516.5 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.122.0.2  netmask 255.255.240.0  broadcast 10.122.15.255
        inet6 fe80::3ccd:42ff:feb8:66d0  prefixlen 64  scopeid 0x20<link>
        ether 3e:cd:42:b8:66:d0  txqueuelen 1000  (Ethernet)
        RX packets 13  bytes 986 (986.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 14  bytes 1076 (1.0 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 1131  bytes 248378 (248.3 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1131  bytes 248378 (248.3 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@redis-server:~# redis-cli -h 142.93.221.126 -p 56679
142.93.221.126:56679> ping
PONG
142.93.221.126:56679> 
root@redis-server:~# 
```

```bash
redis-stuff $ redis-cli -h 142.93.221.126 -p 56679 PING
(error) NOAUTH Authentication required.
redis-stuff $ redis-cli -h 142.93.221.126 -p 56679 
redis-stuff $ export REDISCLI_AUTH="db376693cf0a9d38d571fb1d1d3be9f847f6ea0a736eadd8ceaa1de3fbdc9d44"
redis-stuff $ redis-cli -h 142.93.221.126 -p 56679 PING
PONG
redis-stuff $ redis-cli -h 142.93.221.126 -p 56679 
142.93.221.126:56679> 
```

---

https://duckduckgo.com/?t=ffab&q=letsencrypt&ia=web

https://letsencrypt.org/getting-started/

https://certbot.eff.org/

https://certbot.eff.org/lets-encrypt/ubuntufocal-other

---

[TODO]
- Check how to clients can authenticate with the server using client certificates instead of using password, or does a client need both or may not need one even if it has the other?

---

https://duckduckgo.com/?t=ffab&q=let%27s+encrypt+CA+certificate&ia=web

https://letsencrypt.org/certificates/

https://duckduckgo.com/?t=ffab&q=redis+tls-cert-file&ia=web

https://duckduckgo.com/?t=ffab&q=redis%3A+error%3A0200100D%3Asystem+library%3Afopen%3APermission+denied&ia=web

https://duckduckgo.com/?q=redis+error%3A0200100D%3Asystem+library%3Afopen%3APermission+denied&t=ffab&ia=web

https://redis.io/topics/encryption

---

Lol, I mistook a config and thought it was a cert authority certificate that provided the SSL certificate, but it was actually more of a thing to authenticate clients, clients that are using SSL/TLS certificates to authenticate

---

```bash
root@redis-server:~# snap
The snap command lets you install, configure, refresh and remove snaps.
Snaps are packages that work across many different Linux distributions,
enabling secure delivery and operation of the latest apps and utilities.

Usage: snap <command> [<options>...]

Commonly used commands can be classified as follows:

         Basics: find, info, install, remove, list
        ...more: refresh, revert, switch, disable, enable, create-cohort
        History: changes, tasks, abort, watch
        Daemons: services, start, stop, restart, logs
    Permissions: connections, interface, connect, disconnect
  Configuration: get, set, unset, wait
    App Aliases: alias, aliases, unalias, prefer
        Account: login, logout, whoami
      Snapshots: saved, save, check-snapshot, restore, forget
         Device: model, reboot, recovery
      ... Other: warnings, okay, known, ack, version
    Development: download, pack, run, try

For more information about a command, run 'snap help <command>'.
For a short summary of all commands, run 'snap help --all'.
root@redis-server:~# sudo snap install core; sudo snap refresh core
core 16-2.52.1 from Canonical✓ installed
snap "core" has no updates available
root@redis-server:~# certbot

Command 'certbot' not found, but can be installed with:

apt install certbot

root@redis-server:~# sudo snap install --classic certbot
certbot 1.20.0 from Certbot Project (certbot-eff✓) installed
root@redis-server:~# sudo ln -s /snap/bin/certbot /usr/bin/certbot
root@redis-server:~# certbot 
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Certbot doesn't know how to automatically configure the web server on this system. However, it can still get a certificate for you. Please run "certbot certonly" to do so. You'll need to manually configure your web server to use the resulting certificate.
root@redis-server:~# sudo certbot certonly --standalone
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): karuppiah7890@gmail.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y 

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y
Account registered.
Please enter the domain name(s) you would like on your certificate (comma and/or
space separated) (Enter 'c' to cancel): localhost,142.93.221.126

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
One or more of the entered domain names was not valid:

142.93.221.126: Requested name 142.93.221.126 is an IP address. The Let's
Encrypt certificate authority will not issue certificates for a bare IP address.

Would you like to re-enter the names?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y
Please enter the domain name(s) you would like on your certificate (comma and/or
space separated) (Enter 'c' to cancel): redis-server-1.hosteddatabase.in
Requesting a certificate for redis-server-1.hosteddatabase.in

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
This certificate expires on 2022-02-01.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
root@redis-server:~# 
root@redis-server:~# 
root@redis-server:~# sudo certbot renew --dry-run
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/redis-server-1.hosteddatabase.in.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Account registered.
Simulating renewal of an existing certificate for redis-server-1.hosteddatabase.in

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded: 
  /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
root@redis-server:~# ls /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/
README  cert.pem  chain.pem  fullchain.pem  privkey.pem
root@redis-server:~# ls /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem 
/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem 
root@redis-server:~# less /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem 
root@redis-server:~# less /etc/redis/redis.conf 
root@redis-server:~# cat /etc/redis/redis.conf | grep tls
# By default, TLS/SSL is disabled. To enable it, the "tls-port" configuration
# tls-port 6379
# tls-cert-file redis.crt
# tls-key-file redis.key
# tls-key-file-pass secret
# tls-client-cert-file client.crt
# tls-client-key-file client.key
# tls-client-key-file-pass secret
# tls-dh-params-file redis.dh
# tls-ca-cert-file ca.crt
# tls-ca-cert-dir /etc/ssl/certs
# tls-auth-clients no
# tls-auth-clients optional
# tls-replication yes
# tls-cluster yes
# tls-protocols "TLSv1.2 TLSv1.3"
# tls-ciphers DEFAULT:!MEDIUM
# tls-ciphersuites TLS_CHACHA20_POLY1305_SHA256
# tls-prefer-server-ciphers yes
# tls-session-caching no
# tls-session-cache-size 5000
# tls-session-cache-timeout 60
# {tls-port}        TLS port listening on, or 0.
# * cluster-announce-tls-port
# If cluster-tls is set to yes and cluster-announce-tls-port is omitted or set
# cluster-announce-tls-port has no effect if cluster-tls is set to no.
# cluster-announce-tls-port 6379
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> ping
PONG
127.0.0.1:56679> CONFIG GET tls-ca-cert-dir
1) "tls-ca-cert-dir"
2) ""
127.0.0.1:56679> CONFIG SET tls-ca-cert-dir /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/
OK
127.0.0.1:56679> CONFIG GET tls-ca-cert-dir
1) "tls-ca-cert-dir"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/"
127.0.0.1:56679> CONFIG GET tls-ca-cert-file
1) "tls-ca-cert-file"
2) ""
127.0.0.1:56679> CONFIG SET tls-ca-cert-file cert.pem
OK
127.0.0.1:56679> CONFIG SET tls-ca-cert-file ""
OK
127.0.0.1:56679> CONFIG GET tls-ca-cert-file
1) "tls-ca-cert-file"
2) ""
127.0.0.1:56679> CONFIG GET tls-ca-cert-dir
1) "tls-ca-cert-dir"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/"
127.0.0.1:56679> CONFIG SET tls-ca-cert-dir ""
OK
127.0.0.1:56679> 
root@redis-server:~# wget https://letsencrypt.org/certs/lets-encrypt-r3.pem
--2021-11-03 18:26:58--  https://letsencrypt.org/certs/lets-encrypt-r3.pem
Resolving letsencrypt.org (letsencrypt.org)... 52.220.244.242, 104.248.158.121, 2406:da18:880:3802:371c:4bf1:923b:fc30, ...
Connecting to letsencrypt.org (letsencrypt.org)|52.220.244.242|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1826 (1.8K) [application/x-pem-file]
Saving to: ‘lets-encrypt-r3.pem’

lets-encrypt-r3.pem             100%[=====================================================>]   1.78K  --.-KB/s    in 0s      

2021-11-03 18:26:58 (16.9 MB/s) - ‘lets-encrypt-r3.pem’ saved [1826/1826]

root@redis-server:~# less lets-encrypt-r3.pem 
root@redis-server:~# mv lets-encrypt-r3.pem /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/^C
root@redis-server:~# ls /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/
README  cert.pem  chain.pem  fullchain.pem  privkey.pem
root@redis-server:~# ls /etc/letsencrypt/live/
README  redis-server-1.hosteddatabase.in
root@redis-server:~# ls /etc/letsencrypt
accounts  archive  csr  keys  live  renewal  renewal-hooks
root@redis-server:~# ls /etc/letsencrypt/accounts/
acme-staging-v02.api.letsencrypt.org  acme-v02.api.letsencrypt.org
root@redis-server:~# ls /etc/letsencrypt/accounts/acme-staging-v02.api.letsencrypt.org/directory/5e1e7ba73e62f84ab8e272d70b510618/
meta.json         private_key.json  regr.json         
root@redis-server:~# ls /etc/letsencrypt/accounts/acme-staging-v02.api.letsencrypt.org/directory/5e1e7ba73e62f84ab8e272d70b510618/
meta.json  private_key.json  regr.json
root@redis-server:~# ls /etc/letsencrypt/keys/
0000_key-certbot.pem
root@redis-server:~# ls /etc/letsencrypt/keys/0000_key-certbot.pem 
/etc/letsencrypt/keys/0000_key-certbot.pem
root@redis-server:~# less /etc/letsencrypt/keys/0000_key-certbot.pem 
root@redis-server:~# diff  /etc/letsencrypt/keys/0000_key-certbot.pem 
.bashrc                  .lesshst                 .ssh/                    lets-encrypt-r3.pem      
.cache/                  .profile                 .viminfo                 snap/                    
.cloud-locale-test.skip  .rediscli_history        .wget-hsts               
root@redis-server:~# diff lets-encrypt-r3.pem /etc/letsencrypt/keys/0000_key-certbot.pem 
1,30c1,28
< -----BEGIN CERTIFICATE-----
< dummy-values
< -----END CERTIFICATE-----
---
> -----BEGIN PRIVATE KEY-----
> dummy-values
> -----END PRIVATE KEY-----
root@redis-server:~# 
(failed reverse-i-search)`mv': diff lets-encrypt-r3.pem /etc/letsencrypt/keys/0000_key-certbot.pe^C
root@redis-server:~# ls /etc/letsencrypt/keys/
0000_key-certbot.pem
root@redis-server:~# ls /etc/letsencrypt/live/
README                            redis-server-1.hosteddatabase.in/ 
root@redis-server:~# ls /etc/letsencrypt/live/
README                            redis-server-1.hosteddatabase.in/ 
root@redis-server:~# ls /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/
README  cert.pem  chain.pem  fullchain.pem  privkey.pem
root@redis-server:~# cp lets-encrypt-r3.pem /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG GET tls-ca-cert-dir
1) "tls-ca-cert-dir"
2) ""
127.0.0.1:56679> CONFIG SET tls-ca-cert-file ""
OK
127.0.0.1:56679> CONFIG SET tls-ca-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/lets-encrypt-r3.pem"
OK
127.0.0.1:56679> CONFIG GET tls-ca-cert-file
1) "tls-ca-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/lets-encrypt-r3.pem"
127.0.0.1:56679> CONFIG GET tls-cert-file
1) "tls-cert-file"
2) ""
127.0.0.1:56679> CONFIG GET tls-key-file
1) "tls-key-file"
2) ""
127.0.0.1:56679> CONFIG GET tls-key-file-1
(empty array)
127.0.0.1:56679> CONFIG GET tls-key-file
1) "tls-key-file"
2) ""
127.0.0.1:56679> CONFIG SET tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
OK
127.0.0.1:56679> CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
127.0.0.1:56679> CONFIG SET tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem-wron"
OK
127.0.0.1:56679> CONFIG SET tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
OK
127.0.0.1:56679> CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
127.0.0.1:56679> CONFIG GET tls-cert-file
1) "tls-cert-file"
2) ""
127.0.0.1:56679> CONFIG SET tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
OK
127.0.0.1:56679> CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
127.0.0.1:56679> CONFIG GET tls-port
1) "tls-port"
2) "0"
127.0.0.1:56679> CONFIG SET tls-port 56680
(error) ERR Invalid argument '56680' for CONFIG SET 'tls-port' - Unable to update TLS configuration. Check server logs.
127.0.0.1:56679> CONFIG SET tls-port "56680"
(error) ERR Invalid argument '56680' for CONFIG SET 'tls-port' - Unable to update TLS configuration. Check server logs.
127.0.0.1:56679> 
root@redis-server:~# ls /var/log
apt       cloud-init-output.log  dmesg                     journal    lastlog      redis                 unattended-upgrades
auth.log  cloud-init.log         dpkg.log                  kern.log   letsencrypt  syslog                wtmp
btmp      dist-upgrade           droplet-agent.update.log  landscape  private      ubuntu-advantage.log
root@redis-server:~# ls /var/log/redis/redis-server.log 
/var/log/redis/redis-server.log
root@redis-server:~# less /var/log/redis/redis-server.log 
root@redis-server:~# cat /var/log/redis/redis-server.log 
2419:C 03 Nov 2021 17:47:56.535 * Supervised by systemd. Please make sure you set appropriate values for TimeoutStartSec and TimeoutStopSec in your service unit.
2419:C 03 Nov 2021 17:47:56.535 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
2419:C 03 Nov 2021 17:47:56.535 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=2419, just started
2419:C 03 Nov 2021 17:47:56.535 # Configuration loaded
2419:M 03 Nov 2021 17:47:56.536 * monotonic clock: POSIX clock_gettime
2419:M 03 Nov 2021 17:47:56.540 * Running mode=standalone, port=6379.
2419:M 03 Nov 2021 17:47:56.540 # Server initialized
2419:M 03 Nov 2021 17:47:56.540 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
2419:M 03 Nov 2021 17:47:56.543 * Ready to accept connections
2419:M 03 Nov 2021 17:50:57.539 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:53:18.928 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:55:59.620 # Warning: Could not create server TCP listening socket :56679: Name or service not known
2419:M 03 Nov 2021 17:55:59.620 # Failed to bind, trying to restore old listening sockets.
2419:M 03 Nov 2021 18:32:14.244 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:32:26.558 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
root@redis-server:~# ls /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
root@redis-server:~# ls -al /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
lrwxrwxrwx 1 root root 61 Nov  3 18:13 /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem -> ../../archive/redis-server-1.hosteddatabase.in/fullchain1.pem
root@redis-server:~# ls /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
root@redis-server:~# redis-cli
Could not connect to Redis at 127.0.0.1:6379: Connection refused
not connected> 
root@redis-server:~# redis-cli
Could not connect to Redis at 127.0.0.1:6379: Connection refused
not connected> 
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG GET tls-port 
1) "tls-port"
2) "0"
127.0.0.1:56679> CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
127.0.0.1:56679> CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
127.0.0.1:56679> CONFIG GET tls-ca-cert-file
1) "tls-ca-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/lets-encrypt-r3.pem"
127.0.0.1:56679> CONFIG SET tls-ca-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem"
OK
127.0.0.1:56679> CONFIG SET tls-port 56680
(error) ERR Invalid argument '56680' for CONFIG SET 'tls-port' - Unable to update TLS configuration. Check server logs.
127.0.0.1:56679> 
root@redis-server:~# cat /var/log/redis/redis-server.log 
2419:C 03 Nov 2021 17:47:56.535 * Supervised by systemd. Please make sure you set appropriate values for TimeoutStartSec and TimeoutStopSec in your service unit.
2419:C 03 Nov 2021 17:47:56.535 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
2419:C 03 Nov 2021 17:47:56.535 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=2419, just started
2419:C 03 Nov 2021 17:47:56.535 # Configuration loaded
2419:M 03 Nov 2021 17:47:56.536 * monotonic clock: POSIX clock_gettime
2419:M 03 Nov 2021 17:47:56.540 * Running mode=standalone, port=6379.
2419:M 03 Nov 2021 17:47:56.540 # Server initialized
2419:M 03 Nov 2021 17:47:56.540 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
2419:M 03 Nov 2021 17:47:56.543 * Ready to accept connections
2419:M 03 Nov 2021 17:50:57.539 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:53:18.928 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:55:59.620 # Warning: Could not create server TCP listening socket :56679: Name or service not known
2419:M 03 Nov 2021 17:55:59.620 # Failed to bind, trying to restore old listening sockets.
2419:M 03 Nov 2021 18:32:14.244 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:32:26.558 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:38:27.890 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
root@redis-server:~# ls /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
root@redis-server:~# ls -al /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
lrwxrwxrwx 1 root root 61 Nov  3 18:13 /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem -> ../../archive/redis-server-1.hosteddatabase.in/fullchain1.pem
root@redis-server:~# ls -al /etc/letsencrypt/live/redis-server-1.hosteddatabase.in
total 20
drwxr-xr-x 2 root root 4096 Nov  3 18:28 .
drwx------ 3 root root 4096 Nov  3 18:13 ..
-rw-r--r-- 1 root root  692 Nov  3 18:13 README
lrwxrwxrwx 1 root root   56 Nov  3 18:13 cert.pem -> ../../archive/redis-server-1.hosteddatabase.in/cert1.pem
lrwxrwxrwx 1 root root   57 Nov  3 18:13 chain.pem -> ../../archive/redis-server-1.hosteddatabase.in/chain1.pem
lrwxrwxrwx 1 root root   61 Nov  3 18:13 fullchain.pem -> ../../archive/redis-server-1.hosteddatabase.in/fullchain1.pem
-rw-r--r-- 1 root root 1826 Nov  3 18:28 lets-encrypt-r3.pem
lrwxrwxrwx 1 root root   59 Nov  3 18:13 privkey.pem -> ../../archive/redis-server-1.hosteddatabase.in/privkey1.pem
root@redis-server:~# systemctl status redis
Unit redis.service could not be found.
root@redis-server:~# systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-11-03 17:47:56 UTC; 51min ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 2419 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.5M
     CGroup: /system.slice/redis-server.service
             └─2419 /usr/bin/redis-server *:56679

Nov 03 17:47:56 redis-server systemd[1]: Starting Advanced key-value store...
Nov 03 17:47:56 redis-server systemd[1]: Started Advanced key-value store.
root@redis-server:~# less /lib/systemd/system/redis-server.service
root@redis-server:~# ls /etc/letsencrypt/
accounts  archive  csr  keys  live  renewal  renewal-hooks
root@redis-server:~# ls /etc/letsencrypt/archive/
redis-server-1.hosteddatabase.in
root@redis-server:~# ls /etc/letsencrypt/archive/redis-server-1.hosteddatabase.in/
cert1.pem  chain1.pem  fullchain1.pem  privkey1.pem
root@redis-server:~# ls -al /etc/letsencrypt/archive/redis-server-1.hosteddatabase.in/
total 28
drwxr-xr-x 2 root root 4096 Nov  3 18:13 .
drwx------ 3 root root 4096 Nov  3 18:13 ..
-rw-r--r-- 1 root root 1891 Nov  3 18:13 cert1.pem
-rw-r--r-- 1 root root 3749 Nov  3 18:13 chain1.pem
-rw-r--r-- 1 root root 5640 Nov  3 18:13 fullchain1.pem
-rw------- 1 root root 1704 Nov  3 18:13 privkey1.pem
root@redis-server:~# chown -R redis:redis /etc/letsencrypt/
root@redis-server:~# ls -al /etc/letsencrypt/archive/redis-server-1.hosteddatabase.in/
total 28
drwxr-xr-x 2 redis redis 4096 Nov  3 18:13 .
drwx------ 3 redis redis 4096 Nov  3 18:13 ..
-rw-r--r-- 1 redis redis 1891 Nov  3 18:13 cert1.pem
-rw-r--r-- 1 redis redis 3749 Nov  3 18:13 chain1.pem
-rw-r--r-- 1 redis redis 5640 Nov  3 18:13 fullchain1.pem
-rw------- 1 redis redis 1704 Nov  3 18:13 privkey1.pem
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG SET tls-port 56680
OK
127.0.0.1:56679> CONFIG GET tls-port 
1) "tls-port"
2) "56680"
127.0.0.1:56679> 
root@redis-server:~# cat /var/log/redis/redis-server.log 
2419:C 03 Nov 2021 17:47:56.535 * Supervised by systemd. Please make sure you set appropriate values for TimeoutStartSec and TimeoutStopSec in your service unit.
2419:C 03 Nov 2021 17:47:56.535 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
2419:C 03 Nov 2021 17:47:56.535 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=2419, just started
2419:C 03 Nov 2021 17:47:56.535 # Configuration loaded
2419:M 03 Nov 2021 17:47:56.536 * monotonic clock: POSIX clock_gettime
2419:M 03 Nov 2021 17:47:56.540 * Running mode=standalone, port=6379.
2419:M 03 Nov 2021 17:47:56.540 # Server initialized
2419:M 03 Nov 2021 17:47:56.540 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
2419:M 03 Nov 2021 17:47:56.543 * Ready to accept connections
2419:M 03 Nov 2021 17:50:57.539 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:53:18.928 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:55:59.620 # Warning: Could not create server TCP listening socket :56679: Name or service not known
2419:M 03 Nov 2021 17:55:59.620 # Failed to bind, trying to restore old listening sockets.
2419:M 03 Nov 2021 18:32:14.244 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:32:26.558 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:38:27.890 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:42:41.975 # Error accepting a client connection: error:1417C0C7:SSL routines:tls_process_client_certificate:peer did not return a certificate
2419:M 03 Nov 2021 18:42:44.907 # Error accepting a client connection: error:1417C0C7:SSL routines:tls_process_client_certificate:peer did not return a certificate
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "yes"
127.0.0.1:56679> 
root@redis-server:~# cat /etc/redis/redis.conf | grep tls-auth
# tls-auth-clients no
# tls-auth-clients optional
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> 
root@redis-server:~# cat /etc/redis/redis.conf | grep -C 5 tls-auth
#
# If "no" is specified, client certificates are not required and not accepted.
# If "optional" is specified, client certificates are accepted and must be
# valid if provided, but are not required.
#
# tls-auth-clients no
# tls-auth-clients optional

# By default, a Redis replica does not attempt to establish a TLS connection
# with its master.
#
# Use the following directive to enable TLS on replication links.
root@redis-server:~# cat /etc/redis/redis.conf | grep -B 15 tls-auth

# Configure a CA certificate(s) bundle or directory to authenticate TLS/SSL
# clients and peers.  Redis requires an explicit configuration of at least one
# of these, and will not implicitly use the system wide configuration.
#
# tls-ca-cert-file ca.crt
# tls-ca-cert-dir /etc/ssl/certs

# By default, clients (including replica servers) on a TLS port are required
# to authenticate using valid client side certificates.
#
# If "no" is specified, client certificates are not required and not accepted.
# If "optional" is specified, client certificates are accepted and must be
# valid if provided, but are not required.
#
# tls-auth-clients no
# tls-auth-clients optional
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFG GET tls-ca-cert-file
(error) ERR unknown command `CONFG`, with args beginning with: `GET`, `tls-ca-cert-file`, 
127.0.0.1:56679> CONFIG GET tls-ca-cert-file
1) "tls-ca-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/cert.pem"
127.0.0.1:56679> CONFIG SET tls-ca-cert-file ""
(error) ERR Invalid argument '' for CONFIG SET 'tls-ca-cert-file' - Unable to update TLS configuration. Check server logs.
127.0.0.1:56679> 
root@redis-server:~# cat /var/log/redis/redis-server.log 
2419:C 03 Nov 2021 17:47:56.535 * Supervised by systemd. Please make sure you set appropriate values for TimeoutStartSec and TimeoutStopSec in your service unit.
2419:C 03 Nov 2021 17:47:56.535 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
2419:C 03 Nov 2021 17:47:56.535 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=2419, just started
2419:C 03 Nov 2021 17:47:56.535 # Configuration loaded
2419:M 03 Nov 2021 17:47:56.536 * monotonic clock: POSIX clock_gettime
2419:M 03 Nov 2021 17:47:56.540 * Running mode=standalone, port=6379.
2419:M 03 Nov 2021 17:47:56.540 # Server initialized
2419:M 03 Nov 2021 17:47:56.540 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
2419:M 03 Nov 2021 17:47:56.543 * Ready to accept connections
2419:M 03 Nov 2021 17:50:57.539 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:53:18.928 # CONFIG REWRITE executed with success.
2419:M 03 Nov 2021 17:55:59.620 # Warning: Could not create server TCP listening socket :56679: Name or service not known
2419:M 03 Nov 2021 17:55:59.620 # Failed to bind, trying to restore old listening sockets.
2419:M 03 Nov 2021 18:32:14.244 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:32:26.558 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:38:27.890 # Failed to load certificate: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem: error:0200100D:system library:fopen:Permission denied
2419:M 03 Nov 2021 18:42:41.975 # Error accepting a client connection: error:1417C0C7:SSL routines:tls_process_client_certificate:peer did not return a certificate
2419:M 03 Nov 2021 18:42:44.907 # Error accepting a client connection: error:1417C0C7:SSL routines:tls_process_client_certificate:peer did not return a certificate
2419:M 03 Nov 2021 18:46:23.230 # Either tls-ca-cert-file or tls-ca-cert-dir must be specified when tls-cluster, tls-replication or tls-auth-clients are enabled!
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG SET tls-auth-clients no
OK
127.0.0.1:56679> CONFIG REWRITE
OK
127.0.0.1:56679> 
root@redis-server:~# redis-cli -p 56679
127.0.0.1:56679> CONFIG SET tls-ca-cert-file ""
OK
127.0.0.1:56679> CONFIG GET tls-ca-cert-file
1) "tls-ca-cert-file"
2) ""
127.0.0.1:56679> CONFIG GET tls-ca-cert-dir
1) "tls-ca-cert-dir"
2) ""
127.0.0.1:56679> CONFIG GET tls-cluster
1) "tls-cluster"
2) "no"
127.0.0.1:56679> CONFIG GET tls-replication
1) "tls-replication"
2) "no"
127.0.0.1:56679> CONFIG GET tls-auth
(empty array)
127.0.0.1:56679> CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
127.0.0.1:56679> 
root@redis-server:~# logout
Connection to 142.93.221.126 closed.
database-stuff $ doctl compute droplet delete redis-server
Warning: Are you sure you want to delete this Droplet? (y/N) ? y
database-stuff $ doctl compute droplet delete --help
Use this command to permanently delete a Droplet. This is irreversible.

Usage:
  doctl compute droplet delete <droplet-id|droplet-name>... [flags]

Aliases:
  delete, d, del, rm

Flags:
  -f, --force             Delete the Droplet without a confirmation prompt
  -h, --help              help for delete
      --tag-name string   Tag name

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ 
```

```bash
142.93.221.126:56679> 
redis-stuff $ dig redis-server-1.hosteddatabase.in

; <<>> DiG 9.10.6 <<>> redis-server-1.hosteddatabase.in
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3818
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 13, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;redis-server-1.hosteddatabase.in. IN	A

;; ANSWER SECTION:
redis-server-1.hosteddatabase.in. 600 IN A	142.93.221.126

;; AUTHORITY SECTION:
.			59258	IN	NS	e.root-servers.net.
.			59258	IN	NS	c.root-servers.net.
.			59258	IN	NS	i.root-servers.net.
.			59258	IN	NS	f.root-servers.net.
.			59258	IN	NS	b.root-servers.net.
.			59258	IN	NS	m.root-servers.net.
.			59258	IN	NS	g.root-servers.net.
.			59258	IN	NS	l.root-servers.net.
.			59258	IN	NS	k.root-servers.net.
.			59258	IN	NS	a.root-servers.net.
.			59258	IN	NS	j.root-servers.net.
.			59258	IN	NS	h.root-servers.net.
.			59258	IN	NS	d.root-servers.net.

;; ADDITIONAL SECTION:
G.root-servers.net.	19349	IN	A	192.112.36.4

;; Query time: 82 msec
;; SERVER: 10.112.16.144#53(10.112.16.144)
;; WHEN: Wed Nov 03 23:42:47 IST 2021
;; MSG SIZE  rcvd: 306

redis-stuff $ redis-cli -h 142.93.221.126 -p 56679 
142.93.221.126:56679> 
redis-stuff $ redis-cli --tls -h 142.93.221.126 -p 56679 
^C
redis-stuff $ redis-cli --tls -h 142.93.221.126 -p 56679 -v
redis-cli 6.2.6
redis-stuff $ redis-cli --tls -h 142.93.221.126 -p 56679 --help
redis-cli 6.2.6

Usage: redis-cli [OPTIONS] [cmd [arg [arg ...]]]
  -h <hostname>      Server hostname (default: 127.0.0.1).
  -p <port>          Server port (default: 6379).
  -s <socket>        Server socket (overrides hostname and port).
  -a <password>      Password to use when connecting to the server.
                     You can also use the REDISCLI_AUTH environment
                     variable to pass this password more safely
                     (if both are used, this argument takes precedence).
  --user <username>  Used to send ACL style 'AUTH username pass'. Needs -a.
  --pass <password>  Alias of -a for consistency with the new --user option.
  --askpass          Force user to input password with mask from STDIN.
                     If this argument is used, '-a' and REDISCLI_AUTH
                     environment variable will be ignored.
  -u <uri>           Server URI.
  -r <repeat>        Execute specified command N times.
  -i <interval>      When -r is used, waits <interval> seconds per command.
                     It is possible to specify sub-second times like -i 0.1.
  -n <db>            Database number.
  -3                 Start session in RESP3 protocol mode.
  -x                 Read last argument from STDIN.
  -d <delimiter>     Delimiter between response bulks for raw formatting (default: \n).
  -D <delimiter>     Delimiter between responses for raw formatting (default: \n).
  -c                 Enable cluster mode (follow -ASK and -MOVED redirections).
  -e                 Return exit error code when command execution fails.
  --tls              Establish a secure TLS connection.
  --sni <host>       Server name indication for TLS.
  --cacert <file>    CA Certificate file to verify with.
  --cacertdir <dir>  Directory where trusted CA certificates are stored.
                     If neither cacert nor cacertdir are specified, the default
                     system-wide trusted root certs configuration will apply.
  --insecure         Allow insecure TLS connection by skipping cert validation.
  --cert <file>      Client certificate to authenticate with.
  --key <file>       Private key file to authenticate with.
  --tls-ciphers <list> Sets the list of prefered ciphers (TLSv1.2 and below)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string.
  --tls-ciphersuites <list> Sets the list of prefered ciphersuites (TLSv1.3)
                     in order of preference from highest to lowest separated by colon (":").
                     See the ciphers(1ssl) manpage for more information about the syntax of this string,
                     and specifically for TLSv1.3 ciphersuites.
  --raw              Use raw formatting for replies (default when STDOUT is
                     not a tty).
  --no-raw           Force formatted output even when STDOUT is not a tty.
  --quoted-input     Force input to be handled as quoted strings.
  --csv              Output in CSV format.
  --show-pushes <yn> Whether to print RESP3 PUSH messages.  Enabled by default when
                     STDOUT is a tty but can be overriden with --show-pushes no.
  --stat             Print rolling stats about server: mem, clients, ...
  --latency          Enter a special mode continuously sampling latency.
                     If you use this mode in an interactive session it runs
                     forever displaying real-time stats. Otherwise if --raw or
                     --csv is specified, or if you redirect the output to a non
                     TTY, it samples the latency for 1 second (you can use
                     -i to change the interval), then produces a single output
                     and exits.
  --latency-history  Like --latency but tracking latency changes over time.
                     Default time interval is 15 sec. Change it using -i.
  --latency-dist     Shows latency as a spectrum, requires xterm 256 colors.
                     Default time interval is 1 sec. Change it using -i.
  --lru-test <keys>  Simulate a cache workload with an 80-20 distribution.
  --replica          Simulate a replica showing commands received from the master.
  --rdb <filename>   Transfer an RDB dump from remote server to local file.
                     Use filename of "-" to write to stdout.
  --pipe             Transfer raw Redis protocol from stdin to server.
  --pipe-timeout <n> In --pipe mode, abort with error if after sending all data.
                     no reply is received within <n> seconds.
                     Default timeout: 30. Use 0 to wait forever.
  --bigkeys          Sample Redis keys looking for keys with many elements (complexity).
  --memkeys          Sample Redis keys looking for keys consuming a lot of memory.
  --memkeys-samples <n> Sample Redis keys looking for keys consuming a lot of memory.
                     And define number of key elements to sample
  --hotkeys          Sample Redis keys looking for hot keys.
                     only works when maxmemory-policy is *lfu.
  --scan             List all keys using the SCAN command.
  --pattern <pat>    Keys pattern when using the --scan, --bigkeys or --hotkeys
                     options (default: *).
  --quoted-pattern <pat> Same as --pattern, but the specified string can be
                         quoted, in order to pass an otherwise non binary-safe string.
  --intrinsic-latency <sec> Run a test to measure intrinsic system latency.
                     The test will run for the specified amount of seconds.
  --eval <file>      Send an EVAL command using the Lua script at <file>.
  --ldb              Used with --eval enable the Redis Lua debugger.
  --ldb-sync-mode    Like --ldb but uses the synchronous Lua debugger, in
                     this mode the server is blocked and script changes are
                     not rolled back from the server memory.
  --cluster <command> [args...] [opts...]
                     Cluster Manager command and arguments (see below).
  --verbose          Verbose mode.
  --no-auth-warning  Don't show warning message when using password on command
                     line interface.
  --help             Output this help and exit.
  --version          Output version and exit.

Cluster Manager Commands:
  Use --cluster help to list all available cluster manager commands.

Examples:
  cat /etc/passwd | redis-cli -x set mypasswd
  redis-cli get mypasswd
  redis-cli -r 100 lpush mylist x
  redis-cli -r 100 -i 1 info | grep used_memory_human:
  redis-cli --quoted-input set '"null-\x00-separated"' value
  redis-cli --eval myscript.lua key1 key2 , arg1 arg2 arg3
  redis-cli --scan --pattern '*:12345*'

  (Note: when using --eval the comma separates KEYS[] from ARGV[] items)

When no command is given, redis-cli starts in interactive mode.
Type "help" in interactive mode for information on available commands
and settings.

redis-stuff $ redis-cli --tls -h 142.93.221.126 -p 56679 
^C
redis-stuff $ redis-cli --tls -h redis-server-1.hosteddatabase.in -p 56679 
^C
redis-stuff $ redis-cli --tls -h redis-server-1.hosteddatabase.in -p 56680

I/O error
redis-server-1.hosteddatabase.in:56680> ping

I/O error
Error: Server closed the connection
redis-server-1.hosteddatabase.in:56680> ping
PONG
redis-server-1.hosteddatabase.in:56680> 
redis-stuff $ redis-cli --tls -h redis-server-1.hosteddatabase.in -p 56680
redis-server-1.hosteddatabase.in:56680> PING
PONG
redis-server-1.hosteddatabase.in:56680> 
redis-stuff $ redli
2021/11/04 00:24:40 Dial dial tcp 127.0.0.1:6379: connect: connection refused
redis-stuff $ redli --tls -h redis-server-1.hosteddatabase.in -a db376693cf0a9d38d571fb1d1d3be9f847f6ea0a736eadd8ceaa1de3fbdc9d44 -p 56679
^C
redis-stuff $ redli --tls -h redis-server-1.hosteddatabase.in -a db376693cf0a9d38d571fb1d1d3be9f847f6ea0a736eadd8ceaa1de3fbdc9d44 -p 56680
Connected to 6.2.6
> ping
PONG
> redis-stuff $ 
redis-stuff $ 
redis-stuff $ 
redis-stuff $ redli --help
usage: redli [<flags>] [<commands>...]

Flags:
      --help               Show context-sensitive help (also try --help-long and --help-man).
      --debug              Enable debug mode.
      --long               Enable long prompt with host/port
  -u, --uri=URI            URI to connect to
  -h, --host="127.0.0.1"   Host to connect to
  -p, --port=6379          Port to connect to
  -r, --redisuser=""       Username to use when connecting. Supported since Redis 6.
  -a, --auth=AUTH          Password to use when connecting
  -n, --ndb=0              Redis database to access
      --tls                Enable TLS/SSL
      --skipverify         Don't validate certificates
      --certfile=CERTFILE  Self-signed certificate file for validation
      --certb64=CERTB64    Self-signed certificate string as base64 for validation
      --raw                Produce raw output
      --eval=EVAL          Evaluate a Lua script file, follow with keys a , and args
      --version            Show application version.

Args:
  [<commands>]  Redis commands and values

redis-stuff $ 
```

---

```bash
root@redis-server:~# sudo certbot certonly --standalone --hekp
usage: 
  certbot [SUBCOMMAND] [options] [-d DOMAIN] [-d DOMAIN] ...

Certbot can obtain and install HTTPS/TLS/SSL certificates.  By default,
it will attempt to use a webserver both for obtaining and installing the
certificate. 
certbot: error: unrecognized arguments: --hekp
root@redis-server:~# sudo certbot certonly --standalone --help

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  certbot [SUBCOMMAND] [options] [-d DOMAIN] [-d DOMAIN] ...

Certbot can obtain and install HTTPS/TLS/SSL certificates.  By default,
it will attempt to use a webserver both for obtaining and installing the
certificate. The most common SUBCOMMANDS and flags are:

obtain, install, and renew certificates:
    (default) run   Obtain & install a certificate in your current webserver
    certonly        Obtain or renew a certificate, but do not install it
    renew           Renew all previously obtained certificates that are near
expiry
    enhance         Add security enhancements to your existing configuration
   -d DOMAINS       Comma-separated list of domains to obtain a certificate for

  --apache          Use the Apache plugin for authentication & installation
  --standalone      Run a standalone webserver for authentication
  --nginx           Use the Nginx plugin for authentication & installation
  --webroot         Place files in a server's webroot folder for authentication
  --manual          Obtain certificates interactively, or using shell script
hooks

   -n               Run non-interactively
  --test-cert       Obtain a test certificate from a staging server
  --dry-run         Test "renew" or "certonly" without saving any certificates
to disk

manage certificates:
    certificates    Display information about certificates you have from Certbot
    revoke          Revoke a certificate (supply --cert-name or --cert-path)
    delete          Delete a certificate (supply --cert-name)

manage your account:
    register        Create an ACME account
    unregister      Deactivate an ACME account
    update_account  Update an ACME account
  --agree-tos       Agree to the ACME server's Subscriber Agreement
   -m EMAIL         Email address for important account notifications

More detailed help:

  -h, --help [TOPIC]    print this message, or detailed help on a topic;
                        the available TOPICS are:

   all, automation, commands, paths, security, testing, or any of the
   subcommands or plugins (certonly, renew, install, register, nginx,
   apache, standalone, webroot, etc.)
  -h all                print a detailed help page including all topics
  --version             print the version number
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
root@redis-server:~# sudo certbot certonly --standalone --help automation
usage: 
  certbot [SUBCOMMAND] [options] [-d DOMAIN] [-d DOMAIN] ...

Certbot can obtain and install HTTPS/TLS/SSL certificates.  By default,
it will attempt to use a webserver both for obtaining and installing the
certificate. 

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG_FILE, --config CONFIG_FILE
                        path to config file (default: /etc/letsencrypt/cli.ini and ~/.config/letsencrypt/cli.ini)

automation:
  Flags for automating execution & other tweaks

  -n, --non-interactive, --noninteractive
                        Run without ever asking for user input. This may require additional command line flags; the client
                        will try to explain which ones are required if it finds one missing (default: False)
  --register-unsafely-without-email
                        Specifying this flag enables registering an account with no email address. This is strongly
                        discouraged, because you will be unable to receive notice about impending expiration or revocation
                        of your certificates or problems with your Certbot installation that will lead to failure to renew.
                        (default: False)
  -m EMAIL, --email EMAIL
                        Email used for registration and recovery contact. Use comma to register multiple emails, ex:
                        u1@example.com,u2@example.com. (default: Ask).
  --eff-email           Share your e-mail address with EFF (default: None)
  --no-eff-email        Don't share your e-mail address with EFF (default: None)
  --keep-until-expiring, --keep, --reinstall
                        If the requested certificate matches an existing certificate, always keep the existing one until it
                        is due for renewal (for the 'run' subcommand this means reinstall the existing certificate).
                        (default: Ask)
  --expand              If an existing certificate is a strict subset of the requested names, always expand and replace it
                        with the additional names. (default: Ask)
  --version             show program's version number and exit
  --force-renewal, --renew-by-default
                        If a certificate already exists for the requested domains, renew it now, regardless of whether it is
                        near expiry. (Often --keep-until-expiring is more appropriate). Also implies --expand. (default:
                        False)
  --renew-with-new-domains
                        If a certificate already exists for the requested certificate name but does not match the requested
                        domains, renew it now, regardless of whether it is near expiry. (default: False)
  --reuse-key           When renewing, use the same private key as the existing certificate. (default: False)
  --no-reuse-key        When renewing, do not use the same private key as the existing certificate. Not reusing private keys
                        is the default behavior of Certbot. This option may be used to unset --reuse-key on an existing
                        certificate. (default: False)
  --allow-subset-of-names
                        When performing domain validation, do not consider it a failure if authorizations can not be
                        obtained for a strict subset of the requested domains. This may be useful for allowing renewals for
                        multiple domains to succeed even if some domains no longer point at this system. This option cannot
                        be used with --csr. (default: False)
  --agree-tos           Agree to the ACME Subscriber Agreement (default: Ask)
  --account ACCOUNT_ID  Account ID to use (default: None)
  --duplicate           Allow making a certificate lineage that duplicates an existing one (both can be renewed in parallel)
                        (default: False)
  -q, --quiet           Silence all output except errors. Useful for automation via cron. Implies --non-interactive.
                        (default: False)
root@redis-server:~# sudo certbot certonly --standalone --non-interactive
Saving debug log to /var/log/letsencrypt/letsencrypt.log
You should register before running non-interactively, or provide --agree-tos and --email <email_address> flags.
Ask for help or search for solutions at https://community.letsencrypt.org. See the logfile /var/log/letsencrypt/letsencrypt.log or re-run Certbot with -v for more details.
root@redis-server:~# sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Account registered.
Missing command line flag or config entry for this setting:
Please enter the domain name(s) you would like on your certificate (comma and/or space separated)

(You can set this with the --domains flag)
Ask for help or search for solutions at https://community.letsencrypt.org. See the logfile /var/log/letsencrypt/letsencrypt.log or re-run Certbot with -v for more details.
root@redis-server:~# sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for redis-server-1.hosteddatabase.in

Certbot failed to authenticate some domains (authenticator: standalone). The Certificate Authority reported these problems:
  Domain: redis-server-1.hosteddatabase.in
  Type:   dns
  Detail: DNS problem: NXDOMAIN looking up A for redis-server-1.hosteddatabase.in - check that a DNS record exists for this domain

Hint: The Certificate Authority failed to download the challenge files from the temporary standalone webserver started by Certbot on port 80. Ensure that the listed domains point to this machine and that it can accept inbound connections from the internet.

Some challenges have failed.
Ask for help or search for solutions at https://community.letsencrypt.org. See the logfile /var/log/letsencrypt/letsencrypt.log or re-run Certbot with -v for more details.
root@redis-server:~# sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for redis-server-1.hosteddatabase.in

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
This certificate expires on 2022-02-12.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
root@redis-server:~# 
```

---

[TODO]
- Learn how certificate rotation works and force a certificate rotation and see if Redis Server picks up the new certificate - this can happen when certificate is going to expire or when IP address of the Redis Server changes. IP address change is big - we might just get a new SSL certificate I guess, it doesn't make sense to call it a certificate rotation!

---

```bash
root@redis-server:~# ./run-redis.sh 
./run-redis.sh: line 7: $1: unbound variable
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com
./run-redis.sh: line 8: $2: unbound variable
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 139.59.20.169 56380
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Get:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease [114 kB]                                        
Hit:3 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                        
Get:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease [101 kB]                                      
Get:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease [18.0 kB]
Get:6 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]                  
Get:7 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 Packages [1344 kB]
Get:8 http://mirrors.digitalocean.com/ubuntu focal-updates/main Translation-en [276 kB]
Get:9 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 c-n-f Metadata [14.5 kB]  
Get:10 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 Packages [569 kB]
Get:11 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted Translation-en [81.6 kB]                      
Get:12 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [528 B]   
Get:13 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 Packages [1016 B]
Get:14 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 Packages [875 kB]
Get:15 http://mirrors.digitalocean.com/ubuntu focal-updates/universe Translation-en [189 kB]               
Get:16 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [19.5 kB]              
Get:17 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main Translation-en [584 B]                       
Get:18 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 Packages [24.5 kB]                
Get:19 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse Translation-en [6856 B]
Get:20 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [987 kB]
Get:21 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 c-n-f Metadata [616 B]
Get:22 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 Packages [6592 B]
Get:23 http://mirrors.digitalocean.com/ubuntu focal-backports/universe Translation-en [3292 B]
Get:24 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 c-n-f Metadata [580 B]
Get:25 http://security.ubuntu.com/ubuntu focal-security/main Translation-en [183 kB]
Get:26 http://security.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [8880 B]
Get:27 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [526 kB]
Get:28 http://security.ubuntu.com/ubuntu focal-security/restricted Translation-en [75.4 kB]
Get:29 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 c-n-f Metadata [528 B]
Get:30 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [651 kB]
Get:31 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [107 kB]
Get:32 http://security.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [12.9 kB]
Get:33 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [21.9 kB]
Get:34 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 c-n-f Metadata [540 B]
Fetched 6333 kB in 3s (1872 kB/s)                
Reading package lists... Done
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  redis-tools
Suggested packages:
  ruby-redis
The following NEW packages will be installed:
  redis-server redis-tools
0 upgraded, 2 newly installed, 0 to remove and 29 not upgraded.
Need to get 1150 kB of archives.
After this operation, 6794 kB of additional disk space will be used.
Get:1 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-tools amd64 6:6.2.6-1rl1~focal1 [1067 kB]
Get:2 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-server amd64 6:6.2.6-1rl1~focal1 [82.4 kB]
Fetched 1150 kB in 2s (570 kB/s)   
Selecting previously unselected package redis-tools.
(Reading database ... 63555 files and directories currently installed.)
Preparing to unpack .../redis-tools_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-tools (6:6.2.6-1rl1~focal1) ...
Selecting previously unselected package redis-server.
Preparing to unpack .../redis-server_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-server (6:6.2.6-1rl1~focal1) ...
Setting up redis-tools (6:6.2.6-1rl1~focal1) ...
Setting up redis-server (6:6.2.6-1rl1~focal1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-11-14 06:59:16 UTC; 57s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 3799 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.3M
     CGroup: /system.slice/redis-server.service
             └─3799 /usr/bin/redis-server 127.0.0.1:6379

Nov 14 06:59:16 redis-server systemd[1]: Starting Advanced key-value store...
Nov 14 06:59:16 redis-server systemd[1]: Started Advanced key-value store.
PONG
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:6379
server_time_usec:1636873214404646
uptime_in_seconds:58
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9483262
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
1) "requirepass"
2) ""
OK
1) "requirepass"
2) "88a323691f8122dbe5173c65db0f6223e1dab8e8132d843afad55be5449f3a8f"
OK
root@redis-server:~# 
root@redis-server:~# sudo snap install --classic certbot;
snap "certbot" is already installed, see 'snap help refresh'
root@redis-server:~# echo $?
0
root@redis-server:~# sudo ln -s /snap/bin/certbot /usr/bin/certbot;
ln: failed to create symbolic link '/usr/bin/certbot': File exists
root@redis-server:~# echo $?
1
root@redis-server:~# sudo ln -f -s /snap/bin/certbot /usr/bin/certbot;
root@redis-server:~# man ln
root@redis-server:~# sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot;
root@redis-server:~# add-apt-repository ppa:redislabs/redis --yes;
Hit:1 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal InRelease                                                         
Hit:3 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease                                                 
Hit:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease                                
Hit:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease                            
Hit:6 http://security.ubuntu.com/ubuntu focal-security InRelease
Reading package lists... Done
root@redis-server:~# echo $?
0
root@redis-server:~# apt install redis-server --yes;
Reading package lists... Done
Building dependency tree       
Reading state information... Done
redis-server is already the newest version (6:6.2.6-1rl1~focal1).
0 upgraded, 0 newly installed, 0 to remove and 29 not upgraded.
root@redis-server:~# echo $?
0
root@redis-server:~# 
```

```bash
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 139.59.20.169 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=139.59.20.169
+ port=56380
+ [[ -z karuppiah7890@gmail.com ]]
+ [[ -z redis-server-1.hosteddatabase.in ]]
+ [[ -z 139.59.20.169 ]]
+ [[ -z 56380 ]]
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease                                                 
Hit:3 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease                                               
Hit:4 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                        
Hit:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease                            
Hit:6 http://security.ubuntu.com/ubuntu focal-security InRelease           
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
redis-server is already the newest version (6:6.2.6-1rl1~focal1).
0 upgraded, 0 newly installed, 0 to remove and 29 not upgraded.
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-11-14 06:59:16 UTC; 7min ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 3799 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.5M
     CGroup: /system.slice/redis-server.service
             └─3799 /usr/bin/redis-server 127.0.0.1:6379

Nov 14 06:59:16 redis-server systemd[1]: Starting Advanced key-value store...
Nov 14 06:59:16 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:6379
server_time_usec:1636873613395539
uptime_in_seconds:457
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9483661
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "88a323691f8122dbe5173c65db0f6223e1dab8e8132d843afad55be5449f3a8f"
+ redis-cli -e CONFIG SET requirepass 192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594
OK
+ export REDISCLI_AUTH=192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594
+ REDISCLI_AUTH=192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass 192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594'
+ cat /etc/redis/redis.conf
root@redis-server:~# cat /etc/redis/redis.conf | grep 'requirepass 192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594'
root@redis-server:~# echo $?
1
root@redis-server:~# cat /etc/redis/redis.conf | grep 'requirepass "192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594"'
requirepass "192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594"
root@redis-server:~# cat /etc/redis/redis.conf | grep 'bind'
# By default, if no "bind" configuration directive is specified, Redis listens
# the "bind" configuration directive, followed by one or more IP addresses.
# bind 192.168.1.100 10.0.0.1     # listens on two specific IPv4 addresses
# bind 127.0.0.1 ::1              # listens on loopback IPv4 and IPv6
# bind * -::*                     # like the default, all available interfaces
# internet, binding to all the interfaces is dangerous and will expose the
# following bind directive, that will force Redis to listen only on the
bind 127.0.0.1 -::1
# 1) The server is not binding explicitly to a set of addresses using the
#    "bind" directive.
# are explicitly listed using the "bind" directive.
root@redis-server:~# 
```

```bash
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 139.59.20.169 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=139.59.20.169
+ port=56380
+ [[ -z karuppiah7890@gmail.com ]]
+ [[ -z redis-server-1.hosteddatabase.in ]]
+ [[ -z 139.59.20.169 ]]
+ [[ -z 56380 ]]
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease                                                 
Hit:3 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease                                               
Hit:4 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                        
Hit:5 http://security.ubuntu.com/ubuntu focal-security InRelease    
Hit:6 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
redis-server is already the newest version (6:6.2.6-1rl1~focal1).
0 upgraded, 0 newly installed, 0 to remove and 29 not upgraded.
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-11-14 06:59:16 UTC; 9min ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 3799 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.8M
     CGroup: /system.slice/redis-server.service
             └─3799 /usr/bin/redis-server 127.0.0.1:6379

Nov 14 06:59:16 redis-server systemd[1]: Starting Advanced key-value store...
Nov 14 06:59:16 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:6379
server_time_usec:1636873747287020
uptime_in_seconds:591
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9483795
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "192e55ddf80afb981ba6bfd615cddbebf52d3acafc4693f6446ece449fe19594"
+ redis-cli -e CONFIG SET requirepass c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669
OK
+ export REDISCLI_AUTH=c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669
+ REDISCLI_AUTH=c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass "c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669"'
+ cat /etc/redis/redis.conf
requirepass "c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669"
+ install_certbot
+ sudo snap install --classic certbot
snap "certbot" is already installed, see 'snap help refresh'
+ sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot
+ obtain_ssl_certificate
+ sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Certificate not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Certificate not yet due for renewal; no action taken.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
+ give_redis_user_access_to_ssl_certificate
+ chown -R redis:redis /etc/letsencrypt/
+ configure_tls
+ configure_private_key
+ private_key_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) ""
+ redis-cli -e CONFIG SET tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
OK
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem'
+ cat /etc/redis/redis.conf
root@redis-server:~# cat /etc/redis/redis.conf | grep 'tls-key-file'
# tls-key-file redis.key
# tls-key-file-pass secret
tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
root@redis-server:~# 
```

```bash
root@redis-server:~# export REDISCLI_AUTH=c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 139.59.20.169 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=139.59.20.169
+ port=56380
+ [[ -z karuppiah7890@gmail.com ]]
+ [[ -z redis-server-1.hosteddatabase.in ]]
+ [[ -z 139.59.20.169 ]]
+ [[ -z 56380 ]]
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease                                                 
Hit:3 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                        
Hit:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease                                               
Hit:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease                            
Hit:6 http://security.ubuntu.com/ubuntu focal-security InRelease
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
redis-server is already the newest version (6:6.2.6-1rl1~focal1).
0 upgraded, 0 newly installed, 0 to remove and 29 not upgraded.
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-11-14 06:59:16 UTC; 11min ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 3799 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.8M
     CGroup: /system.slice/redis-server.service
             └─3799 /usr/bin/redis-server 127.0.0.1:6379

Nov 14 06:59:16 redis-server systemd[1]: Starting Advanced key-value store...
Nov 14 06:59:16 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:6379
server_time_usec:1636873871520907
uptime_in_seconds:715
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9483919
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "c87af88879be95c425eeecc24517c30f47a37fea558b9117cd5fe791ac873669"
+ redis-cli -e CONFIG SET requirepass 77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487
OK
+ export REDISCLI_AUTH=77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487
+ REDISCLI_AUTH=77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass "77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487"'
+ cat /etc/redis/redis.conf
requirepass "77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487"
+ install_certbot
+ sudo snap install --classic certbot
snap "certbot" is already installed, see 'snap help refresh'
+ sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot
+ obtain_ssl_certificate
+ sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Certificate not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Certificate not yet due for renewal; no action taken.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
+ give_redis_user_access_to_ssl_certificate
+ chown -R redis:redis /etc/letsencrypt/
+ configure_tls
+ configure_private_key
+ private_key_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG SET tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
OK
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"'
+ cat /etc/redis/redis.conf
tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ configure_ssl_certificate
+ ssl_certificate_path=/etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) ""
+ redis-cli -e CONFIG SET tls-cert-file /etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem
OK
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-cert-file "/etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem"'
+ cat /etc/redis/redis.conf
tls-cert-file "/etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem"
+ disable_tls_auth
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "yes"
+ redis-cli -e CONFIG SET tls-auth-clients no
OK
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-auth-clients no'
+ cat /etc/redis/redis.conf
# tls-auth-clients no
tls-auth-clients no
+ configure_tls_port
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "0"
+ redis-cli -e CONFIG SET tls-port 56380
ERR Invalid argument '56380' for CONFIG SET 'tls-port' - Unable to update TLS configuration. Check server logs.
root@redis-server:~# cat /var/log/redis/redis-server.log 
3799:C 14 Nov 2021 06:59:16.931 * Supervised by systemd. Please make sure you set appropriate values for TimeoutStartSec and TimeoutStopSec in your service unit.
3799:C 14 Nov 2021 06:59:16.931 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
3799:C 14 Nov 2021 06:59:16.931 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=3799, just started
3799:C 14 Nov 2021 06:59:16.931 # Configuration loaded
3799:M 14 Nov 2021 06:59:16.932 * monotonic clock: POSIX clock_gettime
3799:M 14 Nov 2021 06:59:16.939 * Running mode=standalone, port=6379.
3799:M 14 Nov 2021 06:59:16.939 # Server initialized
3799:M 14 Nov 2021 06:59:16.939 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
3799:M 14 Nov 2021 06:59:16.942 * Ready to accept connections
3799:M 14 Nov 2021 07:00:14.437 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:06:53.437 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:09:07.319 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:09:10.056 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:11:11.551 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:11:13.813 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:11:13.849 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:11:13.879 # CONFIG REWRITE executed with success.
3799:M 14 Nov 2021 07:11:13.890 # Failed to load certificate: /etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem: error:02001002:system library:fopen:No such file or directory
root@redis-server:~# 
```

```bash
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 139.59.20.169 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=139.59.20.169
+ port=56380
+ [[ -z karuppiah7890@gmail.com ]]
+ [[ -z redis-server-1.hosteddatabase.in ]]
+ [[ -z 139.59.20.169 ]]
+ [[ -z 56380 ]]
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease                                                 
Hit:3 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease                                               
Hit:4 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                        
Hit:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease
Hit:6 http://security.ubuntu.com/ubuntu focal-security InRelease
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
redis-server is already the newest version (6:6.2.6-1rl1~focal1).
0 upgraded, 0 newly installed, 0 to remove and 29 not upgraded.
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-11-14 06:59:16 UTC; 14min ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 3799 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.7M
     CGroup: /system.slice/redis-server.service
             └─3799 /usr/bin/redis-server 127.0.0.1:6379

Nov 14 06:59:16 redis-server systemd[1]: Starting Advanced key-value store...
Nov 14 06:59:16 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:6379
server_time_usec:1636874054478261
uptime_in_seconds:898
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9484102
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "77dad123bec77ebc1c21aa684c57481994543eff4d5f9ef6fab317247ac23487"
+ redis-cli -e CONFIG SET requirepass 23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4
OK
+ export REDISCLI_AUTH=23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4
+ REDISCLI_AUTH=23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass "23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4"'
+ cat /etc/redis/redis.conf
requirepass "23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4"
+ install_certbot
+ sudo snap install --classic certbot
snap "certbot" is already installed, see 'snap help refresh'
+ sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot
+ obtain_ssl_certificate
+ sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Certificate not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Certificate not yet due for renewal; no action taken.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
+ give_redis_user_access_to_ssl_certificate
+ chown -R redis:redis /etc/letsencrypt/
+ configure_tls
+ configure_private_key
+ private_key_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG SET tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
OK
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"'
+ cat /etc/redis/redis.conf
tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ configure_ssl_certificate
+ ssl_certificate_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG SET tls-cert-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
OK
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"'
+ cat /etc/redis/redis.conf
tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ disable_tls_auth
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG SET tls-auth-clients no
OK
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-auth-clients no'
+ cat /etc/redis/redis.conf
# tls-auth-clients no
tls-auth-clients no
+ configure_tls_port
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "0"
+ redis-cli -e CONFIG SET tls-port 56380
OK
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "56380"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-port 56380'
+ cat /etc/redis/redis.conf
tls-port 56380
+ disable_non_tls_port
+ redis-cli -e -p 56380 CONFIG GET port

I/O error
root@redis-server:~# 
```

```bash
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 139.59.20.169 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=139.59.20.169
+ tls_port=56380
+ [[ -z karuppiah7890@gmail.com ]]
+ [[ -z redis-server-1.hosteddatabase.in ]]
+ [[ -z 139.59.20.169 ]]
+ [[ -z 56380 ]]
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal InRelease                                                         
Hit:3 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease                                                 
Hit:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease                           
Hit:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease                            
Hit:6 http://security.ubuntu.com/ubuntu focal-security InRelease
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
redis-server is already the newest version (6:6.2.6-1rl1~focal1).
0 upgraded, 0 newly installed, 0 to remove and 29 not upgraded.
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-11-14 06:59:16 UTC; 18min ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 3799 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 3.0M
     CGroup: /system.slice/redis-server.service
             └─3799 /usr/bin/redis-server 127.0.0.1:6379

Nov 14 06:59:16 redis-server systemd[1]: Starting Advanced key-value store...
Nov 14 06:59:16 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:6379
server_time_usec:1636874261683203
uptime_in_seconds:1105
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9484309
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "23c88af01d40347e5c7f25358837ed0dc89eb24d049c81f59648576fb73232d4"
+ redis-cli -e CONFIG SET requirepass e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6
OK
+ export REDISCLI_AUTH=e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6
+ REDISCLI_AUTH=e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass "e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6"'
+ cat /etc/redis/redis.conf
requirepass "e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6"
+ install_certbot
+ sudo snap install --classic certbot
snap "certbot" is already installed, see 'snap help refresh'
+ sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot
+ obtain_ssl_certificate
+ sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Certificate not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Certificate not yet due for renewal; no action taken.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
+ give_redis_user_access_to_ssl_certificate
+ chown -R redis:redis /etc/letsencrypt/
+ configure_tls
+ configure_private_key
+ private_key_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG SET tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
OK
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"'
+ cat /etc/redis/redis.conf
tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ configure_ssl_certificate
+ ssl_certificate_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG SET tls-cert-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
OK
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"'
+ cat /etc/redis/redis.conf
tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ disable_tls_auth
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG SET tls-auth-clients no
OK
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-auth-clients no'
+ cat /etc/redis/redis.conf
# tls-auth-clients no
tls-auth-clients no
+ configure_tls_port
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "56380"
+ redis-cli -e CONFIG SET tls-port 56380
OK
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "56380"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-port 56380'
+ cat /etc/redis/redis.conf
tls-port 56380
+ disable_non_tls_port
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "6379"
+ redis-cli -e --tls -p 56380 CONFIG SET port 0
OK
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "0"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'port 0'
+ cat /etc/redis/redis.conf
# If port 0 is specified Redis will not listen on a TCP socket.
port 0
# port 0
# cluster-announce-port 0
+ configure_bind
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG SET bind '139.59.20.169 127.0.0.1 -::1'
OK
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "139.59.20.169 127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'bind 139.59.20.169 127.0.0.1 -::1'
+ cat /etc/redis/redis.conf
bind 139.59.20.169 127.0.0.1 -::1
root@redis-server:~# echo $?
0
root@redis-server:~# 
```

```bash
database-stuff $ redis-cli --tls -h redis-server-1.hosteddatabase.in -p 56380
redis-server-1.hosteddatabase.in:56380> ping
(error) NOAUTH Authentication required.
redis-server-1.hosteddatabase.in:56380> 
database-stuff $ export REDISCLI_AUTH=e83b917b94b91cfce235737a669a4e47ab62cbb84bcd072d84529fb3d3a702f6
database-stuff $ redis-cli --tls -h redis-server-1.hosteddatabase.in -p 56380
redis-server-1.hosteddatabase.in:56380> ping
PONG
redis-server-1.hosteddatabase.in:56380> info server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:56380
server_time_usec:1636874346711666
uptime_in_seconds:1190
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9484394
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
redis-server-1.hosteddatabase.in:56380> 
database-stuff $ redli --tls -h redis-server-1.hosteddatabase.in -p 56380
2021/11/14 12:49:13 NOAUTH Authentication required.
database-stuff $ redli --tls -h redis-server-1.hosteddatabase.in -p 56380 -a ${REDISCLI_AUTH}
Connected to 6.2.6
> info server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:56380
server_time_usec:1636874371206830
uptime_in_seconds:1215
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9484419
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0

> database-stuff $ redl-h redis-server-1.hosteddatabase.in -p 56380 -a ${REDISCLI_AUTH}
database-stuff $ redli -h redis-server-1.hosteddatabase.in -p 56380 -a ${REDISCLI_AUTH}
2021/11/14 12:49:42 Dial read tcp 192.168.1.6:50349->139.59.20.169:56380: read: connection reset by peer
database-stuff $ 
```

```bash
database-stuff $ redli -h 139.59.20.169 -p 56380 -a ${REDISCLI_AUTH}
2021/11/14 12:50:07 Dial read tcp 192.168.1.6:50354->139.59.20.169:56380: read: connection reset by peer
database-stuff $ 
database-stuff $ redli --tls -h 139.59.20.169 -p 56380 -a ${REDISCLI_AUTH}
2021/11/14 12:50:10 Dial x509: cannot validate certificate for 139.59.20.169 because it doesn't contain any IP SANs
database-stuff $ redli -h
redli: error: expected argument for flag '-h', try --help
database-stuff $ redli --help
usage: redli [<flags>] [<commands>...]

Flags:
      --help               Show context-sensitive help (also try --help-long and --help-man).
      --debug              Enable debug mode.
      --long               Enable long prompt with host/port
  -u, --uri=URI            URI to connect to
  -h, --host="127.0.0.1"   Host to connect to
  -p, --port=6379          Port to connect to
  -r, --redisuser=""       Username to use when connecting. Supported since Redis 6.
  -a, --auth=AUTH          Password to use when connecting
  -n, --ndb=0              Redis database to access
      --tls                Enable TLS/SSL
      --skipverify         Don't validate certificates
      --certfile=CERTFILE  Self-signed certificate file for validation
      --certb64=CERTB64    Self-signed certificate string as base64 for validation
      --raw                Produce raw output
      --eval=EVAL          Evaluate a Lua script file, follow with keys a , and args
      --version            Show application version.

Args:
  [<commands>]  Redis commands and values

database-stuff $ redli --skipverify --tls -h 139.59.20.169 -p 56380 -a ${REDISCLI_AUTH}
Connected to 6.2.6
> info server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:3799
process_supervised:systemd
run_id:9c42dc48ea4c192020d9c5f197671d21d21d1b3e
tcp_port:56380
server_time_usec:1636874427867919
uptime_in_seconds:1271
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9484475
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0

> database-stuff $ 
```

```bash
~ $ doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait

ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
273627780    redis-server    159.65.146.158    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
~ $ 
~ $ ssh -i ~/.ssh/digital_ocean root@159.65.146.158









~ $ ssh -i ~/.ssh/digital_ocean root@159.65.146.158
The authenticity of host '159.65.146.158 (159.65.146.158)' can't be established.
ECDSA key fingerprint is SHA256:E76ymyZB7cwS9ATciTknf9wLnvcWo5w7VTmJ6FWSaCk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '159.65.146.158' (ECDSA) to the list of known hosts.
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun Nov 14 10:19:50 UTC 2021

  System load:  0.2               Users logged in:       0
  Usage of /:   6.0% of 24.06GB   IPv4 address for eth0: 159.65.146.158
  Memory usage: 19%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    106

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@redis-server:~# 


root@redis-server:~# wget https://gist.githubusercontent.com/karuppiah7890/fc8fca5e3bdeafbf8072ee656141de7c/raw/e8d4533d8f9eff8b5136332644dcb81e64727ff7/run-redis.sh
--2021-11-14 10:20:17--  https://gist.githubusercontent.com/karuppiah7890/fc8fca5e3bdeafbf8072ee656141de7c/raw/e8d4533d8f9eff8b5136332644dcb81e64727ff7/run-redis.sh
Resolving gist.githubusercontent.com (gist.githubusercontent.com)... 185.199.110.133, 185.199.108.133, 185.199.109.133, ...
Connecting to gist.githubusercontent.com (gist.githubusercontent.com)|185.199.110.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 4376 (4.3K) [text/plain]
Saving to: ‘run-redis.sh’

run-redis.sh                  100%[==============================================>]   4.27K  --.-KB/s    in 0s      

2021-11-14 10:20:18 (37.2 MB/s) - ‘run-redis.sh’ saved [4376/4376]

root@redis-server:~# 




root@redis-server:~# ls
run-redis.sh  snap
root@redis-server:~# 


root@redis-server:~# chmod +x run-redis.sh
root@redis-server:~# ls -l
total 12
-rwxr-xr-x 1 root root 4376 Nov 14 10:20 run-redis.sh
drwxr-xr-x 3 root root 4096 Nov 14 10:18 snap
root@redis-server:~# root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 159.65.146.158 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=159.65.146.158
+ tls_port=56380
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Get:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease [114 kB]                                       
Hit:3 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                       
Get:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease [101 kB]                                     
Get:5 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]    
Get:6 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease [18.0 kB]           
Get:7 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 Packages [1344 kB]             
Get:8 http://mirrors.digitalocean.com/ubuntu focal-updates/main Translation-en [276 kB]                             
Get:9 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 Packages [1016 B]                       
Get:10 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 c-n-f Metadata [14.5 kB]
Get:11 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 Packages [569 kB]                    
Get:12 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main Translation-en [584 B]                      
Get:13 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [987 kB]   
Get:14 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted Translation-en [81.6 kB]
Get:15 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [528 B]
Get:16 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 Packages [875 kB]
Get:17 http://mirrors.digitalocean.com/ubuntu focal-updates/universe Translation-en [189 kB]
Get:18 http://security.ubuntu.com/ubuntu focal-security/main Translation-en [183 kB]   
Get:19 http://security.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [8880 B]
Get:20 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [526 kB]
Get:21 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [19.5 kB]
Get:22 http://security.ubuntu.com/ubuntu focal-security/restricted Translation-en [75.4 kB]        
Get:23 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 c-n-f Metadata [528 B]            
Get:24 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [651 kB] 
Get:25 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 Packages [24.5 kB]
Get:26 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [107 kB]     
Get:27 http://security.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [12.9 kB]
Get:28 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [21.9 kB]
Get:29 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 c-n-f Metadata [540 B]
Get:30 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse Translation-en [6856 B]
Get:31 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 c-n-f Metadata [616 B]
Get:32 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 Packages [6592 B]
Get:33 http://mirrors.digitalocean.com/ubuntu focal-backports/universe Translation-en [3292 B]
Get:34 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 c-n-f Metadata [580 B]
Fetched 6333 kB in 3s (2311 kB/s)                
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  redis-tools
Suggested packages:
  ruby-redis
The following NEW packages will be installed:
  redis-server redis-tools
0 upgraded, 2 newly installed, 0 to remove and 29 not upgraded.
Need to get 1150 kB of archives.
After this operation, 6794 kB of additional disk space will be used.
Get:1 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-tools amd64 6:6.2.6-1rl1~focal1 [1067 kB]
Get:2 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-server amd64 6:6.2.6-1rl1~focal1 [82.4 kB]
Fetched 1150 kB in 2s (578 kB/s)   
Selecting previously unselected package redis-tools.
(Reading database ... 63555 files and directories currently installed.)
Preparing to unpack .../redis-tools_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-tools (6:6.2.6-1rl1~focal1) ...
Selecting previously unselected package redis-server.
Preparing to unpack .../redis-server_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-server (6:6.2.6-1rl1~focal1) ...
Setting up redis-tools (6:6.2.6-1rl1~focal1) ...
Setting up redis-server (6:6.2.6-1rl1~focal1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-11-14 10:21:01 UTC; 3s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 2410 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.2M
     CGroup: /system.slice/redis-server.service
             └─2410 /usr/bin/redis-server 127.0.0.1:6379

Nov 14 10:21:01 redis-server systemd[1]: Starting Advanced key-value store...
Nov 14 10:21:01 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:2410
process_supervised:systemd
run_id:a75f3813405ec448c7759c7c567f1ad866f93675
tcp_port:6379
server_time_usec:1636885265344041
uptime_in_seconds:4
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9495313
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) ""
+ redis-cli -e CONFIG SET requirepass 20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4
OK
+ export REDISCLI_AUTH=20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4
+ REDISCLI_AUTH=20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass "20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4"'
+ cat /etc/redis/redis.conf
requirepass "20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4"
+ install_certbot
+ sudo snap install --classic certbot
certbot 1.21.0 from Certbot Project (certbot-eff✓) installed
+ sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot
+ obtain_ssl_certificate
+ sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Account registered.
Requesting a certificate for redis-server-1.hosteddatabase.in

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
This certificate expires on 2022-02-12.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
+ give_redis_user_access_to_ssl_certificate
+ chown -R redis:redis /etc/letsencrypt/
+ configure_tls
+ configure_private_key
+ private_key_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) ""
+ redis-cli -e CONFIG SET tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
OK
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"'
+ cat /etc/redis/redis.conf
tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ configure_ssl_certificate
+ ssl_certificate_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) ""
+ redis-cli -e CONFIG SET tls-cert-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
OK
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"'
+ cat /etc/redis/redis.conf
tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ disable_tls_auth
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "yes"
+ redis-cli -e CONFIG SET tls-auth-clients no
OK
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-auth-clients no'
+ cat /etc/redis/redis.conf
# tls-auth-clients no
tls-auth-clients no
+ configure_tls_port
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "0"
+ redis-cli -e CONFIG SET tls-port 56380
OK
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "56380"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-port 56380'
+ cat /etc/redis/redis.conf
tls-port 56380
+ disable_non_tls_port
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "6379"
+ redis-cli -e --tls -p 56380 CONFIG SET port 0
OK
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "0"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'port 0'
+ cat /etc/redis/redis.conf
# If port 0 is specified Redis will not listen on a TCP socket.
port 0
# port 0
# cluster-announce-port 0
+ configure_bind
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG SET bind '159.65.146.158 127.0.0.1 -::1'
OK
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "159.65.146.158 127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'bind 159.65.146.158 127.0.0.1 -::1'
+ cat /etc/redis/redis.conf
bind 159.65.146.158 127.0.0.1 -::1
+ echo 'Redis has been installed and configured and is running with TLS support and password protection!!'
Redis has been installed and configured and is running with TLS support and password protection!!
+ echo -e '\nConnection details - '

Connection details - 
+ echo 'Username - No user name'
Username - No user name
+ echo 'Password - 20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4'
Password - 20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4
+ echo 'Host - redis-server-1.hosteddatabase.in'
Host - redis-server-1.hosteddatabase.in
+ echo 'Port - 56380'
Port - 56380
+ echo -e '\nRedis CLI (redis-cli) command - '

Redis CLI (redis-cli) command - 
+ echo 'redis-cli --tls -h redis-server-1.hosteddatabase.in -a 20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4 -p 56380'
redis-cli --tls -h redis-server-1.hosteddatabase.in -a 20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4 -p 56380
root@redis-server:~# logout
Connection to 159.65.146.158 closed.
~ $ redis-cli --tls -h redis-server-1.hosteddatabase.in -a 20314d71ea7868294cf096928b8b685fda40409ea9bd6e379453503a0502aef4 -p 56380
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-server-1.hosteddatabase.in:56380> ping
PONG
redis-server-1.hosteddatabase.in:56380> info server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:2410
process_supervised:systemd
run_id:a75f3813405ec448c7759c7c567f1ad866f93675
tcp_port:56380
server_time_usec:1636885350109547
uptime_in_seconds:89
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9495398
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
redis-server-1.hosteddatabase.in:56380> keys *
(empty array)
redis-server-1.hosteddatabase.in:56380> 
~ $ 
```

---

```bash
Last login: Mon Nov 15 21:54:18 on ttys000
database-stuff $ curl ifconfig.me
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
273799523    redis-server    134.209.144.10    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ 
```

```bash
root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 134.209.144.10 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=134.209.144.10
+ tls_port=56380
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Get:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease [114 kB]                                                
Hit:3 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                                
Get:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease [101 kB]
Get:5 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]      
Get:6 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 Packages [1344 kB]                  
Get:7 http://mirrors.digitalocean.com/ubuntu focal-updates/main Translation-en [276 kB]                   
Get:8 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease [18.0 kB]                                       
Get:9 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 c-n-f Metadata [14.5 kB]                               
Get:10 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 Packages [569 kB]                               
Get:11 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted Translation-en [81.6 kB]
Get:12 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 Packages [1016 B]          
Get:13 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [528 B]
Get:14 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 Packages [875 kB]                                 
Get:15 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [987 kB]                      
Get:16 http://mirrors.digitalocean.com/ubuntu focal-updates/universe Translation-en [189 kB]                       
Get:17 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main Translation-en [584 B]                               
Get:18 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [19.5 kB]                    
Get:19 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 Packages [24.5 kB]
Get:20 http://security.ubuntu.com/ubuntu focal-security/main Translation-en [183 kB]
Get:21 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse Translation-en [6856 B]
Get:22 http://security.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [8880 B]
Get:23 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [526 kB]
Get:24 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 c-n-f Metadata [616 B]
Get:25 http://security.ubuntu.com/ubuntu focal-security/restricted Translation-en [75.4 kB]
Get:26 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 c-n-f Metadata [528 B]
Get:27 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [651 kB]     
Get:28 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 Packages [6592 B]
Get:29 http://mirrors.digitalocean.com/ubuntu focal-backports/universe Translation-en [3292 B]
Get:30 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [107 kB]
Get:31 http://security.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [12.9 kB]
Get:32 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [21.9 kB]
Get:33 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 c-n-f Metadata [540 B]
Get:34 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 c-n-f Metadata [580 B]
Fetched 4847 kB in 2s (2016 kB/s)                
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  redis-tools
Suggested packages:
  ruby-redis
The following NEW packages will be installed:
  redis-server redis-tools
0 upgraded, 2 newly installed, 0 to remove and 34 not upgraded.
Need to get 1150 kB of archives.
After this operation, 6794 kB of additional disk space will be used.
Get:1 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-tools amd64 6:6.2.6-1rl1~focal1 [1067 kB]
Get:2 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-server amd64 6:6.2.6-1rl1~focal1 [82.4 kB]
Fetched 1150 kB in 2s (585 kB/s)   
Selecting previously unselected package redis-tools.
(Reading database ... 63555 files and directories currently installed.)
Preparing to unpack .../redis-tools_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-tools (6:6.2.6-1rl1~focal1) ...
Selecting previously unselected package redis-server.
Preparing to unpack .../redis-server_6%3a6.2.6-1rl1~focal1_amd64.deb ...
Unpacking redis-server (6:6.2.6-1rl1~focal1) ...
Setting up redis-tools (6:6.2.6-1rl1~focal1) ...
Setting up redis-server (6:6.2.6-1rl1~focal1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-11-15 17:14:39 UTC; 42s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 2777 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.2M
     CGroup: /system.slice/redis-server.service
             └─2777 /usr/bin/redis-server 127.0.0.1:6379

Nov 15 17:14:39 redis-server systemd[1]: Starting Advanced key-value store...
Nov 15 17:14:39 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:e15ab29abece34d
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:2777
process_supervised:systemd
run_id:b02c018b407f274b5f3364d71f6cf3933e2b5c56
tcp_port:6379
server_time_usec:1636996521934879
uptime_in_seconds:42
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9606569
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) ""
+ redis-cli -e CONFIG SET requirepass 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347
OK
+ export REDISCLI_AUTH=09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347
+ REDISCLI_AUTH=09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass "09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347"'
+ cat /etc/redis/redis.conf
requirepass "09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347"
+ install_certbot
+ sudo snap install --classic certbot
certbot 1.21.0 from Certbot Project (certbot-eff✓) installed
+ sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot
+ obtain_ssl_certificate
+ sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Account registered.
Requesting a certificate for redis-server-1.hosteddatabase.in

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
This certificate expires on 2022-02-13.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
+ give_redis_user_access_to_ssl_certificate
+ chown -R redis:redis /etc/letsencrypt/
+ configure_tls
+ configure_private_key
+ private_key_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) ""
+ redis-cli -e CONFIG SET tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
OK
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"'
+ cat /etc/redis/redis.conf
tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ configure_ssl_certificate
+ ssl_certificate_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) ""
+ redis-cli -e CONFIG SET tls-cert-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
OK
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"'
+ cat /etc/redis/redis.conf
tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ disable_tls_auth
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "yes"
+ redis-cli -e CONFIG SET tls-auth-clients no
OK
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-auth-clients no'
+ cat /etc/redis/redis.conf
# tls-auth-clients no
tls-auth-clients no
+ configure_tls_port
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "0"
+ redis-cli -e CONFIG SET tls-port 56380
OK
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "56380"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-port 56380'
+ cat /etc/redis/redis.conf
tls-port 56380
+ disable_non_tls_port
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "6379"
+ redis-cli -e --tls -p 56380 CONFIG SET port 0
OK
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "0"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'port 0'
+ cat /etc/redis/redis.conf
# If port 0 is specified Redis will not listen on a TCP socket.
port 0
# port 0
# cluster-announce-port 0
+ configure_bind
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG SET bind '134.209.144.10 127.0.0.1 -::1'
OK
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "134.209.144.10 127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'bind 134.209.144.10 127.0.0.1 -::1'
+ cat /etc/redis/redis.conf
bind 134.209.144.10 127.0.0.1 -::1
+ echo 'Redis has been installed and configured and is running with TLS support and password protection!!'
Redis has been installed and configured and is running with TLS support and password protection!!
+ echo -e '\nConnection details - '

Connection details - 
+ echo 'Username - No user name'
Username - No user name
+ echo 'Password - 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347'
Password - 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347
+ echo 'Host - redis-server-1.hosteddatabase.in'
Host - redis-server-1.hosteddatabase.in
+ echo 'Port - 56380'
Port - 56380
+ echo -e '\nRedis CLI (redis-cli) command - '

Redis CLI (redis-cli) command - 
+ echo 'redis-cli --tls -h redis-server-1.hosteddatabase.in -a 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347 -p 56380'
redis-cli --tls -h redis-server-1.hosteddatabase.in -a 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347 -p 56380
root@redis-server:~# client_loop: send disconnect: Broken pipe
database-stuff $ redis-cli --tls -h redis-server-1.hosteddatabase.in -a 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347 -p 56380
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-server-1.hosteddatabase.in:56380> 
database-stuff $ ssh -i ~/.ssh/digital_ocean root@134.209.144.10
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon Nov 15 18:17:59 UTC 2021

  System load:  0.0               Users logged in:       1
  Usage of /:   6.2% of 24.06GB   IPv4 address for eth0: 134.209.144.10
  Memory usage: 22%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    110

36 updates can be applied immediately.
23 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable


Last login: Mon Nov 15 17:13:27 2021 from 27.5.194.196
root@redis-server:~# redis-cli --tls -h redis-server-1.hosteddatabase.in -a 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347 -p 56380
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-server-1.hosteddatabase.in:56380> ping
PONG
redis-server-1.hosteddatabase.in:56380> 
root@redis-server:~# ifconfig

Command 'ifconfig' not found, but can be installed with:

apt install net-tools

root@redis-server:~# apt install net-tools
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  net-tools
0 upgraded, 1 newly installed, 0 to remove and 34 not upgraded.
Need to get 196 kB of archives.
After this operation, 864 kB of additional disk space will be used.
Get:1 http://mirrors.digitalocean.com/ubuntu focal/main amd64 net-tools amd64 1.60+git20180626.aebd88e-1ubuntu1 [196 kB]
Fetched 196 kB in 0s (1091 kB/s)
Selecting previously unselected package net-tools.
(Reading database ... 63592 files and directories currently installed.)
Preparing to unpack .../net-tools_1.60+git20180626.aebd88e-1ubuntu1_amd64.deb ...
Unpacking net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Setting up net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Processing triggers for man-db (2.9.1-1) ...

root@redis-server:~# 
root@redis-server:~# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 134.209.144.10  netmask 255.255.240.0  broadcast 134.209.159.255
        inet6 fe80::d49c:acff:fe3c:1b1f  prefixlen 64  scopeid 0x20<link>
        ether d6:9c:ac:3c:1b:1f  txqueuelen 1000  (Ethernet)
        RX packets 13137  bytes 55420607 (55.4 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 7652  bytes 726470 (726.4 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.122.0.2  netmask 255.255.240.0  broadcast 10.122.15.255
        inet6 fe80::c0a4:a4ff:fe8e:8b70  prefixlen 64  scopeid 0x20<link>
        ether c2:a4:a4:8e:8b:70  txqueuelen 1000  (Ethernet)
        RX packets 15  bytes 1126 (1.1 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 16  bytes 1216 (1.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 862  bytes 158688 (158.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 862  bytes 158688 (158.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@redis-server:~# curl ifconfig.me
134.209.144.10root@redis-server:~# 
root@redis-server:~# 
root@redis-server:~# logout
Connection to 134.209.144.10 closed.
database-stuff $ doctl compute firewall list
ID    Name    Status    Created At    Inbound Rules    Outbound Rules    Droplet IDs    Tags    Pending Changes
database-stuff $ doctl compute firewall 
The sub-commands of `doctl compute firewall` manage DigitalOcean cloud firewalls.

Cloud firewalls provide the ability to restrict network access to and from a Droplet, allowing you to define which ports accept inbound or outbound connections. With these commands, you can list, create, or delete Cloud firewalls, as well as modify access rules.

A firewall's `inbound_rules` and `outbound_rules` attributes contain arrays of objects as their values. These objects contain the standard attributes of their associated types, which can be found below.

Inbound access rules specify the protocol (TCP, UDP, or ICMP), ports, and sources for inbound traffic that will be allowed through the Firewall to the target Droplets. The `ports` attribute may contain a single port, a range of ports (e.g. `8000-9000`), or `all` to allow traffic on all ports for the specified protocol. The `sources` attribute will contain an object specifying a whitelist of sources from which traffic will be accepted.

Usage:
  doctl compute firewall [command]

Available Commands:
  add-droplets    Add Droplets to a cloud firewall
  add-rules       Add inbound or outbound rules to a cloud firewall
  add-tags        Add tags to a cloud firewall
  create          Create a new cloud firewall
  delete          Permanently delete a cloud firewall
  get             Retrieve information about a cloud firewall
  list            List the cloud firewalls on your account
  list-by-droplet List firewalls by Droplet
  remove-droplets Remove Droplets from a cloud firewall
  remove-rules    Remove inbound or outbound rules from a cloud firewall
  remove-tags     Remove tags from a cloud firewall
  update          Update a cloud firewall's configuration

Flags:
  -h, --help   help for firewall

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute firewall [command] --help" for more information about a command.
database-stuff $ doctl compute firewall add-rules
Error: (firewall.add-rules) command is missing required arguments
database-stuff $ doctl compute firewall add-rules -h
Use this command to add inbound or outbound rules to a cloud firewall.

Usage:
  doctl compute firewall add-rules <id> [flags]

Flags:
  -h, --help                                                     help for add-rules
      --inbound-rules protocol:tcp,ports:22,droplet_id:123       A comma-separated key-value list that defines an inbound rule, e.g.: protocol:tcp,ports:22,droplet_id:123. Use a quoted string of space-separated values for multiple rules.
      --outbound-rules protocol:tcp,ports:22,address:0.0.0.0/0   A comma-separate key-value list the defines an outbound rule, e.g.: protocol:tcp,ports:22,address:0.0.0.0/0. Use a quoted string of space-separated values for multiple rules.

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute firewall 
The sub-commands of `doctl compute firewall` manage DigitalOcean cloud firewalls.

Cloud firewalls provide the ability to restrict network access to and from a Droplet, allowing you to define which ports accept inbound or outbound connections. With these commands, you can list, create, or delete Cloud firewalls, as well as modify access rules.

A firewall's `inbound_rules` and `outbound_rules` attributes contain arrays of objects as their values. These objects contain the standard attributes of their associated types, which can be found below.

Inbound access rules specify the protocol (TCP, UDP, or ICMP), ports, and sources for inbound traffic that will be allowed through the Firewall to the target Droplets. The `ports` attribute may contain a single port, a range of ports (e.g. `8000-9000`), or `all` to allow traffic on all ports for the specified protocol. The `sources` attribute will contain an object specifying a whitelist of sources from which traffic will be accepted.

Usage:
  doctl compute firewall [command]

Available Commands:
  add-droplets    Add Droplets to a cloud firewall
  add-rules       Add inbound or outbound rules to a cloud firewall
  add-tags        Add tags to a cloud firewall
  create          Create a new cloud firewall
  delete          Permanently delete a cloud firewall
  get             Retrieve information about a cloud firewall
  list            List the cloud firewalls on your account
  list-by-droplet List firewalls by Droplet
  remove-droplets Remove Droplets from a cloud firewall
  remove-rules    Remove inbound or outbound rules from a cloud firewall
  remove-tags     Remove tags from a cloud firewall
  update          Update a cloud firewall's configuration

Flags:
  -h, --help   help for firewall

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute firewall [command] --help" for more information about a command.
database-stuff $ doctl compute firewall create
Error: (firewall.create.name) command is missing required arguments
database-stuff $ doctl compute firewall create -h
Use this command to create a cloud firewall. This command must contain at least one inbound or outbound access rule.

Usage:
  doctl compute firewall create [flags]

Aliases:
  create, c

Flags:
      --droplet-ids 123,456                                      A comma-separated list of Droplet IDs to place behind the cloud firewall, e.g.: 123,456
      --format ID                                                Columns for output in a comma-separated list. Possible values: ID, `Name`, `Status`, `Created`, `InboundRules`, `OutboundRules`, `DropletIDs`, `Tags`, `PendingChanges`
  -h, --help                                                     help for create
      --inbound-rules protocol:tcp,ports:22,droplet_id:123       A comma-separated key-value list that defines an inbound rule, e.g.: protocol:tcp,ports:22,droplet_id:123. Use a quoted string of space-separated values for multiple rules.
      --name string                                              Firewall name (required)
      --no-header                                                Return raw data with no headers
      --outbound-rules protocol:tcp,ports:22,address:0.0.0.0/0   A comma-separate key-value list the defines an outbound rule, e.g.: protocol:tcp,ports:22,address:0.0.0.0/0. Use a quoted string of space-separated values for multiple rules.
      --tag-names frontend,backend                               A comma-separated list of tag names to apply to the cloud firewall, e.g.: frontend,backend

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute firewall create --name redis-server --inbound-rules tcp,ports:56380,address:27.5.207.248/32 --droplet-ids 273799523
Error: Unexpected input value [[tcp]], must be a key:value pair
database-stuff $ doctl compute firewall create --name redis-server --inbound-rules protocol:tcp,ports:56380,address:27.5.207.248/32 --droplet-ids 273799523
ID                                      Name            Status     Created At              Inbound Rules                                       Outbound Rules    Droplet IDs    Tags    Pending Changes
3d947ab0-bbe0-44f7-8c86-f8723ae247a6    redis-server    waiting    2021-11-15T18:22:59Z    protocol:tcp,ports:56380,address:27.5.207.248/32                      273799523              droplet_id:273799523,removing:false,status:waiting
database-stuff $ ssh -i ~/.ssh/digital_ocean root@134.209.144.10

^C
database-stuff $ redis-cli --tls -h redis-server-1.hosteddatabase.in -a 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347 -p 56380
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-server-1.hosteddatabase.in:56380> 
database-stuff $ doctl compute firewall create --name redis-server --inbound-rules protocol:tcp,ports:56380,address:27.5.207.248/32 --droplet-ids 273799523
database-stuff $ doctl compute firewall 
The sub-commands of `doctl compute firewall` manage DigitalOcean cloud firewalls.

Cloud firewalls provide the ability to restrict network access to and from a Droplet, allowing you to define which ports accept inbound or outbound connections. With these commands, you can list, create, or delete Cloud firewalls, as well as modify access rules.

A firewall's `inbound_rules` and `outbound_rules` attributes contain arrays of objects as their values. These objects contain the standard attributes of their associated types, which can be found below.

Inbound access rules specify the protocol (TCP, UDP, or ICMP), ports, and sources for inbound traffic that will be allowed through the Firewall to the target Droplets. The `ports` attribute may contain a single port, a range of ports (e.g. `8000-9000`), or `all` to allow traffic on all ports for the specified protocol. The `sources` attribute will contain an object specifying a whitelist of sources from which traffic will be accepted.

Usage:
  doctl compute firewall [command]

Available Commands:
  add-droplets    Add Droplets to a cloud firewall
  add-rules       Add inbound or outbound rules to a cloud firewall
  add-tags        Add tags to a cloud firewall
  create          Create a new cloud firewall
  delete          Permanently delete a cloud firewall
  get             Retrieve information about a cloud firewall
  list            List the cloud firewalls on your account
  list-by-droplet List firewalls by Droplet
  remove-droplets Remove Droplets from a cloud firewall
  remove-rules    Remove inbound or outbound rules from a cloud firewall
  remove-tags     Remove tags from a cloud firewall
  update          Update a cloud firewall's configuration

Flags:
  -h, --help   help for firewall

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute firewall [command] --help" for more information about a command.
database-stuff $ doctl compute firewall add-rules -h
Use this command to add inbound or outbound rules to a cloud firewall.

Usage:
  doctl compute firewall add-rules <id> [flags]

Flags:
  -h, --help                                                     help for add-rules
      --inbound-rules protocol:tcp,ports:22,droplet_id:123       A comma-separated key-value list that defines an inbound rule, e.g.: protocol:tcp,ports:22,droplet_id:123. Use a quoted string of space-separated values for multiple rules.
      --outbound-rules protocol:tcp,ports:22,address:0.0.0.0/0   A comma-separate key-value list the defines an outbound rule, e.g.: protocol:tcp,ports:22,address:0.0.0.0/0. Use a quoted string of space-separated values for multiple rules.

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute firewall list
ID                                      Name            Status       Created At              Inbound Rules                                       Outbound Rules    Droplet IDs    Tags    Pending Changes
3d947ab0-bbe0-44f7-8c86-f8723ae247a6    redis-server    succeeded    2021-11-15T18:22:59Z    protocol:tcp,ports:56380,address:27.5.207.248/32                      273799523              
database-stuff $ doctl compute firewall add-rules 3d947ab0-bbe0-44f7-8c86-f8723ae247a6 --inbound-rules protocol:tcp,ports:22,address:27.5.207.248
database-stuff $ ssh -i ~/.ssh/digital_ocean root@134.209.144.10
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon Nov 15 18:24:38 UTC 2021

  System load:  0.01              Users logged in:       1
  Usage of /:   6.2% of 24.06GB   IPv4 address for eth0: 134.209.144.10
  Memory usage: 22%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    105

36 updates can be applied immediately.
23 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable


Last login: Mon Nov 15 18:17:59 2021 from 27.5.207.248
root@redis-server:~# redis-cli --tls -h redis-server-1.hosteddatabase.in -a 09563cba2fe8ecc48f6f3c043bbce55e226d6f3a86be601b792fbc478f44d347 -p 56380
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-server-1.hosteddatabase.in:56380> 
root@redis-server:~# 
```

```bash
database-stuff $ doctl compute firewall list
ID                                      Name            Status       Created At              Inbound Rules                                                                                  Outbound Rules    Droplet IDs    Tags    Pending Changes
3d947ab0-bbe0-44f7-8c86-f8723ae247a6    redis-server    succeeded    2021-11-15T18:22:59Z    protocol:tcp,ports:22,address:27.5.207.248 protocol:tcp,ports:56380,address:27.5.207.248/32                      273799523              
database-stuff $ 
```

```bash
database-stuff $ doctl compute firewall list
ID                                      Name            Status       Created At              Inbound Rules                                                                                  Outbound Rules    Droplet IDs    Tags    Pending Changes
3d947ab0-bbe0-44f7-8c86-f8723ae247a6    redis-server    succeeded    2021-11-15T18:22:59Z    protocol:tcp,ports:22,address:27.5.207.248 protocol:tcp,ports:56380,address:27.5.207.248/32                      273799523              
database-stuff $ doctl compute firewall 
The sub-commands of `doctl compute firewall` manage DigitalOcean cloud firewalls.

Cloud firewalls provide the ability to restrict network access to and from a Droplet, allowing you to define which ports accept inbound or outbound connections. With these commands, you can list, create, or delete Cloud firewalls, as well as modify access rules.

A firewall's `inbound_rules` and `outbound_rules` attributes contain arrays of objects as their values. These objects contain the standard attributes of their associated types, which can be found below.

Inbound access rules specify the protocol (TCP, UDP, or ICMP), ports, and sources for inbound traffic that will be allowed through the Firewall to the target Droplets. The `ports` attribute may contain a single port, a range of ports (e.g. `8000-9000`), or `all` to allow traffic on all ports for the specified protocol. The `sources` attribute will contain an object specifying a whitelist of sources from which traffic will be accepted.

Usage:
  doctl compute firewall [command]

Available Commands:
  add-droplets    Add Droplets to a cloud firewall
  add-rules       Add inbound or outbound rules to a cloud firewall
  add-tags        Add tags to a cloud firewall
  create          Create a new cloud firewall
  delete          Permanently delete a cloud firewall
  get             Retrieve information about a cloud firewall
  list            List the cloud firewalls on your account
  list-by-droplet List firewalls by Droplet
  remove-droplets Remove Droplets from a cloud firewall
  remove-rules    Remove inbound or outbound rules from a cloud firewall
  remove-tags     Remove tags from a cloud firewall
  update          Update a cloud firewall's configuration

Flags:
  -h, --help   help for firewall

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output

Use "doctl compute firewall [command] --help" for more information about a command.
database-stuff $ doctl compute firewall delete
Error: (firewall.delete) command is missing required arguments
database-stuff $ doctl compute firewall delete -h
Use this command to permanently delete a cloud firewall. This is irreversable, but does not delete any Droplets assigned to the cloud firewall.

Usage:
  doctl compute firewall delete <id>... [flags]

Aliases:
  delete, d, rm

Flags:
  -f, --force   Delete firewall without confirmation prompt
  -h, --help    help for delete

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute firewall delete redis-server
Warning: Are you sure you want to delete this firewall? (y/N) ? y
Error: DELETE https://api.digitalocean.com/v2/firewalls/redis-server: 404 (request "304a0f4a-de1e-4d90-b1cd-1bd71a27e066") Firewall not found
database-stuff $ doctl compute firewall delete 3d947ab0-bbe0-44f7-8c86-f8723ae247a6
Warning: Are you sure you want to delete this firewall? (y/N) ? y
database-stuff $ 
```

```bash
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
273799523    redis-server    134.209.144.10    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ doctl compute droplet list
database-stuff $ doctl compute droplet delete redis-server 
Warning: Are you sure you want to delete this Droplet? (y/N) ? n
Error: Operation aborted.
database-stuff $ doctl compute droplet delete redis-server -h
Use this command to permanently delete a Droplet. This is irreversible.

Usage:
  doctl compute droplet delete <droplet-id|droplet-name>... [flags]

Aliases:
  delete, d, del, rm

Flags:
  -f, --force             Delete the Droplet without a confirmation prompt
  -h, --help              help for delete
      --tag-name string   Tag name

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute droplet delete redis-server --force
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
273799523    redis-server    134.209.144.10    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
273799523    redis-server    134.209.144.10    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ doctl compute droplet list
ID           Name            Public IPv4       Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
273799523    redis-server    134.209.144.10    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
database-stuff $ doctl compute droplet list
ID    Name    Public IPv4    Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image    VPC UUID    Status    Tags    Features    Volumes
database-stuff $ doctl compute firewall list
ID    Name    Status    Created At    Inbound Rules    Outbound Rules    Droplet IDs    Tags    Pending Changes
database-stuff $ 
```

---

[TODO]
- Check what DNS services provide an API to manage DNS records
  - Google Cloud Domains
  - Cloudflare DNS


---

Services providing API to manage DNS records -

Google Cloud Platform (GCP) - Google Cloud DNS - https://cloud.google.com/dns/

https://cloud.google.com/products/calculator

https://cloud.google.com/blog/products/networking/introducing-cloud-domains

https://cloud.google.com/domains/docs

https://cloud.google.com/domains/docs/domain-transfer-in

https://cloud.google.com/domains/docs/apis

https://cloud.google.com/domains/docs/getting-started

https://cloud.google.com/domains/pricing

https://duckduckgo.com/?q=dnssec&ia=web

https://www.cloudflare.com/en-gb/dns/dnssec/how-dnssec-works/

https://developers.cloudflare.com/registrar/

https://developers.cloudflare.com/

https://developers.cloudflare.com/registrar/get-started/register-domain

https://www.cloudflare.com/en-gb/tld-policies/

https://developers.cloudflare.com/registrar/get-started/transfer-domain-to-cloudflare

https://developers.cloudflare.com/registrar/account-options/enable-dnssec

https://www.cloudflare.com/en-gb/dns/dnssec/how-dnssec-works/

https://insights.sei.cmu.edu/blog/probable-cache-poisoning-of-mail-handling-domains/

https://developers.cloudflare.com/registrar/faq#billing

https://developers.cloudflare.com/api/

https://developers.cloudflare.com/api/v4docs

https://api.cloudflare.com/

https://api.cloudflare.com/#dns-records-for-a-zone-properties

https://api.cloudflare.com/#dnssec-properties

https://api.cloudflare.com/#dns-firewall-properties

https://api.cloudflare.com/#dns-firewall-analytics-properties

https://api.cloudflare.com/#secondary-dns-properties

https://api.cloudflare.com/#secondary-dns-tsig--properties

https://api.cloudflare.com/#secondary-dns-primary--properties

https://duckduckgo.com/?q=cloudflare+dns+pricing&ia=web

https://www.cloudflare.com/en-gb/plans/#overview

https://constellix.com/news/cloudflare-dns-features

https://www.wikihow.com/Transfer-a-Domain

https://developers.google.com/apis-explorer/#p/domains/v1/

https://cloud.google.com/dns/docs/reference/v1

---

[TODO]
- Read about DNSSEC !

---

```bash
~ $ doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
ID           Name            Public IPv4        Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
274264174    redis-server    165.232.179.170    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
~ $ ssh -i ~/.ssh/digital_ocean root@165.232.179.170
The authenticity of host '165.232.179.170 (165.232.179.170)' can't be established.
ECDSA key fingerprint is SHA256:CMOpuH2WGRSi0fvBCtrkPmDNSa1HxhNA1GaD5o0UwwI.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '165.232.179.170' (ECDSA) to the list of known hosts.
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Nov 18 17:12:01 UTC 2021

  System load:  0.0               Users logged in:       0
  Usage of /:   6.0% of 24.06GB   IPv4 address for eth0: 165.232.179.170
  Memory usage: 19%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    100

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@redis-server:~# 
root@redis-server:~# wget https://gist.githubusercontent.com/karuppiah7890/fc8fca5e3bdeafbf8072ee656141de7c/raw/e8d4533d8f9eff8b5136332644dcb81e64727ff7/run-redis.sh
--2021-11-18 17:12:09--  https://gist.githubusercontent.com/karuppiah7890/fc8fca5e3bdeafbf8072ee656141de7c/raw/e8d4533d8f9eff8b5136332644dcb81e64727ff7/run-redis.sh
Resolving gist.githubusercontent.com (gist.githubusercontent.com)... 185.199.110.133, 185.199.109.133, 185.199.108.133, ...
Connecting to gist.githubusercontent.com (gist.githubusercontent.com)|185.199.110.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 4376 (4.3K) [text/plain]
Saving to: ‘run-redis.sh’

run-redis.sh                    100%[=====================================================>]   4.27K  --.-KB/s    in 0s      

2021-11-18 17:12:09 (36.2 MB/s) - ‘run-redis.sh’ saved [4376/4376]

root@redis-server:~# 
root@redis-server:~# chmod +x run-redis.sh
root@redis-server:~# 
root@redis-server:~# ./run-redis.sh
./run-redis.sh: line 8: 1: Email has not been passed to the script. Usage example: ./run-redis.sh abc@example.com redis-server.example.com 156.165.10.5 6379
root@redis-server:~# 

root@redis-server:~# ./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in 165.232.179.170 56380
+ email=karuppiah7890@gmail.com
+ domain_name=redis-server-1.hosteddatabase.in
+ ip=165.232.179.170
+ tls_port=56380
+ install_redis
+ add-apt-repository ppa:redislabs/redis --yes
Hit:1 http://mirrors.digitalocean.com/ubuntu focal InRelease
Get:2 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease [114 kB]                                                
Hit:3 https://repos-droplet.digitalocean.com/apt/droplet-agent main InRelease                                                
Get:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease [101 kB]                                              
Get:5 http://ppa.launchpad.net/redislabs/redis/ubuntu focal InRelease [18.0 kB]
Get:6 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 Packages [1344 kB]   
Get:7 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]                 
Get:8 http://mirrors.digitalocean.com/ubuntu focal-updates/main Translation-en [276 kB]                                      
Get:9 http://mirrors.digitalocean.com/ubuntu focal-updates/main amd64 c-n-f Metadata [14.5 kB]                               
Get:10 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 Packages [1028 B]                                    
Get:11 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 Packages [569 kB]                               
Get:12 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main Translation-en [584 B]                            
Get:13 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted Translation-en [81.6 kB]
Get:14 http://mirrors.digitalocean.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [528 B]
Get:15 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 Packages [877 kB]
Get:16 http://mirrors.digitalocean.com/ubuntu focal-updates/universe Translation-en [190 kB]
Get:17 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [987 kB]    
Get:18 http://mirrors.digitalocean.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [19.5 kB]
Get:19 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 Packages [24.5 kB]
Get:20 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse Translation-en [6856 B]
Get:21 http://mirrors.digitalocean.com/ubuntu focal-updates/multiverse amd64 c-n-f Metadata [616 B]
Get:22 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 Packages [6588 B]
Get:23 http://mirrors.digitalocean.com/ubuntu focal-backports/universe Translation-en [3292 B]
Get:24 http://mirrors.digitalocean.com/ubuntu focal-backports/universe amd64 c-n-f Metadata [580 B]
Get:25 http://security.ubuntu.com/ubuntu focal-security/main Translation-en [184 kB]
Get:26 http://security.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [8880 B]
Get:27 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [526 kB]
Get:28 http://security.ubuntu.com/ubuntu focal-security/restricted Translation-en [75.4 kB]
Get:29 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 c-n-f Metadata [528 B]
Get:30 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [653 kB]
Get:31 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [107 kB]
Get:32 http://security.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [12.9 kB]
Get:33 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [21.9 kB]
Get:34 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 c-n-f Metadata [540 B]
Fetched 6339 kB in 3s (2086 kB/s)                           
Reading package lists... Done
+ apt install redis-server --yes
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  redis-tools
Suggested packages:
  ruby-redis
The following NEW packages will be installed:
  redis-server redis-tools
0 upgraded, 2 newly installed, 0 to remove and 39 not upgraded.
Need to get 1149 kB of archives.
After this operation, 6794 kB of additional disk space will be used.
Get:1 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-tools amd64 6:6.2.6-2rl1~focal1 [1067 kB]
Get:2 http://ppa.launchpad.net/redislabs/redis/ubuntu focal/main amd64 redis-server amd64 6:6.2.6-2rl1~focal1 [82.5 kB]
Fetched 1149 kB in 2s (578 kB/s)   
Selecting previously unselected package redis-tools.
(Reading database ... 63555 files and directories currently installed.)
Preparing to unpack .../redis-tools_6%3a6.2.6-2rl1~focal1_amd64.deb ...
Unpacking redis-tools (6:6.2.6-2rl1~focal1) ...
Selecting previously unselected package redis-server.
Preparing to unpack .../redis-server_6%3a6.2.6-2rl1~focal1_amd64.deb ...
Unpacking redis-server (6:6.2.6-2rl1~focal1) ...
Setting up redis-tools (6:6.2.6-2rl1~focal1) ...
Setting up redis-server (6:6.2.6-2rl1~focal1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.13) ...
+ systemctl status redis-server
● redis-server.service - Advanced key-value store
     Loaded: loaded (/lib/systemd/system/redis-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Thu 2021-11-18 17:12:50 UTC; 39s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 2448 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 5 (limit: 1136)
     Memory: 2.2M
     CGroup: /system.slice/redis-server.service
             └─2448 /usr/bin/redis-server 127.0.0.1:6379

Nov 18 17:12:50 redis-server systemd[1]: Starting Advanced key-value store...
Nov 18 17:12:50 redis-server systemd[1]: Started Advanced key-value store.
+ redis-cli -e PING
PONG
+ redis-cli -e INFO server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:9c9e426e2f96cc51
redis_mode:standalone
os:Linux 5.4.0-88-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:c11-builtin
gcc_version:9.3.0
process_id:2448
process_supervised:systemd
run_id:1a09c9dc7de65e338b227d9e49278259352e1882
tcp_port:6379
server_time_usec:1637255610119177
uptime_in_seconds:40
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:9865658
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
io_threads_active:0
+ check_malloc_is_jemalloc
+ grep jemalloc
+ redis-cli -e MEMORY MALLOC-STATS
___ Begin jemalloc statistics ___
--- End jemalloc statistics ---
+ configure_password
++ redis-cli -e ACL GENPASS
+ password=d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) ""
+ redis-cli -e CONFIG SET requirepass d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828
OK
+ export REDISCLI_AUTH=d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828
+ REDISCLI_AUTH=d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828
+ redis-cli -e CONFIG GET requirepass
1) "requirepass"
2) "d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'requirepass "d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828"'
+ cat /etc/redis/redis.conf
requirepass "d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828"
+ install_certbot
+ sudo snap install --classic certbot
certbot 1.21.0 from Certbot Project (certbot-eff✓) installed
+ sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot
+ obtain_ssl_certificate
+ sudo certbot certonly --standalone --non-interactive --agree-tos --email karuppiah7890@gmail.com --domains redis-server-1.hosteddatabase.in
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Account registered.
Requesting a certificate for redis-server-1.hosteddatabase.in

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
This certificate expires on 2022-02-16.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
+ give_redis_user_access_to_ssl_certificate
+ chown -R redis:redis /etc/letsencrypt/
+ configure_tls
+ configure_private_key
+ private_key_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) ""
+ redis-cli -e CONFIG SET tls-key-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem
OK
+ redis-cli -e CONFIG GET tls-key-file
1) "tls-key-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"'
+ cat /etc/redis/redis.conf
tls-key-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/privkey.pem"
+ configure_ssl_certificate
+ ssl_certificate_path=/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) ""
+ redis-cli -e CONFIG SET tls-cert-file /etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem
OK
+ redis-cli -e CONFIG GET tls-cert-file
1) "tls-cert-file"
2) "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"'
+ cat /etc/redis/redis.conf
tls-cert-file "/etc/letsencrypt/live/redis-server-1.hosteddatabase.in/fullchain.pem"
+ disable_tls_auth
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "yes"
+ redis-cli -e CONFIG SET tls-auth-clients no
OK
+ redis-cli -e CONFIG GET tls-auth-clients
1) "tls-auth-clients"
2) "no"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-auth-clients no'
+ cat /etc/redis/redis.conf
# tls-auth-clients no
tls-auth-clients no
+ configure_tls_port
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "0"
+ redis-cli -e CONFIG SET tls-port 56380
OK
+ redis-cli -e CONFIG GET tls-port
1) "tls-port"
2) "56380"
+ redis-cli -e CONFIG REWRITE
OK
+ grep 'tls-port 56380'
+ cat /etc/redis/redis.conf
tls-port 56380
+ disable_non_tls_port
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "6379"
+ redis-cli -e --tls -p 56380 CONFIG SET port 0
OK
+ redis-cli -e --tls -p 56380 CONFIG GET port
1) "port"
2) "0"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'port 0'
+ cat /etc/redis/redis.conf
# If port 0 is specified Redis will not listen on a TCP socket.
port 0
# port 0
# cluster-announce-port 0
+ configure_bind
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG SET bind '165.232.179.170 127.0.0.1 -::1'
OK
+ redis-cli -e --tls -p 56380 CONFIG GET bind
1) "bind"
2) "165.232.179.170 127.0.0.1 -::1"
+ redis-cli -e --tls -p 56380 CONFIG REWRITE
OK
+ grep 'bind 165.232.179.170 127.0.0.1 -::1'
+ cat /etc/redis/redis.conf
bind 165.232.179.170 127.0.0.1 -::1
+ echo 'Redis has been installed and configured and is running with TLS support and password protection!!'
Redis has been installed and configured and is running with TLS support and password protection!!
+ echo -e '\nConnection details - '

Connection details - 
+ echo 'Username - No user name'
Username - No user name
+ echo 'Password - d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828'
Password - d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828
+ echo 'Host - redis-server-1.hosteddatabase.in'
Host - redis-server-1.hosteddatabase.in
+ echo 'Port - 56380'
Port - 56380
+ echo -e '\nRedis CLI (redis-cli) command - '

Redis CLI (redis-cli) command - 
+ echo 'redis-cli --tls -h redis-server-1.hosteddatabase.in -a d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828 -p 56380'
redis-cli --tls -h redis-server-1.hosteddatabase.in -a d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828 -p 56380
root@redis-server:~# logout
Connection to 165.232.179.170 closed.
~ $ redis-cli --tls -h redis-server-1.hosteddatabase.in -a d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828 -p 56380
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-server-1.hosteddatabase.in:56380> 
~ $ 
~ $ doctl compute firewall create --name redis-server --inbound-rules tcp,ports:56380,address:27.5.207.248/32 --droplet-ids redis-server
~ $ curl ifconfig.me
60.243.82.0~ $ doctl compute firewall create --name redis-server --inbound-rules tcp,ports:56380,address:60.243.82.0/32 --dropis-servered 
~ $ 
~ $ 
~ $ 
~ $ doctl compute firewall create --name redis-server --inbound-rules tcp,ports:56380,address:60.243.82.0/32 --droplet-ids redis-server 
Error: Unexpected input value [[tcp]], must be a key:value pair
~ $ doctl compute firewall create --name redis-server --inbound-rules protocol:tcp,ports:56380,address:60.243.82.0/32 --droplet-ids redis-server 
Error: Provided value [redis-server] for droplet id is not of type int
~ $ 
~ $ doctl compute droplet list
ID           Name            Public IPv4        Private IPv4    Public IPv6    Memory    VCPUs    Disk    Region    Image                     VPC UUID                                Status    Tags    Features                            Volumes
274264174    redis-server    165.232.179.170    10.122.0.2                     1024      1        25      blr1      Ubuntu 20.04 (LTS) x64    98ca4926-d9da-4647-a411-2a489c7d2515    active            droplet_agent,private_networking    
~ $ doctl compute firewall create --name redis-server --inbound-rules protocol:tcp,ports:56380,address:60.243.82.0/32 --droplet-ids 274264174
ID                                      Name            Status     Created At              Inbound Rules                                      Outbound Rules    Droplet IDs    Tags    Pending Changes
f776fef2-0d90-4e59-ba11-74acab796bc4    redis-server    waiting    2021-11-18T17:16:07Z    protocol:tcp,ports:56380,address:60.243.82.0/32                      274264174              droplet_id:274264174,removing:false,status:waiting
~ $ doc
docker                         docker-compose-v1              docker-credential-ecr-login    doctl
docker-compose                 docker-credential-desktop      docker-credential-osxkeychain  
~ $ doctl compute firewall list
ID                                      Name            Status       Created At              Inbound Rules                                      Outbound Rules    Droplet IDs    Tags    Pending Changes
f776fef2-0d90-4e59-ba11-74acab796bc4    redis-server    succeeded    2021-11-18T17:16:07Z    protocol:tcp,ports:56380,address:60.243.82.0/32                      274264174              
~ $ ~ $ redis-cli --tls -h redis-server-1.hosteddatabase.in -a d95e66647a6816e7216efff60da3ce9c7733f565d62fd989a5b72ceca0d72828 -p 56380
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-server-1.hosteddatabase.in:56380> 
~ $ ssh -i ~/.ssh/digital_ocean root@165.232.179.170
^C
~ $ ssh -vvv -i ~/.ssh/digital_ocean root@165.232.179.170
OpenSSH_8.1p1, LibreSSL 2.7.3
debug1: Reading configuration data /Users/karuppiahn/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 47: Applying options for *
debug2: resolve_canonicalize: hostname 165.232.179.170 is address
debug2: ssh_connect_direct
debug1: Connecting to 165.232.179.170 [165.232.179.170] port 22.
^C
~ $ telnet 165.232.179.170 22
Trying 165.232.179.170...

^C
~ $ doctl compute firewall list
ID                                      Name            Status       Created At              Inbound Rules                                      Outbound Rules    Droplet IDs    Tags    Pending Changes
f776fef2-0d90-4e59-ba11-74acab796bc4    redis-server    succeeded    2021-11-18T17:16:07Z    protocol:tcp,ports:56380,address:60.243.82.0/32                      274264174              
~ $ 










~ $ doctl compute firewall add-rules f776fef2-0d90-4e59-ba11-74acab796bc4 --inbound-rules protocol:tcp,ports:22,address:60.243.82.0/32

~ $ 
~ $ ssh -vvv -i ~/.ssh/digital_ocean root@165.232.179.170
OpenSSH_8.1p1, LibreSSL 2.7.3
debug1: Reading configuration data /Users/karuppiahn/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 47: Applying options for *
debug2: resolve_canonicalize: hostname 165.232.179.170 is address
debug2: ssh_connect_direct
debug1: Connecting to 165.232.179.170 [165.232.179.170] port 22.
debug1: Connection established.
debug1: identity file /Users/karuppiahn/.ssh/digital_ocean type 3
debug1: identity file /Users/karuppiahn/.ssh/digital_ocean-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_8.1
debug1: Remote protocol version 2.0, remote software version OpenSSH_8.2p1 Ubuntu-4ubuntu0.3
debug1: match: OpenSSH_8.2p1 Ubuntu-4ubuntu0.3 pat OpenSSH* compat 0x04000000
debug2: fd 3 setting O_NONBLOCK
debug1: Authenticating to 165.232.179.170:22 as 'root'
debug3: hostkeys_foreach: reading file "/Users/karuppiahn/.ssh/known_hosts"
debug3: record_hostkey: found key type ECDSA in file /Users/karuppiahn/.ssh/known_hosts:77
debug3: load_hostkeys: loaded 1 keys from 165.232.179.170
debug3: order_hostkeyalgs: prefer hostkeyalgs: ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521
debug3: send packet: type 20
debug1: SSH2_MSG_KEXINIT sent
debug3: receive packet: type 20
debug1: SSH2_MSG_KEXINIT received
debug2: local client KEXINIT proposal
debug2: KEX algorithms: curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256,diffie-hellman-group14-sha1,ext-info-c
debug2: host key algorithms: ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256,ssh-rsa
debug2: ciphers ctos: chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
debug2: ciphers stoc: chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
debug2: MACs ctos: umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1
debug2: MACs stoc: umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1
debug2: compression ctos: none,zlib@openssh.com,zlib
debug2: compression stoc: none,zlib@openssh.com,zlib
debug2: languages ctos: 
debug2: languages stoc: 
debug2: first_kex_follows 0 
debug2: reserved 0 
debug2: peer server KEXINIT proposal
debug2: KEX algorithms: curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256
debug2: host key algorithms: rsa-sha2-512,rsa-sha2-256,ssh-rsa,ecdsa-sha2-nistp256,ssh-ed25519
debug2: ciphers ctos: chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
debug2: ciphers stoc: chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
debug2: MACs ctos: umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1
debug2: MACs stoc: umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1
debug2: compression ctos: none,zlib@openssh.com
debug2: compression stoc: none,zlib@openssh.com
debug2: languages ctos: 
debug2: languages stoc: 
debug2: first_kex_follows 0 
debug2: reserved 0 
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug3: send packet: type 30
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug3: receive packet: type 31
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:CMOpuH2WGRSi0fvBCtrkPmDNSa1HxhNA1GaD5o0UwwI
debug3: hostkeys_foreach: reading file "/Users/karuppiahn/.ssh/known_hosts"
debug3: record_hostkey: found key type ECDSA in file /Users/karuppiahn/.ssh/known_hosts:77
debug3: load_hostkeys: loaded 1 keys from 165.232.179.170
debug1: Host '165.232.179.170' is known and matches the ECDSA host key.
debug1: Found key in /Users/karuppiahn/.ssh/known_hosts:77
debug3: send packet: type 21
debug2: set_newkeys: mode 1
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug3: receive packet: type 21
debug1: SSH2_MSG_NEWKEYS received
debug2: set_newkeys: mode 0
debug1: rekey in after 134217728 blocks
debug1: Will attempt key: /Users/karuppiahn/.ssh/digital_ocean ED25519 SHA256:NMIQtJbsFE3DjlpS2UQm2ODIwKne3YNyYL+fU0BiFkA explicit
debug2: pubkey_prepare: done
debug3: send packet: type 5
debug3: receive packet: type 7
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,sk-ssh-ed25519@openssh.com,ssh-rsa,rsa-sha2-256,rsa-sha2-512,ssh-dss,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ecdsa-sha2-nistp256@openssh.com>
debug3: receive packet: type 6
debug2: service_accept: ssh-userauth
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug3: send packet: type 50
debug3: receive packet: type 51
debug1: Authentications that can continue: publickey
debug3: start over, passed a different list publickey
debug3: preferred publickey,keyboard-interactive,password
debug3: authmethod_lookup publickey
debug3: remaining preferred: keyboard-interactive,password
debug3: authmethod_is_enabled publickey
debug1: Next authentication method: publickey
debug1: Offering public key: /Users/karuppiahn/.ssh/digital_ocean ED25519 SHA256:NMIQtJbsFE3DjlpS2UQm2ODIwKne3YNyYL+fU0BiFkA explicit
debug3: send packet: type 50
debug2: we sent a publickey packet, wait for reply
debug3: receive packet: type 60
debug1: Server accepts key: /Users/karuppiahn/.ssh/digital_ocean ED25519 SHA256:NMIQtJbsFE3DjlpS2UQm2ODIwKne3YNyYL+fU0BiFkA explicit
debug3: sign_and_send_pubkey: ED25519 SHA256:NMIQtJbsFE3DjlpS2UQm2ODIwKne3YNyYL+fU0BiFkA
debug3: sign_and_send_pubkey: signing using ssh-ed25519
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
debug3: send packet: type 50
debug3: receive packet: type 52
debug1: Authentication succeeded (publickey).
Authenticated to 165.232.179.170 ([165.232.179.170]:22).
debug1: channel 0: new [client-session]
debug3: ssh_session2_open: channel_new: 0
debug2: channel 0: send open
debug3: send packet: type 90
debug1: Requesting no-more-sessions@openssh.com
debug3: send packet: type 80
debug1: Entering interactive session.
debug1: pledge: network
debug3: receive packet: type 80
debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
debug3: receive packet: type 4
debug1: Remote: /root/.ssh/authorized_keys:1: key options: agent-forwarding port-forwarding pty user-rc x11-forwarding
debug3: receive packet: type 4
debug1: Remote: /root/.ssh/authorized_keys:1: key options: agent-forwarding port-forwarding pty user-rc x11-forwarding
debug3: receive packet: type 91
debug2: channel_input_open_confirmation: channel 0: callback start
debug2: fd 3 setting TCP_NODELAY
debug3: ssh_packet_set_tos: set IP_TOS 0x48
debug2: client_session2_setup: id 0
debug2: channel 0: request pty-req confirm 1
debug3: send packet: type 98
debug1: Sending environment.
debug3: Ignored env NVM_INC
debug3: Ignored env TERM_PROGRAM
debug3: Ignored env NVM_CD_FLAGS
debug3: Ignored env SHELL
debug3: Ignored env TERM
debug3: Ignored env HISTSIZE
debug3: Ignored env TMPDIR
debug3: Ignored env TERM_PROGRAM_VERSION
debug3: Ignored env TERM_SESSION_ID
debug3: Ignored env GOPRIVATE
debug3: Ignored env NVM_DIR
debug3: Ignored env USER
debug3: Ignored env DIGITALOCEAN_API_TOKEN
debug3: Ignored env SSH_AUTH_SOCK
debug3: Ignored env DO_API_TOKEN
debug3: Ignored env BASH_SILENCE_DEPRECATION_WARNING
debug3: Ignored env PATH
debug3: Ignored env LaunchInstanceID
debug3: Ignored env __CFBundleIdentifier
debug3: Ignored env PWD
debug3: Ignored env XPC_FLAGS
debug3: Ignored env PS1
debug3: Ignored env XPC_SERVICE_NAME
debug3: Ignored env GPG_TTY
debug3: Ignored env SHLVL
debug3: Ignored env HOME
debug3: Ignored env GOROOT
debug3: Ignored env LOGNAME
debug1: Sending env LC_CTYPE = UTF-8
debug2: channel 0: request env confirm 0
debug3: send packet: type 98
debug3: Ignored env JABBA_HOME
debug3: Ignored env GOPATH
debug3: Ignored env NVM_BIN
debug3: Ignored env SECURITYSESSIONID
debug3: Ignored env _
debug3: Ignored env __CF_USER_TEXT_ENCODING
debug2: channel 0: request shell confirm 1
debug3: send packet: type 98
debug2: channel_input_open_confirmation: channel 0: callback done
debug2: channel 0: open confirm rwindow 0 rmax 32768
debug3: receive packet: type 99
debug2: channel_input_status_confirm: type 99 id 0
debug2: PTY allocation request accepted on channel 0
debug2: channel 0: rcvd adjust 2097152
debug3: receive packet: type 99
debug2: channel_input_status_confirm: type 99 id 0
debug2: shell request accepted on channel 0
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Nov 18 17:18:57 UTC 2021

  System load:  0.03              Users logged in:       0
  Usage of /:   6.2% of 24.06GB   IPv4 address for eth0: 165.232.179.170
  Memory usage: 21%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    103

37 updates can be applied immediately.
25 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable


Last login: Thu Nov 18 17:12:02 2021 from 60.243.82.0
root@redis-server:~# logout
debug3: receive packet: type 98
debug1: client_input_channel_req: channel 0 rtype exit-status reply 0
debug3: receive packet: type 98
debug1: client_input_channel_req: channel 0 rtype eow@openssh.com reply 0
debug2: channel 0: rcvd eow
debug2: channel 0: chan_shutdown_read (i0 o0 sock -1 wfd 4 efd 6 [write])
debug2: channel 0: input open -> closed
debug3: receive packet: type 96
debug2: channel 0: rcvd eof
debug2: channel 0: output open -> drain
debug2: channel 0: obuf empty
debug2: channel 0: chan_shutdown_write (i3 o1 sock -1 wfd 5 efd 6 [write])
debug2: channel 0: output drain -> closed
debug3: receive packet: type 97
debug2: channel 0: rcvd close
debug3: channel 0: will not send data after close
debug2: channel 0: almost dead
debug2: channel 0: gc: notify user
debug2: channel 0: gc: user detached
debug2: channel 0: send close
debug3: send packet: type 97
debug2: channel 0: is dead
debug2: channel 0: garbage collecting
debug1: channel 0: free: client-session, nchannels 1
debug3: channel 0: status: The following connections are open:
  #0 client-session (t4 r0 i3/0 o3/0 e[write]/0 fd -1/-1/6 sock -1 cc -1)

debug3: send packet: type 1
debug3: fd 1 is not O_NONBLOCK
Connection to 165.232.179.170 closed.
Transferred: sent 2424, received 4300 bytes, in 1.6 seconds
Bytes per second: sent 1539.0, received 2730.0
debug1: Exit status 0
~ $ telnet 165.232.179.170 22
Trying 165.232.179.170...
Connected to 165.232.179.170.
Escape character is '^]'.
SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3

Invalid SSH identification string.
Connection closed by foreign host.
~ $ telnet 165.232.179.170 22
Trying 165.232.179.170...
Connected to 165.232.179.170.
Escape character is '^]'.
SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3
^]
telnet> Connection closed.
~ $ 
```

https://docs.digitalocean.com/products/networking/firewalls/how-to/configure-rules/

https://docs.digitalocean.com/reference/api/api-reference/#operation/add_firewall_rules

```bash
database-stuff $ doctl compute firewall add-rules --help
Use this command to add inbound or outbound rules to a cloud firewall.

Usage:
  doctl compute firewall add-rules <id> [flags]

Flags:
  -h, --help                                                     help for add-rules
      --inbound-rules protocol:tcp,ports:22,droplet_id:123       A comma-separated key-value list that defines an inbound rule, e.g.: protocol:tcp,ports:22,droplet_id:123. Use a quoted string of space-separated values for multiple rules.
      --outbound-rules protocol:tcp,ports:22,address:0.0.0.0/0   A comma-separate key-value list the defines an outbound rule, e.g.: protocol:tcp,ports:22,address:0.0.0.0/0. Use a quoted string of space-separated values for multiple rules.

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute firewall add-rules f776fef2-0d90-4e59-ba11-74acab796bc4 --outbound-rules protocol:tcp,ports:0,address:0.0.0.0/0
database-stuff $ doctl compute firewall list
ID                                      Name            Status       Created At              Inbound Rules                                                                                   Outbound Rules                            Droplet IDs    Tags    Pending Changes
f776fef2-0d90-4e59-ba11-74acab796bc4    redis-server    succeeded    2021-11-18T17:16:07Z    protocol:tcp,ports:22,address:60.243.82.0/32 protocol:tcp,ports:56380,address:60.243.82.0/32    protocol:tcp,ports:0,address:0.0.0.0/0    274264174              
database-stuff $ doctl compute firewall add-rules f776fef2-0d90-4e59-ba11-74acab796bc4 --outbound-rules protocol:tcp,address:0.0.0.0/0
Error: POST https://api.digitalocean.com/v2/firewalls/f776fef2-0d90-4e59-ba11-74acab796bc4/rules: 422 (request "684ac201-dde6-478c-a924-7ad64830a33c") must have at least one rule
database-stuff $ doctl compute firewall add-rules f776fef2-0d90-4e59-ba11-74acab796bc4 --outbound-rules protocol:tcp,ports:,address:0.0.0.0/0
Error: POST https://api.digitalocean.com/v2/firewalls/f776fef2-0d90-4e59-ba11-74acab796bc4/rules: 422 (request "707b5886-8a38-4789-9925-df7bcaccea0c") must have at least one rule
database-stuff $ doctl compute firewall add-rules f776fef2-0d90-4e59-ba11-74acab796bc4 --outbound-rules protocol:tcp,ports:0,address:0.0.0.0/0
database-stuff $ ssh -i ~/.ssh/digital_ocean root@165.232.179.170
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Nov 18 17:33:18 UTC 2021

  System load:  0.0               Users logged in:       0
  Usage of /:   6.2% of 24.06GB   IPv4 address for eth0: 165.232.179.170
  Memory usage: 21%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    102

37 updates can be applied immediately.
25 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable


Last login: Thu Nov 18 17:26:15 2021 from 60.243.82.0
root@redis-server:~# curl google.com
^C
root@redis-server:~# logout
Connection to 165.232.179.170 closed.
database-stuff $ doctl compute firewall list
ID                                      Name            Status       Created At              Inbound Rules                                                                                   Outbound Rules                            Droplet IDs    Tags    Pending Changes
f776fef2-0d90-4e59-ba11-74acab796bc4    redis-server    succeeded    2021-11-18T17:16:07Z    protocol:tcp,ports:22,address:60.243.82.0/32 protocol:tcp,ports:56380,address:60.243.82.0/32    protocol:tcp,ports:0,address:0.0.0.0/0    274264174              
database-stuff $ doctl compute firewall list -h
Use this command to retrieve a list of cloud firewalls.

Usage:
  doctl compute firewall list [flags]

Aliases:
  list, ls

Flags:
      --format ID   Columns for output in a comma-separated list. Possible values: ID, `Name`, `Status`, `Created`, `InboundRules`, `OutboundRules`, `DropletIDs`, `Tags`, `PendingChanges`
  -h, --help        help for list
      --no-header   Return raw data with no headers

Global Flags:
  -t, --access-token string   API V2 access token
  -u, --api-url string        Override default API endpoint
  -c, --config string         Specify a custom config file (default "/Users/karuppiahn/Library/Application Support/doctl/config.yaml")
      --context string        Specify a custom authentication context name
  -o, --output string         Desired output format [text|json] (default "text")
      --trace                 Show a log of network activity while performing a command
  -v, --verbose               Enable verbose output
database-stuff $ doctl compute firewall list -o json
[
  {
    "id": "f776fef2-0d90-4e59-ba11-74acab796bc4",
    "name": "redis-server",
    "status": "succeeded",
    "inbound_rules": [
      {
        "protocol": "tcp",
        "ports": "22",
        "sources": {
          "addresses": [
            "60.243.82.0/32"
          ]
        }
      },
      {
        "protocol": "tcp",
        "ports": "56380",
        "sources": {
          "addresses": [
            "60.243.82.0/32"
          ]
        }
      }
    ],
    "outbound_rules": [
      {
        "protocol": "tcp",
        "ports": "0",
        "destinations": {
          "addresses": [
            "0.0.0.0/0"
          ]
        }
      }
    ],
    "droplet_ids": [
      274264174
    ],
    "tags": [],
    "created_at": "2021-11-18T17:16:07Z",
    "pending_changes": []
  }
]database-stuff $ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
database-stuff $ ssh -i ~/.ssh/digital_ocean root@165.232.179.170
Enter passphrase for key '/Users/karuppiahn/.ssh/digital_ocean': 
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Nov 18 17:34:15 UTC 2021

  System load:  0.0               Users logged in:       0
  Usage of /:   6.2% of 24.06GB   IPv4 address for eth0: 165.232.179.170
  Memory usage: 21%               IPv4 address for eth0: 10.47.0.5
  Swap usage:   0%                IPv4 address for eth1: 10.122.0.2
  Processes:    102

37 updates can be applied immediately.
25 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable


Last login: Thu Nov 18 17:33:18 2021 from 60.243.82.0
root@redis-server:~# dig

; <<>> DiG 9.16.1-Ubuntu <<>>
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7777
;; flags: qr rd ra; QUERY: 1, ANSWER: 13, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;.				IN	NS

;; ANSWER SECTION:
.			83454	IN	NS	l.root-servers.net.
.			83454	IN	NS	g.root-servers.net.
.			83454	IN	NS	e.root-servers.net.
.			83454	IN	NS	k.root-servers.net.
.			83454	IN	NS	f.root-servers.net.
.			83454	IN	NS	m.root-servers.net.
.			83454	IN	NS	b.root-servers.net.
.			83454	IN	NS	a.root-servers.net.
.			83454	IN	NS	i.root-servers.net.
.			83454	IN	NS	j.root-servers.net.
.			83454	IN	NS	h.root-servers.net.
.			83454	IN	NS	c.root-servers.net.
.			83454	IN	NS	d.root-servers.net.

;; Query time: 4 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Thu Nov 18 17:34:18 UTC 2021
;; MSG SIZE  rcvd: 239

root@redis-server:~# dig google.com

; <<>> DiG 9.16.1-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 11910
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		92	IN	A	142.250.193.110

;; Query time: 0 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Thu Nov 18 17:34:21 UTC 2021
;; MSG SIZE  rcvd: 55

root@redis-server:~# curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
root@redis-server:~# curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
root@redis-server:~# logout
Connection to 165.232.179.170 closed.
database-stuff $ 
```


