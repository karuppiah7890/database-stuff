What would one need to do to create a DBaaS? 🤔

Surely it has to be an End to End thing. For example, a good Web UI for someone to quickly click a button and get a Database. Users of the DBaaS should be aware of security issues in the DB and should be able to do quick updates at the click of a button - or be able to tell that updates can be automatic, but of course this is assuming that there is no downtime to the database version upgrades / other updates (configuration, side components etc). But yeah, breaking changes cannot happen in the upgrades - so only for vulnerability fix or bug fix updates, one could do patch version upgrades automatically if user desires it. Minor version or major version automatic upgrades - big no no I guess, especially when there's drastic changes including breaking changes in major version upgrades. So, the user of course gets to decide and choose what version they use and when and how to upgrade too - manual / automatic. Manual simply means they gotta click a button. Automatic - it's just automatic, but again, users get to say when the upgrades can happen / should happen - for example, not during peak traffic hours, with the fear that if something goes wrong, it could go terribly wrong for a lot of users, etc. I guess manual vs automatic is not a great distinction, something to think more about. But in any case, user should have complete control, and DBaaS should just act on it with the user's instructions in it's mind, for example, an instruction could be like "Upgrade patch versions automatically only on Sundays from 2 am IST to 3 am IST"

Status page / high level monitoring page for "db is up" or "db is down"

monitoring dashboards for CPU, Memory, Disk and many other DB specific details. For example, for redis - number of keys present, biggest keys, etc

Upgrades, Downgrades

Support many platforms - Kubernetes, Nomad, plain old VMs. What about Docker, Docker Swarm? Meh, maybe not. Docker Engine generally runs only in a single machine I think, for cluster like behavior, one needs something like Docker Swarm I think

Use pre-defined container images for container orchestration platforms, use pre-defined artifacts (tar balls etc) with binaries for VMs or use VM images

Support many cloud providers including popular ones - GCP, AWS, Azure, Digital Ocean etc

I think all the operations need to be noted down first to do them manually. And then it has to be codified! :D

Some things to keep in mind for basic things like creating a machine for hosting the DB -
- If we host the DB on machines directly, we will need machines - bare metal machines or VMs. We need to be able to create them on demand
- If we host the DB on containers (Nomad, K8s etc), we will still need machines to run the containers (Nomad, K8s etc)

For creating machines, this is what we need to know
- If we host directly on VMs or bare metal machines, that is without containers, then we will need to create the machine using things like - interacting with the cloud APIs directly, or using an abstraction like Terraform where Terraform Providers for different Cloud Providers help interact with the Cloud APIs with ease, or use an abstraction like Pulumi which is like Terraform but with lots of code and flexibility I think, or we could use a Kubernetes cluster, with something like https://kubevirt.io to manage the VMs or bare metal machines using K8s objects and let controllers in K8s clusters take care of interacting with Cloud APIs, for example - there's cloud controller manager helps K8s cluster to scale up and scale down K8s clusters with more and less nodes, and it also helps with interacting with the Cloud APIs for other things too, like get a public IP for load balancer services, creating disks and PVs etc, so that's cool too!

- If we host on containers, like using K8s or Nomad, then we can just leave the whole machine management to K8s or Nomad if they have controllers that interact with the cloud APIs to scale up and scale down nodes, and DBs will be on containers, if more containers come in more nodes will be created!

---

How do other DBaaS services manage their databases? CockroachLabs apparently manages CockroachDB on Kubernetes cluster

---

Other things to keep in mind
Location of the Database - region where it's deployed, as this determines distance between where the app is deployed and the database is deployed. If the app and database are far away, it's possible to have more latency due to the distance, as we are constrained by the speed of light. https://www.oreilly.com/content/primer-on-latency-and-bandwidth/

Resource usage of the Database - how to ensure that the database gets the resources it needs? CPU, RAM, Disk, Networking. Other processes in the system should not compete with the database server for these resources, affecting the database. This is where Linux Containers concept can help I guess, which helps to have an isolated process. I've to check if it can help and take care of both - minimum and maximum limits for resource for the database. I know Kubernetes allows setting such min (request) and max(limit). Basically, the database should have exclusive access to resources - if resources are given to it, nothing else (no other processes) should use it up or compete for it, and database also should not take up too much resources or have access to infinite or complete resources of the system, and instead should have a maximum. But the question is - in DBaaS - how does one set limits / a max for resources? I mean, if the database hit limits, do we not allow the database to use more resources? That will hinder the database to work properly. Also, in terms of pricing, if the pricing is based on resource usage, then ideally the user has to be alerted about this. And of course there will be alerts on high resource usage, for example 80% CPU usage, 80% RAM usage etc, but if the user does not respond to the alerts and if it hits the high, how does a service handle it is the question, hmmm. In a Pay As You Go Model, I guess the DBaaS could just increase the amount of resources for the database and ask for more money, of course this is assuming that the increase in resource usage was due to the user's database usage and not due to some issue that happened in the database and wasn't looked at by us the DBaaS provider in which case it's our fault that the database is misbehaving and using unexpected amount of resources. Also, if we keep increase resources for the database as resource usage increases - when do we stop? What if it's an issue from the DBaaS platform side? Or from the Application side? Or something else? It has to be determined as to why the resource usage is high and then accordingly a solution has to be implemented. Also, I have seen limits for CPU, RAM, Disk, but networking - something to checkout, surely max is easy - the max of the connection / network link (ethernet interface usually), min also has to be taken care of, basically, an exclusive network connection. Hopefully control groups (cgroups) in Linux can help with all of that!

