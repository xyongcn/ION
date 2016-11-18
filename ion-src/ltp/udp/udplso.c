/*
	udplso.c:	LTP UDP-based link service output daemon.
			Dedicated to UDP datagram transmission to
			a single remote LTP engine.

	Author: Scott Burleigh, JPL

	Copyright (c) 2007, California Institute of Technology.
	ALL RIGHTS RESERVED.  U.S. Government Sponsorship
	acknowledged.
	
	7/6/2010, modified as per issue 132-udplso-tx-rate-limit
	Greg Menke, Raytheon, under contract METS-MR-679-0909
	with NASA GSFC.
									*/

#include "udplsa.h"

#if defined(linux)

#define IPHDR_SIZE	(sizeof(struct iphdr) + sizeof(struct udphdr))

#elif defined(mingw)

#define IPHDR_SIZE	(20 + 8)

#else

#include "netinet/ip_var.h"
#include "netinet/udp_var.h"

#define IPHDR_SIZE	(sizeof(struct udpiphdr))

#endif

static sm_SemId		udplsoSemaphore(sm_SemId *semid)
{
	static sm_SemId	semaphore = -1;
	
	if (semid)
	{
		semaphore = *semid;
	}

	return semaphore;
}

static void	shutDownLso()	/*	Commands LSO termination.	*/
{
	sm_SemEnd(udplsoSemaphore(NULL));
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
	char			*buffer;
	int			segmentLength;
	struct sockaddr_storage 	fromAddr;
	socklen_t		fromSize;

	buffer = MTAKE(UDPLSA_BUFSZ);
	if (buffer == NULL)
	{
		putErrmsg("udplsi can't get UDP buffer.", NULL);
		shutDownLso();
		return NULL;
	}

	/*	Can now start receiving bundles.  On failure, take
	 *	down the LSO.						*/
	fd_set rfds;
	struct timeval time_out;
	time_out.tv_sec=1;
	time_out.tv_usec=0;
	int maxfd = rtp->linkSocket;
	int ret;

	iblock(SIGTERM);
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
					shutDownLso();

					/*	Intentional fall-through to next case.	*/

				case 1:				/*	Normal stop.	*/
					rtp->running = 0;
					writeMemo("[i] udplsi receives end signal.");
					continue;
				}

				if (ltpHandleInboundSegment(buffer, segmentLength) < 0)
				{
					putErrmsg("Can't handle inbound segment.", NULL);
					shutDownLso();
					rtp->running = 0;
					continue;
				}

				/*	Make sure other tasks have a chance to run.	*/

				sm_TaskYield();
			}
		}
	}

	writeErrmsgMemos();
	writeMemo("[i] udplso receiver thread has ended.");

	/*	Free resources.						*/

	MRELEASE(buffer);
	return NULL;
}

/*	*	*	Main thread functions	*	*	*	*/

int	sendSegmentByUDP(int linkSocket, char *from, int length,
		struct addrinfo *destAddrinfo )
{
	int	bytesWritten;

	while (1)	/*	Continue until not interrupted.		*/
	{
		bytesWritten = isendto(linkSocket, from, length, 0,
				destAddrinfo->ai_addr, destAddrinfo->ai_addrlen);
		if (bytesWritten < 0)
		{
			if (errno == EINTR)	/*	Interrupted.	*/
			{
				continue;	/*	Retry.		*/
			}

			if (errno == ENETUNREACH)
			{
				return length;	/*	Just data loss.	*/
			}

			{
				char			memoBuf[1000];
				struct sockaddr_in	*saddr = (struct sockaddr_in *)destAddrinfo->ai_addr;

				isprintf(memoBuf, sizeof(memoBuf),
					"udplso sendto() error, dest=[%s:%d], \
nbytes=%d, rv=%d, errno=%d", (char *) inet_ntoa(saddr->sin_addr), 
					ntohs(saddr->sin_port), 
					length, bytesWritten, errno);
				writeMemo(memoBuf);
			}
		}

		return bytesWritten;
	}
}

