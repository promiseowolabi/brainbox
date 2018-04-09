# OpenEMR In Docker

## install

(All these steps are mac only, ill change that later, shouldnt be too hard to figure out other 
operations systems since its all in docker)

1. First, Download OpenEMR from sourceforge:
openemr-4.2.0.tar.gz (MD5 sum: ef8ddb1cead3b5e24f5d579b3cbc8513)
http://sourceforge.net/projects/openemr/files/OpenEMR%20Current/4.2.0/openemr-4.2.0.tar.gz/download

2. Next, Extract the downloaded archive:

tar -pxvzf openemr-4.2.0.tar.gz
    (The -p is important to keep file permissions)

extrat this file into the git repository under the name "openemr"

If on mac ensure boot2docker is installed 
```bash
brew install boot2docker
boot2docker init
boot2docker up
$(boot2docker shellinit)
```

Then install docker-compose
```pip install docker-compose```

then 

```docker-compose up```

from the root of the repository

Access the openemr program from the ip of your boot2docker instance and the port 8080

go through the steps and when asked whether to create or use already created database
use an already created database

Change all ips from localhost to the boot2docker ip on the next screen and ensure 
the database name, user and password are all "openemr"

wait for the DB to build, then have fun

## Accessing the DB
you can use:
```mysql --host=$(boot2docker ip) --user=openemr --password=openemr openemr```

