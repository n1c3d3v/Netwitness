import pcap
from pcap_reassembler import PcapReassembler, address_to_string 
import requests
from requests.auth import HTTPBasicAuth

a = requests.get('http://10.224.208.117:50105/sdk/packets?&sessions=4', auth=HTTPBasicAuth('admin', 'netwitness'))
pcapdec = a.content


reassembler = PcapReassembler() 
messages = reassembler.load_pcap(pcapdec) 
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
#write to file
file = open('extrected.eml','w') 
file.write(result) 
file.close()
