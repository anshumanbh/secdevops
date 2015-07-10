#!/bin/bash
echo Hello World

set -e

WEBCONTAINERID=$(docker run -d -P --name web training/webapp python app.py)
echo Container ID = $WEBCONTAINERID

WEBDOCKERIP=$(docker inspect $WEBCONTAINERID | grep -w IPAddress | sed 's/.*IPAddress": "//' | sed 's/",$//')
echo Webapp Docker IP = $WEBDOCKERIP

WEBDOCKERPORT=$(docker port $WEBCONTAINERID | sed 's/\/tcp.*//')
echo Webapp Docker Port = $WEBDOCKERPORT

ZAPCONTAINERID=$(docker run -d --name zap test python /zap/ZAP_2.4.0/runzap.py http://$WEBDOCKERIP:$WEBDOCKERPORT)
echo ZAP Container ID = $ZAPCONTAINERID

STATUS=$(docker inspect $ZAPCONTAINERID | grep Running | sed 's/"Running"://' | sed 's/,//')
flag="1"

while [ "$flag" = "1" ]; do
if [ $STATUS == "true" ];
	then 	
		sleep 5
		echo ZAP is running..
		flag=1
		STATUS=$(docker inspect $ZAPCONTAINERID | grep Running | sed 's/"Running"://' | sed 's/,//') 
	else
		sleep 5
		echo ZAP has stopped
		flag=0
		STATUS=$(docker inspect $ZAPCONTAINERID | grep Running | sed 's/"Running"://' | sed 's/,//')
fi
done

echo Copying the report to host in the current directory with the name report.xml 
docker cp $ZAPCONTAINERID:/zap/ZAP_2.4.0/report.xml .

echo Deleting the ZAP Container
docker rm $ZAPCONTAINERID

if [ $? -eq 0 ]
then 
	echo Stopping the Webapp Container
	docker stop $WEBCONTAINERID
fi

if [ $? -eq 0 ]
then 
	echo Deleting the Webapp Container
	docker rm $WEBCONTAINERID
fi
