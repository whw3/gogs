#!/bin/bash
###############
# User config #
###############
PORT=3000
IP=$(hostname -I| sed -e 's: :\n:g'| grep 192|sort|head -1)

#############
# Functions #
#############
function start {
    if [ "$1" = "" ];then
        [ -e CONTAINER_ID ] && rm CONTAINER_ID  #should be an impossible condition but clean up anyway
        docker run -d --name=gogs \
        -p 127.0.0.1:10022:22 \
        -p $IP:$PORT:3000 \
        -v /srv/gogs/data:/data \
        gogs > CONTAINER_ID
        [ $? -ne 0 ] &&  exit 1
        echo "Started Gogs"        
    else
        docker start $1
        if [ $? -eq 0 ]; then
            echo "Sweet Jesus!!! I've been revived!"
            #docker container inspect $1 
        else
            echo "Removing stale CONTAINER_ID"
            [ -e CONTAINER_ID ] && rm CONTAINER_ID
            start
            if [ $? -ne 0 ]; then
                echo "DAMN! DAMN! DAMN!"
                exit 1
            fi
        fi         
    fi
    exit 0
}
##############
# Begin Main #
##############
cd /srv/gogs
[[ "$(docker images -q gogs 2> /dev/null)" == "" ]] && ./build.sh
CID=$(docker ps |grep "gogs" | cut -d' ' -f1)
if [ "$CID" = "" ]; then
    [ -e CONTAINER_ID ] && CID=$(cut -c1-12 CONTAINER_ID)
    start $CID
    if [ $? -ne 0 ]; then  
        if [ "$CID" = "" ]; then
            echo "DAMN! That sucked"
            exit 1
        fi
    fi
else
    # verify CID
    CONTID=""
    [ -e CONTAINER_ID ] && CONTID=$(cut -c1-12 CONTAINER_ID)
    if [[ $CONTID = $CID* ]]; then
        echo "Gogs already running...nothing to do here"
    else
        echo "I must be confused"
        echo "Killing CONTAINER_ID:$CONTID"
        docker stop $CONTID
        docker rm $CONTID
        echo "Updating CONTAINER_ID:$CID"
        echo $CID > CONTAINER_ID
    fi
fi
exit 0
