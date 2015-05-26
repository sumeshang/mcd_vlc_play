#!/usr/bin/python
#Author : sumesh kk
#Date: 29-oct-2012
#purpose : To find the currently working file on vlc player and
#move the file to other directory  use python "file name" commnad to execute

import sys
import os
import re
import string
import shutil
try:
	fh = open ("./tmp")
except:
	print "cant open file tmp"	
lines = fh.read()
results = lines.split('*')
#for line in lines:
#	foo =  line.replace('\n','')
#	results.append(foo)
print "\n The files in tmp file is :\n"
print results
if (len(results) == 2):
	src = results[0].rstrip()
	dest = results[1].rstrip()
	print src,dest	
	print "\nmoving ",src," to ",dest		
	try: 	
		shutil.move(src,dest)	
	except IOError as e:
    		print "I/O error({0}): {1}".format(e.errno, e.strerror)
 
else:
	print "file contents corupted in tmp file: more than two lines"
