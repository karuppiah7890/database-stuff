
Hey folks! In this video I'm going to show a demo of how to deploy Redis Server on a 5$ Digital Ocean cloud virtual machine with TLS support and password protection. It's a very simple setup from where you can get started and then later you can configure the Redis Server and the Operating System according to your changing needs. You can also fine tune configurations for performance for your setup. For example you would do fine tuning and aim for performance in your production setup compared to a local development setup

Now, let's get started!

In Digital Ocean, droplets and virtual machines are the same thing, droplet is just a term used by Digital Ocean similar to how the term EC2 or Elastic Compute Cloud term is used in Amazon Web Services to refer to virtual machines

I currently have no droplets in my account, which you can see like this using the `doctl` CLI tool or you can also use Digital Ocean Dashboard. I have setup `doctl` and authenticated using it, so I'm gonna use that. I believe `doctl` is short for Digital Ocean control and is pretty simple to use

```bash
doctl compute droplet list
```

I have a few SSH keys, which you can see like this

```bash
doctl compute ssh-key list
```

I would be using one of these ssh keys while deploying the droplet

I'm going to deploy a 5$ Digital Ocean Droplet. Let's see the configuration for it

```bash
doctl compute size list
```

5$ Digital Ocean Droplet is a 1 vCPU and 1 GB RAM virtual machine

Let's start by deploying a 5$ Digital Ocean Droplet now

```bash
doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
```

I'm deploying the virtual machine with Ubuntu 20.04 64 bit Operating System image and deploying it in Bangalore region in India which is very close to where I live so the latency to connect to the virtual machine would be very low, which also means latency to connect to the Redis on the virtual machine would be very low

Now that the virtual machine has been deployed, we can see it in the list of droplets like this

```bash
doctl compute droplet list
```

Now let's SSH into virtual machine as a root user

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

Okay, it says authentication is required because we have set a password for the Redis Server now

Before we do anything using `redis-cli` to interact with the Redis Server, we have to authenticate with the Redis Server. For this we will set the `REDISCLI_AUTH` environment variable so that we don't have to pass the password in the command line using flags or pass it every time we use the `redis-cli` tool which can get pretty tedious

```bash
export REDISCLI_AUTH="<password>"
```

Now let's check if the password configuration is all good

```bash
redis-cli CONFIG GET requirepass
```

Now that it's configured, let's also quickly rewrite the config to the Redis Server Config file because that is a static config file that doesn't get changed on the fly unless we forcefully rewrite it using this command

```bash
redis-cli CONFIG REWRITE
```

Let's see if that worked

```bash
cat /etc/redis/redis.conf | grep "requirepass"
```

Cool, that worked! Now let's follow a similar strategy to do other configurations too

Now that the password is set, let's move on to using a port other than 6379 for our Redis. Why? So that when we expose the Redis Server to the Internet with a public IP malicious services will hit 6379 and other popular ports looking to exploit services like Redis, SSH and other popular server software. Changing the port of course does not prevent the malicious services or bots online from port scanning and trying out different protocols to detect what service is running at a given port, which can be a random port or popular default port. A better way to prevent attacks on the Redis Server would be to use firewalls to allow only some ports to be accessible and only some source IPs to be able to access these ports and only allow some protocols to be used while communicating to these ports. For example, in the case of Redis server,

- Allow only port 56379, a random port
- Allow only my computer's public IP to be able to access the Redis server
- Allow only TCP protocol communication on this port. If possible maybe even restrict it to Redis Server's RESP protocol which is based on top of TCP. RESP has different versions though, v3 being the latest I believe

Now let's follow the simple way and not do firewall stuff for now

Let's set the port number to 56379

```bash
{
    redis-cli CONFIG GET port;
    redis-cli CONFIG SET port 56379;
    redis-cli -p 56379 CONFIG GET port;
    redis-cli -p 56379 CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "port 56379";
}
```

Now we see that the port number of the Redis Server is 56379 already. We are using the `-p` flag where `p` is short for port

