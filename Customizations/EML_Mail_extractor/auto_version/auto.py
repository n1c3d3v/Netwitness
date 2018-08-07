#!/usr/bin/env python

import os
import json
import requests
from requests.auth import HTTPBasicAuth
import pcap
from pcap_reassembler import PcapReassembler, address_to_string 
import sys	

def mail_extractor(pcapname,filename):
	try:
	
		reassembler = PcapReassembler() 
		messages = reassembler.load_pcap(pcapname) 
		listt = [] 
		i = 0 

		for i in range(len(messages)):
	
			if ("From: " in messages[i].payload and "\r\n.\r\n" in messages[i].payload):
		       		result = messages[i].payload
		       
		       		break
			if ("From: " in messages[i].payload or "DATA" in messages[i].payload) and "\r\n.\r\n" not in messages[i].payload:
				result = str(messages[i].payload)
		
				while "\r\n.\r\n" not in messages[i].payload:
					i = i + 1
					result = result + str(messages[i].payload)
				break
			
			
	#write to file only if result exists
		
		
		#if result == False:	
		#	print('arquivo relacionado a sessao ' + filename + ' nao foi criado pois o payload esta cagado')
			
		
		#else:	
		file = open(filename + '.eml','w') 
		file.write(result) 
		file.close()
		result=''
		print('arquivo relacionado a sessao ' + filename + ' foi criado')
		#else:
		#	print('result zoado')
	except Exception as e:
		pass
		print(e)


def pcap_extractor(sessionid):

        a = requests.post('http://10.224.208.117:50105/sdk/packets?&sessions=' + str(sessionid), auth=HTTPBasicAuth('admin', 'netwitness'))
        a = requests.get('http://10.224.208.117:50105/sdk/packets?&sessions=' + str(sessionid), auth=HTTPBasicAuth('admin', 'netwitness'))
        pcapdec = a.content
        # Save the pcap to be loaded on the reassembler function
        basepcap = 'testete.pcap'
        file = open(basepcap, 'w').close()
        file = open(basepcap, 'w')
        file.write(pcapdec)
        file.close()


        # send pcap to be parsed and after that save the raw mail as eml file
        mail_extractor(basepcap,str(sessionid))


try:
	#os.remove('*.eml')
	b = requests.post('http://10.224.208.117:50105/sdk?msg=query&query=select+sessionid+where+service=25&force-content-type=application/json', auth=HTTPBasicAuth('admin', 'netwitness'))
	#b = requests.get('http://10.224.208.117:50105/sdk?msg=query&query=select+sessionid+where+' + str(raw_input('digite a query desejada\n')) + '&force-content-type=application/json', auth=HTTPBasicAuth('admin', 'netwitness'))
	b = requests.get('http://10.224.208.117:50105/sdk?msg=query&query=select+sessionid+where+' + "service=25" + '&force-content-type=application/json', auth=HTTPBasicAuth('admin', 'netwitness'))
	#obj = json.loads(b.content)[0]


	for res in range(len(json.loads(b.content))):
		obj = json.loads(b.content)[res]
		for val in range(len(obj['results']['fields'])):
			#print(val)
			pcap_extractor(int(str(obj['results']['fields'][val]['value'])))
	#print(sys.argv[1])

except Exception as e:
	
        print(e)
	
	#if 'range' in str(e):
	#	print('coloque um argumento quando executar o script nao coloque espacos. \nEX: ./auto.py <query>')
	#if str(0) in str(e):
	#	print('digite uma query valida e sem espacos. \n EX: service=25 ') 
	#else:
	#	pass
	#exit
	#print(e)