#if defined (ION_LWT)
int	udplso(int a1, int a2, int a3, int a4, int a5,
	       int a6, int a7, int a8, int a9, int a10)
{
	char		*endpointSpec = (char *) a1;
	unsigned int	txbps = (a2 != 0 ?  strtoul((char *) a2, NULL, 0) : 0);
	uvast		remoteEngineId = a3 != 0 ?  strtouvast((char *) a3) : 0;
#else
int	main(int argc, char *argv[])
{
	char		*endpointSpec = argc > 1 ? argv[1] : NULL;
	unsigned int	txbps = (argc > 2 ?  strtoul(argv[2], NULL, 0) : 0);
	uvast		remoteEngineId = argc > 3 ? strtouvast(argv[3]) : 0;
#endif
	Sdr			sdr;
	LtpVspan		*vspan;
	PsmAddress		vspanElt;
//	struct sockaddr 	bindSockName;
//	socklen_t		nameLength;
	ReceiverThreadParms	rtp;
	pthread_t		receiverThread;
	int			segmentLength;
	char			*segment;
	int			bytesSent;
	float			sleepSecPerBit = 0;
	float			sleep_secs;
	unsigned int		usecs;
//	int			fd;
//	char			quit = '\0';

	if( txbps != 0 && remoteEngineId == 0 )
	{
		remoteEngineId = txbps;
		txbps = 0;
	}

	if (remoteEngineId == 0 || endpointSpec == NULL)
	{
		PUTS("Usage: udplso {<remote engine's host name> | @}[:\
		<its port number>] <txbps (0=unlimited)> <remote engine ID>");
		return 0;
	}

	/*	Note that ltpadmin must be run before the first
	 *	invocation of ltplso, to initialize the LTP database
	 *	(as necessary) and dynamic database.			*/

	if (ltpInit(0) < 0)
	{
		putErrmsg("udplso can't initialize LTP.", NULL);
		return 1;
	}

	sdr = getIonsdr();
	CHKZERO(sdr_begin_xn(sdr));	/*	Just to lock memory.	*/
	findSpan(remoteEngineId, &vspan, &vspanElt);
	if (vspanElt == 0)
	{
		sdr_exit_xn(sdr);
		putErrmsg("No such engine in database.", itoa(remoteEngineId));
		return 1;
	}

	if (vspan->lsoPid != ERROR && vspan->lsoPid != sm_TaskIdSelf())
	{
		sdr_exit_xn(sdr);
		putErrmsg("LSO task is already started for this span.",
				itoa(vspan->lsoPid));
		return 1;
	}

	sdr_exit_xn(sdr);

	/*	All command-line arguments are now validated.  First
	 *	get peer's socket address.				*/
	char ipAddress[50];
	char portNbr[20];
	int retVal;
	if (parseSocketSpecCompat(endpointSpec, ipAddress, portNbr) != 0)
	{
		writeMemoNote("[?] udpclo: can't get induct IP address",
				endpointSpec);
		return -1;
	} else {
		char tmp[200];
		sprintf(tmp, "[i] LSO ductName:%s, ip:%s, port:%s",endpointSpec, ipAddress, portNbr);
		writeMemo(tmp);
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
	  
	struct addrinfo *peer_addrinfo;  
	//获取地址信息  
	retVal=getaddrinfo(ipAddress, portNbr,&addrCriteria,&peer_addrinfo);  
	if(retVal!=0){
		writeMemoNote("getaddrinfo failed!", NULL);
		return -1;
	}
	
	/*	Now create the socket that will be used for sending
	 *	datagrams to the peer LTP engine and receiving
	 *	datagrams from the peer LTP engine.			*/
	//建立socket  
	rtp.linkSocket = socket(peer_addrinfo->ai_family,peer_addrinfo->ai_socktype,peer_addrinfo->ai_protocol);  
	if (rtp.linkSocket < 0)
	{
		putSysErrmsg("LSO can't open UDP socket", NULL);
		return 1;
	}

	int isIpv6 = 0;
	if ( strchr(endpointSpec, '[') )
	{
		isIpv6 = 1;
	}
	/*	Now compute own socket address, used when the peer
	 *	responds to the link service output socket rather
	 *	than to the advertised link service input socket.	*/
	memset(&addrCriteria,0,sizeof(addrCriteria));  
	if (isIpv6)
		addrCriteria.ai_family = AF_INET6;
	else
		addrCriteria.ai_family = AF_INET;
	addrCriteria.ai_flags=AI_PASSIVE;  
	addrCriteria.ai_socktype=SOCK_DGRAM;  
	addrCriteria.ai_protocol=IPPROTO_UDP;  

	struct addrinfo *own_addrinfo;
	retVal = getaddrinfo(NULL, "0", &addrCriteria, &own_addrinfo);
	if(retVal!=0){
		writeMemoNote("getaddrinfo failed!", NULL);
		return 1;
	}
	
	/*	Bind the socket to own socket address so that we can
	 *	send a 1-byte datagram to that address to shut down
	 *	the datagram handling thread.				*/
//	nameLength = sizeof(struct sockaddr);
	if ( bind(rtp.linkSocket,own_addrinfo->ai_addr,own_addrinfo->ai_addrlen) < 0 )
		//|| getsockname(rtp.linkSocket, &bindSockName, &nameLength) < 0)
	{
		closesocket(rtp.linkSocket);
		putSysErrmsg("LSO can't bind UDP socket", NULL);
		return 1;
	}


	/*	Set up signal handling.  SIGTERM is shutdown signal.	*/

	oK(udplsoSemaphore(&(vspan->segSemaphore)));
	signal(SIGTERM, shutDownLso);

	/*	Start the echo handler thread.				*/

	rtp.running = 1;
	if (pthread_begin(&receiverThread, NULL, handleDatagrams, &rtp))
	{
		closesocket(rtp.linkSocket);
		putSysErrmsg("udplsi can't create receiver thread", NULL);
		return 1;
	}

	/*	Can now begin transmitting to remote engine.		*/

	{
		char	memoBuf[1024];

		isprintf(memoBuf, sizeof(memoBuf),
			"[i] udplso is running, spec=[%s:%s], txbps=%d \
(0=unlimited), rengine=%d.", ipAddress, portNbr, txbps, (int) remoteEngineId);
		writeMemo(memoBuf);
	}

	if (txbps)
	{
		sleepSecPerBit = 1.0 / txbps;
	}

	while (rtp.running && !(sm_SemEnded(vspan->segSemaphore)))
	{
		segmentLength = ltpDequeueOutboundSegment(vspan, &segment);
		if (segmentLength < 0)
		{
			rtp.running = 0;	/*	Terminate LSO.	*/
			continue;
		}

		if (segmentLength == 0)		/*	Interrupted.	*/
		{
			continue;
		}

		if (segmentLength > UDPLSA_BUFSZ)
		{
			putErrmsg("Segment is too big for UDP LSO.",
					itoa(segmentLength));
			rtp.running = 0;	/*	Terminate LSO.	*/
		}
		else
		{
			bytesSent = sendSegmentByUDP(rtp.linkSocket, segment,
					segmentLength, peer_addrinfo);
			if (bytesSent < segmentLength)
			{
				rtp.running = 0;/*	Terminate LSO.	*/
			}

			if (txbps)
			{
				sleep_secs = sleepSecPerBit
					* ((IPHDR_SIZE + segmentLength) * 8);
				usecs = sleep_secs * 1000000.0;
				if (usecs == 0)
				{
					usecs = 1;
				}

				microsnooze(usecs);
			}
		}

		/*	Make sure other tasks have a chance to run.	*/

		sm_TaskYield();
	}

	/*	Create one-use socket for the closing quit byte.	*/
/*	fd = socket(own_addrinfo->ai_family,own_addrinfo->ai_socktype,own_addrinfo->ai_protocol);  
	if (fd < 0)
	{
		putSysErrmsg("udplso closing phase: LSO can't open UDP socket", NULL);
		return 1;
	}
	if (fd >= 0)
	{
		writeMemo("LSO:sending end packet .");
		isendto(fd, &quit, 1, 0, &bindSockName, sizeof(struct sockaddr));
		closesocket(fd);
	}
*/
	rtp.running = 0;

//	pthread_cancel(receiverThread);
	pthread_join(receiverThread, NULL);
	closesocket(rtp.linkSocket);
	writeErrmsgMemos();
	writeMemo("[i] udplso has ended.");
	ionDetach();
	return 0;
}
