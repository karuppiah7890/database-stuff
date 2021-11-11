
Hey folks! In this video I'm going to show a demo of how to deploy Redis Server on a 5$ Digital Ocean Droplet with TLS support and password protection. It's a very simple setup from where you can get started and then configure the Redis Server and the Operating System according to your needs and also to fine tune things for performance for your setup which could be a production setup

Now, let's get started!

I currently have no droplets in my account, which you can see like this

```bash
doctl compute droplet list
```

I have a few SSH keys, which you can see like this

```bash
doctl compute ssh-key list
```

I would be using one of these ssh keys while deploying the droplet

I'm going to deploy a 5% Digital Ocean Droplet. Let's see the configuration for it

```bash
doctl compute size list
```

5$ Digital Ocean Droplet is a 1 vCPU and 1 GB RAM virtual machine. In Digital Ocean, droplets and virtual machines are the same thing, droplet is just a term used by Digital Ocean similar to how the term EC2 or Elastic Compute Cloud is used in Amazon Web Services to refer to virtual machines

Let's start by deploying a 5$ Digital Ocean Droplet now

```bash
doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
```

I'm deploying the virtual machine with Ubuntu 20.04 Operating System and deploying it in Bangalore region in India which is very close to where I live so the latency to connect to the virtual machine would be very low

Now that the virtual machine has been deployed, we can see it in the list of droplets like this

```bash
doctl compute droplet list
```

Now let's SSH into it as a root user

```bash
ssh -i ~/.ssh/digital_ocean root@<ip>
```

Now we are inside the virtual machine

Let's install Redis

```bash
{
    add-apt-repository ppa:redislabs/redis --yes;
    apt install redis-server --yes;
}
```

This will add the Redis Labs Redis repository and install Redis. By the way, Redis Labs company renamed themselves to just Redis

Cool, now that Redis is installed, you will also notice that the Redis Server is already running. I believe it's part of the installation

You can check the Redis Server that's running like this

```bash
systemctl status redis-server;
```

You can see that we are running Redis Server version 6.2.6

You can also of course connect to it using `redis-cli`

```bash
redis-cli PING;
```

And we can also check the Redis Server version like this

```bash
redis-cli INFO server
```

So we are running Redis Server version 6.2.6

I'm going to check if this Redis Server is using libc library or jemalloc library for memory allocation using `MEMORY MALLOC-STATS` Redis command

```bash
redis-cli MEMORY MALLOC-STATS;
```

Cool, it uses jemalloc !

Now let's generate a password and use it to configure and protect our Redis Server with password protection

```bash
redis-cli ACL GENPASS;
```

Currently there's no password configured for the default user

```bash
redis-cli CONFIG GET requirepass
```

Let's configure a password for the default user

```bash
redis-cli CONFIG SET requirepass <password>
```

Let's check if it's configured

```bash
redis-cli CONFIG GET requirepass
```

Now that it's configured, let's also quickly rewrite the config to the Redis Server Config file

```bash
redis-cli CONFIG REWRITE
```

Let's see if that worked

```bash
cat /etc/redis/redis.conf | grep "requirepass"
```

Cool, that worked! Now let's follow a similar strategy to do other configurations too

Now that the password is set, let's move on to using a port other than 6379 for our Redis. Why? So that when we expose the Redis Server to the Internet with a public IP malicious services will hit 6379 and other popular ports looking to exploit services like Redis, SSH and other popular server software. Changing the port of course does not prevent the malicious services or bots online from port scanning and trying out different protocols to detect what service is being run at a given port, which can be a random port or popular default port. A better way to prevent attacks on the Redis Server would be to use firewalls to allow only some ports to be accessible and only some source IPs to be able to access these ports and only allow some protocols to be used while communicating to this port. For example, in the case of Redis server,

- Allow only port 56379, a random port
- Allow only my computer's public IP to be able to access the Redis server
- Allow only TCP protocol communication on this port. If possible maybe even restrict it to Redis Server's RESP protocol which is based on top of TCP. RESP has different versions though, v3 being the latest I believe