With port number and password set, let's see if we can connect to the Redis Server from my local machine using the virtual machine's public IP

I'm going to use `doctl` to check the public IP of the virtual machine. You can also use `curl ifconfig.me` or use `ifconfig` command line tool. Beware that `curl ifconfig.me` could be collecting the public IP of your virtual machine to know that it's an online virtual machine on the public Internet and could attack you or share the public IP with someone you don't want to share it to. But yeah, if you have safety measures in place like password configured and firewall to allow only trusted clients to access the Redis Server, I think you are good to go and don't have to worry about DDoS or breach attempts by cracking the Redis Server password. I'll probably try to cover firewalls in another video! But now, let's move on

Now, let's check the connectivity to the Redis Server from my local machine

So, I'm going to set the password

```bash
export REDISCLI_AUTH="<password>"
redis-cli -h <ip> -p 56379 PING
```

Hmm, it doesn't seem to work. It says connection refused. Let me check if there's any connectivity using `telnet`

```bash
telnet <ip> 56379
```

Hmm. It says connection refused. Okay, looks like there's no connectivity. So, usually there could be multiple reasons for this, so one reason could be that your Redis Server is not running. Or maybe the Redis Server is running at a different and you used the wrong port number or wrong IP address. Or maybe the Redis Server is running and port and IP is correct, but there is some firewall or network access block in between refusing the connections, or the Redis Server is running but refusing the connection due to some reason.

Well, the reason in our case is that by default Redis Server binds to only the loop back network interfaces and listens for connections from local clients only, that is, clients from the virtual machine where the Redis Server is deployed. We need to fix this by binding the Redis Server to the public IP or by binding it to all network interfaces of the virtual machine - which could include different kinds of networks. So beware of what you are doing, and if you don't know what you are doing, just stick to binding to the public IP address alone maybe, or public IP address and the loop back addresses

Let's connect back to the virtual machine

```
ssh -i ~/.ssh/digital_ocean root@<ip>
```

We need to authenticate using the `REDISCLI_AUTH` environment variable

```bash
export REDISCLI_AUTH="<password>"
```

```bash
{
    redis-cli -p 56379 CONFIG GET bind;
    redis-cli -p 56379 CONFIG SET bind "<ip> 127.0.0.1 -::1";
    redis-cli -p 56379 CONFIG GET bind;
    redis-cli -p 56379 CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "bind";
}
```

I'm binding the Redis Server explicitly to the public IP and the loopback interfaces. An alternative would be use

```bash
# redis-cli -p 56379 CONFIG SET bind "* -::*"
```

Which I don't recommend

Now that we have bound to the network interface associated with the public IP, we can now connect to the Redis Server from my local machine

```bash
echo $REDISCLI_AUTH;

redis-cli -p 56379 -h <ip> PING;
```

Now, let's setup TLS support for the Redis Server. For TLS support, I'm going to use Let's Encrypt Certificate Authority Free Certificates and use a demo sub domain of a domain name that I own through Google Domains

First, let me show how I point the DNS of the sub domain to the Redis Server's public IP so that I can prove to Let's Encrypt that I'm actually the owner of the domain name and it's records and hence I'm eligible to get the SSL certificates for the domain name and use it in my Redis Server

I'm going to switch to Google Domains website now. Okay, here we go

Now let's add a DNS A record, with sub domain as redis-server-2 and use the Redis Server's public IP

Now let's obtain the SSL Certificate using a free and open source tool called certbot

Let's first install the certbot tool. Let me SSH into the virtual machine

```bash
ssh -i ~/.ssh/digital_ocean root@<ip>
```

```bash
{
    sudo snap install --classic certbot;
    sudo ln -s /snap/bin/certbot /usr/bin/certbot;
}
```

Now let's get the SSL certificate

```bash
sudo certbot certonly --standalone
```

```bash
ls -l /etc/letsencrypt/live/redis-server-2.hosteddatabase.in/
```

