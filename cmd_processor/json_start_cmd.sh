#!/bin/sh
APPCONFIG="/home/wu/Desktop/ion/cmd.json"
THIS_ADDR="ipn:1"
CMD_PORT="1"

#Validating CMD
jq -c '.' ${APPCONFIG} 

if [ $? -ne 0 ]; then
echo "CMD Error!"
exit 1
fi

#res=`jq -c '.' ${APPCONFIG}`
#echo ${res}

#Sending CMD to ION daemon of this node
bpsource ${THIS_ADDR}.${CMD_PORT} `jq -c '.' ${APPCONFIG}`
