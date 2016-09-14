/*
	udplsi.c:	LTP UDP-based link service daemon.

	Author: Scott Burleigh, JPL

	Copyright (c) 2007, California Institute of Technology.
	ALL RIGHTS RESERVED.  U.S. Government Sponsorship
	acknowledged.
	
									*/
#include "udplsa.h"

static void	interruptThread()
{
	isignal(SIGTERM, interruptThread);
	ionKillMainThread("udplsi");
}

/*	*	*	Receiver thread functions	*	*	*/

typedef struct
{
	int		linkSocket;
	int		running;
} ReceiverThreadParms;

static void	*handleDatagrams(void *parm)
{
	/*	Main loop for UDP datagram reception and handling.	*/

	ReceiverThreadParms	*rtp = (ReceiverThreadParms *) parm;
	char			*procName = "udplsi";
	char			*buffer;
	int			segmentLength;
	struct sockaddr_storage	fromAddr;
	socklen_t		fromSize;

	snooze(1);	/*	Let main thread become interruptable.	*/
	buffer = MTAKE(UDPLSA_BUFSZ);
	if (buffer == NULL)
	{
		putErrmsg("udplsi can't get UDP buffer.", NULL);
		ionKillMainThread(procName);
		return NULL;
	}

	/*	Can now start receiving bundles.  On failure, take
	 *	down the LSI.						*/
	fd_set rfds;
	struct timeval time_out;
	time_out.tv_sec=1;
	time_out.tv_usec=0;
	int maxfd = rtp->linkSocket;
	int ret;

	while (rtp->running)
	{	
		FD_ZERO(&rfds);
		FD_SET(rtp->linkSocket, &rfds);
		ret = select(maxfd+1, &rfds, NULL, NULL, &time_out);
		if(ret < 0){
			perror("*********select return SOCKET_ERROR**********\n");
			exit(0);
		} else if(ret == 0){
//			pthread_testcancel();
		} else {
			if (FD_ISSET(rtp->linkSocket, &rfds)){
				fromSize = sizeof fromAddr;
				segmentLength = irecvfrom(rtp->linkSocket, buffer, UDPLSA_BUFSZ,
						0, (struct sockaddr *) &fromAddr, &fromSize);
				switch (segmentLength)
				{
				case -1:
					putSysErrmsg("Can't acquire segment", NULL);
					ionKillMainThread(procName);
				
					/*	Intentional fall-through to next case.	*/
				
				case 1: 			/*	Normal stop.	*/
					rtp->running = 0;
					writeMemo("[i] udplsi receives end signal.");
					continue;
				}

				if (ltpHandleInboundSegment(buffer, segmentLength) < 0)
				{
					putErrmsg("Can't handle inbound segment.", NULL);
					ionKillMainThread(procName);
					rtp->running = 0;
					continue;
				}

				/*	Make sure other tasks have a chance to run.	*/

				sm_TaskYield();
			}
		}
	}

	writeErrmsgMemos();
	writeMemo("[i] udplsi receiver thread has ended.");

	/*	Free resources.						*/

	MRELEASE(buffer);
	return NULL;
}

/*	*	*	Main thread functions	*	*	*	*/