Now that we have the SSL certificate and the private key, let's use it to configure the Redis Server

Before configuring it in the Redis Server, we need to ensure that the Redis Server can access the SSL certificate. The Redis Server is being run using the `redis` user and has the same access as the `redis` user. How do I know this? Well, we find it out by checking the systemd service file

```bash
systemctl status redis-server
```

```bash
cat /lib/systemd/system/redis-server.service
```

But the `redis` user does not have access to the SSL certificate that we just created. How do I know this? Well by checking this

```bash
ls -l /etc/letsencrypt/
```

```bash
ls -l /etc/letsencrypt/live/redis-server-2.hosteddatabase.in/
```

All the files are owned by root user. Only root user has access to the `/etc/letsencrypt` directory. Other users in root group or users in other groups cannot read it, this includes the `redis` user. So we will have to give the `redis` user access to the SSL certificate

Let's give the access now!

```bash
{
    chown -R redis:redis /etc/letsencrypt/;
    ls -al /etc/letsencrypt/;
}
```

Now that we have solved the access issue, let's configure the Redis Server with the SSL certificate which is the public key and also configure the private key! I'll start with the private key first!

Let's set the password first

```bash
export REDISCLI_AUTH=<password>
```

Cool, now the configuration!

```bash
{
    redis-cli -p 56379 CONFIG GET tls-key-file;
    redis-cli -p 56379 CONFIG SET tls-key-file "/etc/letsencrypt/live/redis-server-2.hosteddatabase.in/privkey.pem";
    redis-cli -p 56379 CONFIG GET tls-key-file;
    redis-cli -p 56379 CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-key-file";
}
```

Let's do the public key next, which is the SSL certificate

```bash
{
    redis-cli -p 56379 CONFIG GET tls-cert-file;
    redis-cli -p 56379 CONFIG SET tls-cert-file "/etc/letsencrypt/live/redis-server-2.hosteddatabase.in/fullchain.pem";
    redis-cli -p 56379 CONFIG GET tls-cert-file;
    redis-cli -p 56379 CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-cert-file";
}
```

Now we have configured the Redis Server with SSL certificate and private key. Let's disable the TLS auth clients feature which is usually enabled by default to say that clients must provide TLS certificates while connecting to the Redis Server. Since I'm not gonna be creating client certificates for clients in this video, I'll disable. If I don't it will lead to some errors as it's enabled by default. 

```bash
{
    redis-cli -p 56379 CONFIG GET tls-auth-clients;
    redis-cli -p 56379 CONFIG SET tls-auth-clients no;
    redis-cli -p 56379 CONFIG GET tls-auth-clients;
    redis-cli -p 56379 CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-auth-clients no";
}
```

Next, let's also set the TLS port to enable the TLS feature and listening at the TLS port

```bash
{
    redis-cli -p 56379 CONFIG GET tls-port;
    redis-cli -p 56379 CONFIG SET tls-port 56380;
    redis-cli -p 56379 CONFIG GET tls-port;
    redis-cli -p 56379 CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-port 56380";
}
```

Next, let's disable the non-TLS port

```bash
{
    redis-cli -p 56379 CONFIG GET port;
    redis-cli -p 56379 CONFIG SET port 0;
    redis-cli --tls -p 56380 CONFIG GET port;
    redis-cli --tls -p 56380 CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "port 0";
}
```

Note that once I disable the non-TLS port, I can only use the TLS port number and I need to use `--tls` flag in the `redis-cli` or else you will get an I/O error. Something like this

```
redis-cli -p 56380 CONFIG GET port;
```

Now we can connect to this Redis Server from my local using `redis-cli` or using `redli`, which is another Redis Client CLI tool from IBM. We can use `redli` like this

```bash
redli --tls -h redis-server-1.hosteddatabase.in -a <password> -p 56380
```

That's all I had for this video! I hope you learned something! Let me know your comments in the comments section! Thanks for watching! I'll see you in the next one! Bubye!
