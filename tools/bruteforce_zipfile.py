#!/usr/bin/python
import zipfile
import optparse
from threading import Thread

def extractZip(zfile, password):
	try:
		zfile.extractall(pwd=password)
		print "\n[+] Found password : " + password + "\n"
	except:
		pass

def main():
	parser = optparse.OptionParser("usage %prog -f <zipfile> -d <dictionary>")

	parser.add_option('-f', dest='zname', type='string', help='specify zip file')
	parser.add_option('-d', dest='dname', type='string', help='specify dictionary file')

	(options, arg) = parser.parse_args()

	if (options.zname == None) | (options.dname == None):
		print parser.usage
		exit(0)
	else:
		zname = options.zname
		dname = options.dname

	try:
		zFile = zipfile.ZipFile(zname)
		passFile = open(dname)

		for line in passFile.readlines():
			password = line.strip('\n')
			Thread(target=extractZip, args=(zFile, password)).start()
	except:
		print "Unable to find your file"

if __name__ == '__main__':
	main()
