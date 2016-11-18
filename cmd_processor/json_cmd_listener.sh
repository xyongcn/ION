#!/bin/sh
THIS_ADDR="ipn:1"
CMD_PORT="1"

while [ 1 ]
do
	cmd=`bpsink ${THIS_ADDR}.${CMD_PORT}`
	###Validating CMD
	echo ${cmd} | jq '.' 
	if [ $? -ne 0 ]; then
		echo "CMD Error!"
		continue
	fi
	echo next

	###processing CMD
	##CMD--Retrieval
	tmp=`echo ${cmd} | jq -c '.retrieval'`
	if [ "$tmp" != "null" ]; then
		##retrieval
		#If this node is the cmd sender, then 
		#	send this cmd to the destination
		#else if this node is the cmd executor, then
		#	excute the cmd and send replying
		SADDR=`echo ${cmd} | jq -c '.retrieval.saddr'`
		SADDR=`echo ${SADDR} | sed 's/\"//g'`
		
		DADDR=`echo ${cmd} | jq -c '.retrieval.daddr'`
		DADDR=`echo ${DADDR} | sed 's/\"//g'`
		
		RECVPORT=`echo ${cmd} | jq -c '.retrieval.recv_port'`
		RECVPORT=`echo ${RECVPORT} | sed 's/\"//g'`
		
		REQUEST_FILE=`echo ${cmd} | jq -c '.retrieval.file'`
		REQUEST_FILE=`echo ${REQUEST_FILE} | sed 's/\"//g'`
		
		if [ "$SADDR" = "$THIS_ADDR" ]; then
			echo bpsource ${DADDR}.${CMD_PORT} ${cmd}
			bpsource ${DADDR}.${CMD_PORT} ${cmd}
		elif [ "$DADDR" = "$THIS_ADDR" ]; then
			#Checking the requested file
			FILE_VALID=1
			if [ -f $REQUEST_FILE ]; then
				echo bpsendfile ${THIS_ADDR}.${CMD_PORT} ${SADDR}.${RECVPORT} ${REQUEST_FILE}
				bpsendfile ${THIS_ADDR}.${CMD_PORT} ${SADDR}.${RECVPORT} ${REQUEST_FILE}
				FILE_VALID=1
			else
				echo "File not exist!"
				FILE_VALID=-1
			fi
			#Sending replying
			echo "Replying!"
			echo bpsource ${SADDR}.${CMD_PORT} {\"replying\":{\"retrieval\":\"${FILE_VALID}\"\,\"port\":\"${RECVPORT}\"}}
			bpsource ${SADDR}.${CMD_PORT} {\"replying\":{\"retrieval\":\"${FILE_VALID}\"\,\"port\":\"${RECVPORT}\"}}
		fi		
	fi
	
	##CMD--Replying
	tmp=`echo ${cmd} | jq -c '.replying'`
	if [ "$tmp" != "null" ]; then
		RECVPORT=`echo ${cmd} | jq -c '.replying.port'`
		RECVPORT=`echo ${RECVPORT} | sed 's/\"//g'`
		
		bprecvfile ${THIS_ADDR}.${RECVPORT} 1

	fi
done