Some buzz words in the DBaaS market
- Active Active replication
- Globally distributed database
- Serverless database
- Multi-model database


---

To get the best performance, the database can be run on the best hardware and software - the processors, the memory, the disk, the OS etc

For example, for Redis, we could use Graviton processor - a memory optimized one, or different kinds of processor based on user's usage and expectation! I need to learn more about the available processors in the market. Graviton is just one

---

Some thoughts -

Create a DBaaS service platform. Start with Redis, or say etcd ;) :D

Create an operator. Look at end to end

How to do no or minimal downtime upgrades for any change in version or any change in anything, say certificates, auth etc

Create plugins, for example Redis Hashicorp Vault plugin

Contribute to existing plugins like Redis Grafana plugin

Create plugins for everything, for example, sending Redis Data to data dog, sending Redis Data to influx db cloud, sending Redis Data to New relic, Kibana etc

Think about how to use a status page to show simple status. Or maybe use Grafana dashboard ;)

Think about how to get updates about new releases - major versions, minor versions, patch versions including security updates so that you can immediately do the updates! And prevent problems!! :)

Access control, security etc

A platform to run the stuff. Kubernetes, Nomad, or even without these? Hmm. We want both container and non container platforms ! And some simple platforms!!! :) Nomad is one such!!

Think about the benefits and the cost of platforms like Kubernetes, Nomad, and note it down. Especially for Stateful workloads!

---

Some more thoughts -

Every feature has to be almost perfect and usable, with tests and docs. Can't do all that later. Okay? Basic stuff atleast should be there, the content that is. API docs etc

Mindset?
Simplicity first
API first
Test first
Understandability first

Think about user workflows for a DBaaS service. Think how you used to use databases from Heroku. Check it again now. Check how MongoDB Atlas does it, how RedisLabs does it etc

Create a plan of what features to build first based on the user workflows

For example, a basic workflow is - a user wants to deploy a database and connect their application to it! User upgrading a database is not a basic workflow!!! :P That's big, huge! Atleast I think so. I have also seen others feel the same. But yeah, everything should be easy for the user in any case! With as little problems or headaches.

User deploys database, gets connection details to connect the application to the database. Simple! Let's add some complexity to it! How to secure the database? If any IP can access it, that's problematic! Only the app or expected apps and machines and users should be able to access the database. There has to be some sort of firewall. What about not exposing the database to the public Internet? What if folks want the database in a private network in which the app is present too? What if app and database are on different cloud providers? We have to use some system to connect the two and also put them in the same private network!! :O

What about automatic rotation of credentials? Using something like Vault. I need to create that Redis Vault plugin! :D for generating secrets!

I need to learn Redis ACL for Redis Access Control management to help consumers manage users through a Web UI and internally use Redis ACL

I think I'll build a Redis DBaaS first! Just the product. I don't think I can host it. I'll just create a platform product first. The management layer! :)

Name? Just Manage My DB. Or, Just Manage It. justmanageit.io justmanage.db ;)

For redis operator just work on an imperative implementation. Declarative implantation is just about detecting the imperative action to take based on the declarative instructions from the user. However imperative is gonna stay there. There is gonna be CRUD at some point as cloud APIs and many other APIs work like that and it's also granular control. But yeah, APIs can be declarative too like the popular K8s API. I think Nomad API is declarative too

I think I might use Nomad for my first cut, for my DBaaS! :D

Gotta checkout about storage though. Elastic block storage Open EBS, Ceph, Rook etc

For the management platform, for authentication and authorisation, let's not build from scratch. Let's use ORY, or similar services, like Keycloak, Auth0 (paid), Firebase (paid), Gluu etc

Try reusing tools and services as much as possible, unless you wanna build and learn or surpass existing tools and services, or if existing ones are paid and you wanna try open source and there's none and you wanna build it. Don't do yak shaving though, remember that
