#!/usr/bin/env python

import sys,os
import fnmatch

#open 9 files for each node

conffilearray = [];

for f in range(1, 10):
   conffilepath = "/home/lchao/ionconfinf/" + str(f) + ".conf";
   conffilearray.append(open(conffilepath, 'w+'));

infofilepath = "/home/lchao/sateliteinfonew.txt";
infofile = open(infofilepath);
satelitenumber = int(infofile.readline().strip());

speed = 100000;
timescale = 1;
addressprefix = "[2000::";
addressport = "]:1113";
contactcollection = [];
rangecollection = [];
contactexist = [[] for i in range(9)];


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

for f in range(1, 10):
   conffilearray[f-1].write("## begin ionadmin \n");
   conffilearray[f-1].write("1 " + str(f) + " " + "''\n");
   conffilearray[f-1].write("s\n");
   conffilearray[f-1].writelines(contactcollection);
   conffilearray[f-1].writelines(rangecollection);
   conffilearray[f-1].write("## end ionadmin \n");
   conffilearray[f-1].write("\n");
   conffilearray[f-1].write("## begin ltpadmin \n");
   conffilearray[f-1].write("1 32\n");
   for p in range(1, 10):
      if(f == p):
         conffilearray[f-1].write("a span " + str(p) + " " + "10 10 1400 10000 1" + " " + "'udplso " + addressprefix + str(p) + addressport + "'\n");
      elif(str(p) in contactexist[f-1]):
         conffilearray[f-1].write("a span " + str(p) + " " + "10 10 1400 10000 1" + " " + "'udplso " + addressprefix + str(p) + addressport + "'\n");
      else:
         continue;
   conffilearray[f-1].write("s 'udplsi " + addressprefix + str(f) + addressport +"'" + "\n");
   conffilearray[f-1].write("## end ltpadmin \n");
   conffilearray[f-1].write("## begin bpadmin \n");
   conffilearray[f-1].write("1\n");
   conffilearray[f-1].write("a scheme ipn 'ipnfw' 'ipnadminep'\n");
   conffilearray[f-1].write("a endpoint ipn:" + str(f) + ".0 q\n");
   conffilearray[f-1].write("a endpoint ipn:" + str(f) + ".1 q\n");
   conffilearray[f-1].write("a protocol ltp 1400 100\n");
   conffilearray[f-1].write("a induct ltp " + str(f) + " ltpcli\n");
   for p in range(1, 10):
      if(f == p):
         conffilearray[f-1].write("a outduct ltp " + str(p) + " ltpclo\n");
      elif(str(p) in contactexist[f-1]):
         conffilearray[f-1].write("a outduct ltp " + str(p) + " ltpclo\n");
      else:
         continue;
   conffilearray[f-1].write("s\n");
   conffilearray[f-1].write("## end bpadmin \n");
   conffilearray[f-1].write("## begin ipnadmin \n");
   for p in range(1, 10):
      if(f == p):
         conffilearray[f-1].write("a plan " + str(p) + " ltp/" + str(p) + "\n");
      elif(str(p) in contactexist[f-1]):
         conffilearray[f-1].write("a plan " + str(p) + " ltp/" + str(p) + "\n");
      else:
         continue;
   conffilearray[f-1].write("## end ipnadmin \n");

for f in range(1, 10):
   conffilearray[f-1].close();
