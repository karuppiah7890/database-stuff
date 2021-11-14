
Hey folks! In this video I'm going to show you a demo of how to deploy Redis Server on a 5$ Digital Ocean cloud virtual machine with TLS support and password protection.

Let's start by deploying a Digital Ocean virtual machine like this

```bash
doctl compute droplet create --image ubuntu-20-04-x64 --size s-1vcpu-1gb --region blr1 redis-server --ssh-keys 32221856 --wait
```

Next, let's create a DNS A record for a sub domain name and point it to this public IP address

I have a domain name in Google Domains and I'm gonna use that. We will be using this sub domain name to connect to our redis-server and also to obtain SSL certificates for TLS/SSL support.

```
redis-server-1
```

```
redis-server-1.hosteddatabase.in
```

Now let's get back to the terminal

I'm going to SSH into the virtual machine now

```bash
ssh -i ~/.ssh/digital_ocean root@<ip>
```

Now I'm going to use a script to install and configure the Redis Server

This script is present in one of my GitHub repos and also in the form of a gist. You can use whatever you prefer. I'll link both of them in the video description

```bash
wget https://gist.githubusercontent.com/karuppiah7890/fc8fca5e3bdeafbf8072ee656141de7c/raw/e8d4533d8f9eff8b5136332644dcb81e64727ff7/run-redis.sh
```

Let's ensure that we can execute this script

```bash
chmod +x run-redis.sh
```

Cool, now let's run it!

<!-- 
```bash
./run-redis.sh
```

So it tells me that I need to pass my Email ID and also shows an example where it shows I need to pass the Domain name, IP and TLS port number too
-->

```bash
./run-redis.sh karuppiah7890@gmail.com redis-server-1.hosteddatabase.in <ip> 56380
```

And that's it! We now have a Redis Server deployed and configured and we can connect to it using the `redis-cli` tool with this command! :D
