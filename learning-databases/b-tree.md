B Tree

https://en.m.wikipedia.org/wiki/B-tree

https://ysangkok.github.io/js-clrs-btree/btree.html

http://ysangkok.github.io/js-clrs-btree/btree.html#{%22actions%22:[[%22initTree2%22,{%22keys%22:[1,2,3]}],[%22insert%22,4],[%22insert%22,5],[%22insert%22,6],[%22insert%22,7]]}

https://www.cs.usfca.edu/~galles/visualization/BTree.html

https://cis.stvincent.edu/html/tutorials/swd/btree/btree.html

---

I was looking at this video to understand some basics

https://www.youtube.com/watch?v=TOb1tuEZ2X4

It was good!

This is another nice video - https://youtu.be/aZjYr87r1b8 !

Some questions on the top of my mind
- How are disk blocks and files related? Since everything on systems are stored in the form of files on the disk
- What is the size of the disk block on a system? How do I find it? For example on Linux, or MacOS, or Windows.
- Do Databases find the system's disk block size? and then accordingly store the data on the disk? Using files that is
- Is disk block based on the disk? or the system? Like, operating system / kernel. Or is it based on the file system?
- Do databases store all their data in a single file?

I'm also wondering how databases work on data concurrently, I mean, if there are multiple cores used by the database program, or if there are multiple instances of the database program each using one core, or even multiple cores. Things seem to get pretty complicated. I guess multiple instances of the database program would mean a distributed system, and hence a distributed database. For one database program using multiple cores and all data in the same system - I'm wondering how requests are concurrently handled. How things work, like locks, transactions etc. There are also different kinds of transactions - 2 phase commit etc etc. Sounds pretty complicated to do all of that stuff when you have to first read from the disk and store it in memory and also ensure that the data is not dirty - some other request updating it concurrently on the disk after finishing processing in the memory. Phew.