#if defined (ION_LWT)
int	udplsi(int a1, int a2, int a3, int a4, int a5,
		int a6, int a7, int a8, int a9, int a10)
{
	char	*endpointSpec = (char *) a1;
#else
int	main(int argc, char *argv[])
{
	char	*endpointSpec = (argc > 1 ? argv[1] : NULL);
#endif
	LtpVdb			*vdb;
//	unsigned short		portNbr = 0;
//	unsigned int		ipAddress = INADDR_ANY;
	char ipAddress[50];
	char portNbr[20];
	int retVal;
//	struct sockaddr		socketName;
//	struct sockaddr_in	*inetName;
	ReceiverThreadParms	rtp;
//	socklen_t		nameLength;
	pthread_t		receiverThread;
//	int			fd;
//	char			quit = '\0';
	*ipAddress = '\0';
	*portNbr = '\0';

	/*	Note that ltpadmin must be run before the first
	 *	invocation of ltplsi, to initialize the LTP database
	 *	(as necessary) and dynamic database.			*/ 

	if (ltpInit(0) < 0)
	{
		putErrmsg("udplsi can't initialize LTP.", NULL);
		return 1;
	}

	vdb = getLtpVdb();
	if (vdb->lsiPid != ERROR && vdb->lsiPid != sm_TaskIdSelf())
	{
		putErrmsg("LSI task is already started.", itoa(vdb->lsiPid));
		return 1;
	}

	/*	All command-line arguments are now validated.		*/

	if (endpointSpec)
	{
		if(parseSocketSpecCompat(endpointSpec, ipAddress, portNbr) != 0)
		{
			putErrmsg("Can't get IP/port for endpointSpec.",
					endpointSpec);
			return -1;
		} else {
			char tmp[200];
			sprintf(tmp, "[i] LSI ductName:%s, ip:%s, port:%s",endpointSpec, ipAddress, portNbr);
			writeMemo(tmp);
		}
	} else {
		writeMemo("LSI: endpointSpec is NULL");
	}

	if (*portNbr == '\0')
	{
		sprintf(portNbr, "%d", LtpUdpDefaultPortNbr);
	}

	//配置地址信息   
	struct addrinfo addrCriteria;  
	memset(&addrCriteria,0,sizeof(addrCriteria));  
	addrCriteria.ai_family=AF_UNSPEC;  
	addrCriteria.ai_flags=AI_PASSIVE;  
	addrCriteria.ai_socktype=SOCK_DGRAM;  
	addrCriteria.ai_protocol=IPPROTO_UDP;  
	  
	struct addrinfo *server_addrinfo;  
	//获取地址信息  
	retVal=getaddrinfo(ipAddress, portNbr,&addrCriteria,&server_addrinfo);  
	if(retVal!=0){
		writeMemoNote("***********LSI: getaddrinfo failed!***********", NULL);
		return -1;
	}
	
	/*	Now create the socket that will be used for sending
	 *	datagrams to the peer LTP engine and receiving
	 *	datagrams from the peer LTP engine.			*/
	//建立socket  
	rtp.linkSocket = socket(server_addrinfo->ai_family,server_addrinfo->ai_socktype,server_addrinfo->ai_protocol);  
	if (rtp.linkSocket < 0)
	{
		putSysErrmsg("LSI can't open UDP socket", NULL);
		return 1;
	}

	if ( endpointSpec && strchr(endpointSpec, '[') )
	{
		int sin6_scope_id = parseScopeId(ipAddress); //IPV6_ADDR_MC_SCOPE(&((struct sockaddr_in6 *)server_addr->ai_addr)->sin6_addr);
		if(sin6_scope_id < 0)
		{
			writeMemoNote("Unspported ipv6 addr!", NULL);
			return -1;
		} else 
			writeMemoNote("sin6_scope_id", itoa(sin6_scope_id));
		((struct sockaddr_in6 *) server_addrinfo->ai_addr)->sin6_scope_id = sin6_scope_id;
	}


//	nameLength = sizeof(struct sockaddr);
	if (reUseAddress(rtp.linkSocket)
	|| bind(rtp.linkSocket,server_addrinfo->ai_addr,server_addrinfo->ai_addrlen) < 0 )
	//|| getsockname(rtp.linkSocket, &socketName, &nameLength) < 0)
	{
		closesocket(rtp.linkSocket);
		putSysErrmsg("Can't initialize socket", NULL);
		return 1;
	}

	/*	Set up signal handling; SIGTERM is shutdown signal.	*/

	ionNoteMainThread("udplsi");
	isignal(SIGTERM, interruptThread);

	/*	Start the receiver thread.				*/

	rtp.running = 1;
	if (pthread_begin(&receiverThread, NULL, handleDatagrams, &rtp))
	{
		closesocket(rtp.linkSocket);
		putSysErrmsg("udplsi can't create receiver thread", NULL);
		return 1;
	}

	/*	Now sleep until interrupted by SIGTERM, at which point
	 *	it's time to stop the link service.			*/

	{
		char	txt[500];

		isprintf(txt, sizeof(txt),
			"[i] udplsi is running, spec=[%s:%s].", 
			ipAddress, portNbr);
		writeMemo(txt);
	}
	ionPauseMainThread(-1);

	/*	Time to shut down.					*/
	rtp.running = 0;

	/*	Wake up the receiver thread by sending it a 1-byte
	 *	datagram.						*/

/*	fd = socket(server_addrinfo->ai_family,server_addrinfo->ai_socktype,server_addrinfo->ai_protocol);  
	if (fd >= 0)
	{
		writeMemo("LSI:sending end packet .");
		isendto(fd, &quit, 1, 0, &socketName, sizeof(struct sockaddr));
		closesocket(fd);
  	} else	{
		putSysErrmsg("LSI can't open UDP socket for closing procedure!!", NULL);
		return 1;
	}
*/

//	pthread_cancel(receiverThread);
	pthread_join(receiverThread, NULL);
	closesocket(rtp.linkSocket);
	writeErrmsgMemos();
	writeMemo("[i] udplsi has ended.");
	ionDetach();
	return 0;
}
