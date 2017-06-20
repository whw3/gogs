#!/bin/bash
cd /srv/gogs
CID=""
if [ -e CONTAINER_ID ]; then
    CID=$(cut -c1-12 CONTAINER_ID)
else    
    CID=$(docker ps |grep "gogs" | cut -d' ' -f1)
    echo $CID > CONTAINER_ID
fi
if [ "$CID" = "" ]; then
    echo "Is Gogs really running????"
    exit 1
fi
docker stop $CID
if [ $? -eq 0 ]; then
    read -p "Remove Gogs? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        docker rm $CID
        rm CONTAINER_ID
    fi
else
    rm CONTAINER_ID
    echo "Removed stale CONTAINER_ID"
fi
