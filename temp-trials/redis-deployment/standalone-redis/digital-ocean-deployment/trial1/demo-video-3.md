
Hey folks! This is a sequel to the previous video where I showed how to deploy a Redis Server on a 5$ Digital Ocean cloud virtual machine with TLS support and password protection. In this video I'm going to show you a demo of how to secure your Redis Server after deploying it to Digital Ocean

I had mentioned that when the Redis Server has a public IP and is exposed to the outside world, it's important to secure it

One of the key things about security is - authentication, authorization and encrypting communication. We have actually added authentication by adding a password and encrypted communications between the Redis Server and the Redis clients by enabling TLS support and by using Let's Encrypt Certificate Authority SSL certificates. You could add authorization by using Redis ACL - Access Control List which is a new feature in the latest Redis versions. I'll probably do a demo on that another day

In this video, we are going to look at how to use the Digital Ocean Cloud Firewall to protect and control connections to and from the Redis Server

We can choose to open up any and all ports in a Redis Server and also open it up for everyone on the Internet or just some trusted systems or just our own systems. Opening up the Redis Server to everyone on the Internet with a public IP is a very risky thing as many bots out there on the Internet can try to hack your Redis Server and any other open systems on the virtual machine, for example the SSH server running on the virtual machine for `ssh` feature

For example, let's see how to open up only the Redis Server's TLS port to my local machine's public IP

Now, if you see, we can connect to the Redis Server and do `PING`, `KEYS *` etc

But we can't even `ssh` into this Virtual machine, for which we have to open up the 22 port of `sshd` which SSH daemon or the SSH server. For which we have to add another inbound rule to the firewall

Now, you can see you can SSH into the virtual machine

But if you try to access the Internet, it will not work out. Now, this maybe a boon or a bane. If you think the virtual machine should not have access to the Internet and other networks, it's a boon, but otherwise it's a bane / a problem. For solving this, you need to add an outbound rule to the firewall to allow all outbound connections. Note that this is assuming that all the software in the virtual machine can be trusted, if you can't trust it - then it can corrupt / damage your data on the virtual machine and it can also send / transfer / leak all the data to some remote machine for which it will ideally require Internet access, which can be controller outbound Firewall rules

These cloud firewall rules are similar to Operating System firewall rules. For Digital Ocean cloud firewall, the features it provides are these - https://docs.digitalocean.com/products/networking/firewalls/ . Each cloud's firewall has it's own features!

Finally we can delete the firewall like this or we can also delete just some of the firewall rules too
