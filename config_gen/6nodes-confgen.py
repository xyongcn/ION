#!/usr/bin/env python

import sys,os
import fnmatch

#open 9 files for each node

conffilearray = [];

for f in range(4, 10):
   conffilepath = "/Users/lchao/Documents/ION/ionconf/" + str(f) + ".conf";
   conffilearray.append(open(conffilepath, 'w+'));

infofilepath = "/Users/lchao/Documents/ION/sateliteinfo.txt";
addrfilepath = "/Users/lchao/Documents/ION/addressassign.txt";
infofile = open(infofilepath);
satelitenumber = int(infofile.readline().strip());
addrfile = open(addrfilepath);


speed = 100000;
timescale = 1;
addressport = 1113;
contactcollection = [];
rangecollection = [];
contactexist = [[] for i in range(9)];
addresspool = [[] for i in range(9)];


for n in range(1, satelitenumber+1):
   infofile.readline();

while True:
   contactinfoline = infofile.readline();
   if len(contactinfoline)==0:
      break;
   else:
      contactinfo = contactinfoline.strip().split(" ");
      sourcenode = contactinfo[0];
      destnode = contactinfo[1];

      recordnumber = int(contactinfo[2]);

      if(sourcenode == "1" or sourcenode == "2" or sourcenode == "3"):
         for i in range(1, recordnumber + 1):
            infofile.readline();
         continue;

      if(destnode  == "1" or destnode == "2" or destnode == "3"):
         for i in range(1, recordnumber + 1):
            infofile.readline();
         continue;

      contactexist[int(sourcenode)-1].append(destnode);
      contactexist[int(destnode)-1].append(sourcenode);
      for r in range(1, recordnumber +1):
         contactrecord = infofile.readline().strip();
         recorddetail = contactrecord.split(" ");
         if(int(recorddetail[0] == "0")):
            recordstring = "a contact " + "+1 " + "+" + str(int(round(float(recorddetail[1])/timescale))) + " " + sourcenode + " " + destnode + " " + str(speed) + "\n";
            rangestring = "a range " + "+1 " + "+" + str(int(round(float(recorddetail[1])/timescale))) + " " + sourcenode + " " + destnode + " " + "1" + "\n";
         else:
            recordstring = "a contact " + "+" + str(int(round(float(recorddetail[0])/timescale))) + " " + "+" + str(int(round(float(recorddetail[1])/timescale))) + " " + sourcenode + " " + destnode + " " + str(speed) + "\n";
            rangestring = "a range " + "+" + str(int(round(float(recorddetail[0])/timescale))) + " " + "+" + str(int(round(float(recorddetail[1])/timescale))) + " " + sourcenode + " " + destnode + " " + "1" + "\n";
         contactcollection.append(recordstring);
         rangecollection.append(rangestring);
         #reverse
         if(int(recorddetail[0] == "0")):
            recordstring = "a contact " + "+1 " + "+" + str(int(round(float(recorddetail[1])/timescale))) + " " + destnode + " " + sourcenode + " " + str(speed) + "\n";
         else:
            recordstring = "a contact " + "+" + str(int(round(float(recorddetail[0])/timescale))) + " " + "+" + str(int(round(float(recorddetail[1])/timescale))) + " " + destnode + " " + sourcenode + " " + str(speed) + "\n";
         contactcollection.append(recordstring);

for n in range(1, 10):
   for r in range(1, 10):
      addresspool[n-1].append('0');

while True:
   addressinfoline = addrfile.readline();
   if len(addressinfoline)==0:
      break;
   else:
      addressinfo = addressinfoline.strip().split(" ");
      addressnode = int(addressinfo[0]);
      addressnumber = int(addressinfo[1]);
      
      if(addressnode == "1" or addressnode == "2" or addressnode == "3"):
         for i in range(1, addressnumber + 1):
            addrfile.readline();
         continue;

      for p in range(0, addressnumber):
         addressdetail = addrfile.readline().strip().split(" ");
         remotenode = int(addressdetail[0]);
         remoteaddress = addressdetail[1];
         if(remotenode == "1" or remotenode == "2" or remotenode == "3"):
            continue;
         addresspool[addressnode-1][remotenode-1] =  remoteaddress;
      

for f in range(4, 10):
   conffilearray[f-4].write("## begin ionadmin \n");
   conffilearray[f-4].write("1 " + str(f) + " " + "''\n");
   conffilearray[f-4].write("s\n");
   conffilearray[f-4].writelines(contactcollection);
   conffilearray[f-4].writelines(rangecollection);
   conffilearray[f-4].write("## end ionadmin \n");
   conffilearray[f-4].write("\n");
   conffilearray[f-4].write("## begin ltpadmin \n");
   conffilearray[f-4].write("1 32\n");
   for p in range(4, 10):
      if(f == p):
         for k in range(4, 10):
            if addresspool[f-1][k-1] == '0':
               continue;
            else:
               break;
         conffilearray[f-4].write("a span " + str(p) + " " + "10 10 1400 10000 1" + " " + "'udplso " + addresspool[f-1][k-1] + ":" + str(addressport + k - 1) + "'\n");
      elif(str(p) in contactexist[f-1]):
         conffilearray[f-4].write("a span " + str(p) + " " + "10 10 1400 10000 1" + " " + "'udplso " + addresspool[p-1][f-1] + ":" + str(addressport + f - 1) + "'\n");
      else:
         continue;
   for p in range(4, 10):
      if(str(p) in contactexist[f-1]):
         conffilearray[f-4].write("s 'udplsi " + addresspool[f-1][p-1] + ":" + str(addressport + p-1) +"'" + "\n");
   conffilearray[f-4].write("## end ltpadmin \n");
   conffilearray[f-4].write("## begin bpadmin \n");
   conffilearray[f-4].write("1\n");
   conffilearray[f-4].write("a scheme ipn 'ipnfw' 'ipnadminep'\n");
   conffilearray[f-4].write("a endpoint ipn:" + str(f) + ".0 q\n");
   conffilearray[f-4].write("a endpoint ipn:" + str(f) + ".1 q\n");
   conffilearray[f-4].write("a protocol ltp 1400 100\n");
   conffilearray[f-4].write("a induct ltp " + str(f) + " ltpcli\n");
   for p in range(4, 10):
      if(f == p):
         conffilearray[f-4].write("a outduct ltp " + str(p) + " ltpclo\n");
      elif(str(p) in contactexist[f-1]):
         conffilearray[f-4].write("a outduct ltp " + str(p) + " ltpclo\n");
      else:
         continue;
   conffilearray[f-4].write("s\n");
   conffilearray[f-4].write("## end bpadmin \n");
   conffilearray[f-4].write("## begin ipnadmin \n");
   for p in range(4, 10):
      if(f == p):
         conffilearray[f-4].write("a plan " + str(p) + " ltp/" + str(p) + "\n");
      elif(str(p) in contactexist[f-1]):
         conffilearray[f-4].write("a plan " + str(p) + " ltp/" + str(p) + "\n");
      else:
         continue;
   conffilearray[f-4].write("## end ipnadmin \n");

for f in range(4, 10):
   conffilearray[f-4].close();