What would one need to do to create a DBaaS? 🤔

Surely it has to be an End to End thing. For example, a good Web UI for someone to quickly click a button and get a Database. Users of the DBaaS should be aware of security issues in the DB and should be able to do quick updates at the click of a button - or be able to tell that updates can be automatic, but of course this is assuming that there is no downtime to the database version upgrades / other updates (configuration, side components etc). But yeah, breaking changes cannot happen in the upgrades - so only for vulnerability fix or bug fix updates, one could do patch version upgrades automatically if user desires it. Minor version or major version automatic upgrades - big no no I guess, especially when there's drastic changes including breaking changes in major version upgrades. So, the user of course gets to decide and choose what version they use and when and how to upgrade too - manual / automatic. Manual simply means they gotta click a button. Automatic - it's just automatic, but again, users get to say when the upgrades can happen / should happen - for example, not during peak traffic hours, with the fear that if something goes wrong, it could go terribly wrong for a lot of users, etc. I guess manual vs automatic is not a great distinction, something to think more about. But in any case, user should have complete control, and DBaaS should just act on it with the user's instructions in it's mind, for example, an instruction could be like "Upgrade patch versions automatically only on Sundays from 2 am IST to 3 am IST"

Status page / high level monitoring page for "db is up" or "db is down"

monitoring dashboards for CPU, Memory, Disk and many other DB specific details. For example, for redis - number of keys present, biggest keys, etc

Upgrades, Downgrades

Support many platforms - Kubernetes, Nomad, plain old VMs
Use pre-defined container images for container orchestration platforms, use pre-defined artifacts with binaries for VMs or use VM images
