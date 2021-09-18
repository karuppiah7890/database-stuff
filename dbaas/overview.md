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
