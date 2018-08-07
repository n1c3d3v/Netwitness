import pcap
from pcap_reassembler import PcapReassembler, address_to_string
import requests
from requests.auth import HTTPBasicAuth

a = requests.get('http://10.224.208.117:50105/sdk/packets?&sessions=4', auth=HTTPBasicAuth('admin', 'netwitness'))
pcapdec = a.content
print(pcapdec)

#pcapf = open('sample-imf.pcap','r')
pcapf2 = open('pcapdec','w')
#af = pcapf.read()
pcapf2.write(a.content)
pcapf2.close()
#pcapf.close()
pcapp = open('pcapdec','r')
aff = pcapp.read()
pcapp.close() 
print(type(aff))
#print(str(a))
reassembler = PcapReassembler()
messages = reassembler.load_pcap('pcapdec')
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

        # save raw mail as eml file
file = open('test.eml','w')
file.write(result)
file.close()

