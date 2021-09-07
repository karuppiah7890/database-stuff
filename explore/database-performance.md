Looking at the different levels at which one can squeeze performance, I was wondering about these -

- Hardware
- Software

In Hardware -
- Processing power
- Network
- Storage - Disk

In Software -
- OS with Kernel
- Application
    - Algorithm
    - Application's programming language runtime, standard library and other code
- Network
    - Protocol used for communication

---

I think if one can squeeze out the performance at every level by customizing things particular to the system, then the system will be blazing fast! :D

---

For processing power, I was wondering about different processor architectures like - CPU amd64, then there's arm / ARM which is also getting popular with Apple's new macbook using ARM. Then there's Graphical Processing Unit (GPU) apart from CPU.

I recently noticed about AWS's new processor - https://aws.amazon.com/ec2/graviton/ . There are also different types of AWS EC2 instances for different kinds of workloads - https://aws.amazon.com/ec2/instance-types/r6/ , https://aws.amazon.com/ec2/instance-types/x2/ and more! Compute Optimized, General Purpose, Memory Optimized

I think if one can squeeze out the performance at every level by customizing things particular to the system, then the system will be blazing fast! :D

https://duckduckgo.com/?q=aws+graviton+processor&t=ffab&ia=web

More about AWS Graviton - https://aws.amazon.com/blogs/aws/new-amazon-rds-on-graviton2-processors/ , https://aws.amazon.com/blogs/machine-learning/aws-and-nvidia-to-bring-arm-based-instances-with-gpus-to-the-cloud/

I have also seen such kind of performance improvements using processors for Machine Learning workloads

I found out about Graviton when I noticed it on Travis CI

https://duckduckgo.com/?t=ffab&q=travis-ci+graviton&ia=web

https://aws.amazon.com/blogs/opensource/getting-started-with-travis-ci-com-on-aws-graviton2/

https://blog.travis-ci.com/AWS-Graviton-2-support-comes-to-Travis-CI

https://blog.travis-ci.com/2020-09-11-arm-on-aws

Travis CI speeding up builds in an interesting manner!

https://dev.to/aws-builders/aws-graviton-processors-3nk3

So, I think it's key to check on the processing power / compute power and of course check on the memory (RAM) and get the best of both worlds as much as possible, for a database. But I guess it still depends, for example in Redis, you might focus on Memory more? Something to think about. Surely Redis would need CPU too! For any computing, of course!

Another thing to note is, I have also heard about Application-specific Integrated Circuits (ASIC) - https://en.wikipedia.org/wiki/Application-specific_integrated_circuit . It's something to checkout, but everything has it's own advantages and disadvantages of course. I remember hearing that general purpose circuits are built for general use cases, but application specific ones are specific to an application and also something about how if it can be modified for a different application or not is the tricky part. There are also other kinds of circuits, for example there's also Field-programmable Gate Array (FPGA) - https://en.wikipedia.org/wiki/Field-programmable_gate_array . All these are interesting things to checkout! I don't know much, so I need to research more

---

In terms of network, I don't have much to say since I haven't researched much. But surely physical network hardware is key too! Usually cloud providers and Internet Service Providers take care of all this

---

Disk - I don't know much here too. Something to research more on! But I keep hearing a lot about NVMe! For example, here's a DB called Splinter DB which utilizes NVMe - https://www.usenix.org/conference/atc20/presentation/conway

---

OS - I know only a few popular Operating Systems and Kernels. I think the Kernel is the key thing. As of now, Linux seems to be the most popular and widely used Kernel! But yeah, there are others too surely!

I don't have much to say here as I need to research more, but I guess I would go with Linux for now - just for the big community and support and maturity, even though there might be better kernels and operating systems with better features and performance and utilizing the modern hardware - not many people might know about it and be able to help with it when issues come up. Also it can be a problem when new solutions need to be built with the kernel in mind but one doesn't know how to build it as they don't know much about the kernel

---

Application Algorithm

I guess it's obvious that Algorithm has to be good to be performant - all the time and space complexity stuff. 

The key thing here is, there are only a few kinds of general purpose database with generic solutions. If some more specificity was there in the problem that the database is solving, would it be more performant? Something to think about. Also, if the problem and solution are more specific, would it be more simple too? Hmm, with less bugs? ;)

---

Application's programming language runtime, standard library and other code

I think most times I see database written in C, C++. Sometimes Golang. More recently Rust. So, it's pretty cool that there's a few choices now ;) I'm planning to mostly use Rust and squeeze the performance out of the database! At least, that's what I hear from people who love and write Rust!

---

Network protocol

I know databases using HTTP APIs, custom protocols on top of TCP

Given that new protocols are coming up everyday, this is something to check out too and see if there's a venue to optimize the performance here too. For example, there's QUIC protocol which I'm yet to checkout, but it's a new venue. The only tricky thing is - both database client and server have to support it. Unlike HTTP APIs with HTTP clients and client libraries, it's harder to implement something that's less well known across many languages for developers to be able to use it. HTTP and TCP are popular, mature and ubiquitous. If someone uses something else, like QUIC, they have to also ensure that they can write clients (GUI, CLI) and client libraries in different languages. Something to be aware of is that there are already some implementations of QUIC available for example, but maybe not in all languages. Also, since QUIC is new, community and support around it might be less!!

Maybe supporting multiple protocols might be a good idea - HTTP, QUIC and even TCP and anything else that seems like a good option. For example, if QUIC is a viable option, maybe one can say that QUIC is for squeezing out the performance at the network layer at protocol level ;) If that's possible and implemented that is and someone asks "Why use QUIC?"

---

Are there any advantages to using ARM and other CPU architectures? For example Graviton seems to be popular, and fast. How? Why not AMD64? [Question]
