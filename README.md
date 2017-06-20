# gogs
Official gogs docker image adapted for use with Raspberry Pi.<br/>
Pre-configured to [Share port 22 between Gogs inside Docker & the local system](http://www.ateijelo.com/blog/2016/07/09/share-port-22-between-docker-gogs-ssh-and-local-system)

### Assumptions
* home for docker build images is ***/srv/docker***
* home for docker services is ***/srv/***
* openssh is installed and enabled on the host server

To build the docker image run ***/srv/gogs/build.sh***
```
cd /srv/
git clone https://github.com/whw3/gogs.git
cd gogs
chmod 0700 *.sh
./build.sh
./start.sh
```
### Usage
* use ***/srv/gogs/start.sh*** to start Gogs
* use ***/srv/gogs/stop.sh*** to stop Gogs
* See https://gogs.io/ for more details about Gogs
