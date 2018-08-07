import BaseHTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler
import sys
import os
import base64
import ssl
import SocketServer
import re
import ldap

key = base64.b64encode("fred:pass")
CERTFILE_PATH = "server.crt"
encodpass = None
#fla = False
global fla
fla = None
def lpa(username,password):
  	#global fla
	ldap_server="10.224.210.11"
		# the following is the user_dn format provided by the ldap server
	user_dn = "CN="+username+",CN=Users,DC=lab,DC=local"
	# adjust this to your base dn for searching
	base_dn = "dc=lab,dc=local"
	connect = ldap.open(ldap_server)
	search_filter = "uid="+username
	try:
		#if authentication successful, get the full user data
		connect.bind_s(username,password)
		#result = connect.search_s(base_dn,ldap.SCOPE_SUBTREE,search_filter)
		# return all user data results
		
		ldap_result = connect.search(base_dn, ldap.SCOPE_SUBTREE, "(&(objectClass=Person)(cn=ann))", None)
		res_type, data = connect.result(ldap_result, 0)
		print(data)
		connect.unbind_s()
		#print result
		print "ldap rodou na moral"
		print username
		fla = True
		return True
	except ldap.LDAPError as e:
		connect.unbind_s()
		print "ldap nao rodou na moral"
		print e
		print username
		print password
		fla = False
		return False

	







class AuthHandler(SimpleHTTPRequestHandler):
    ''' Main class to present webpages and authentication. '''
    def do_HEAD(self):
        print "send header"
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_AUTHHEAD(self):
        print "send header"
        self.send_response(401)
        self.send_header('WWW-Authenticate', 'Basic realm=\"Test\"')
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        #global key
        #base64.b64decode(key)
	''' Present frontpage with user authentication. '''
        
	
	#encodpass = str(self.headers.getheader('Authorization'))
	#verify = base64.b64decode(encodpass)
        #decodpass = base64.b64decode(encodpass.split(" ")[0])
        #userpass  = decodpass.split(":")
        #print(encodepass)
	#print(verify)
	#print(decodpass)
	#print(userpass)
	#lpa(userpass[0],userpass[1])
	
        if self.headers.getheader('Authorization') == None:
            self.do_AUTHHEAD()
            self.wfile.write('no auth header received')
	    pass
	
	
	elif self.headers.getheader('Authorization') is not None:
            
	    encodpass = str(self.headers.getheader('Authorization'))
            #verify = base64.b64decode(encodpass)
            decodpass = base64.b64decode(encodpass.split(" ")[1])
            userpass  = decodpass.split(":")
            #print(encodpass)
            #print(verify)
            #print(decodpass)
            #print(userpass)
            lpa(userpass[0],userpass[1])
	    #self.wfile.write(userpass)	
            
	    #if fla == True:
	    SimpleHTTPRequestHandler.do_GET(self)
            #print(encodpass)
	    pass
        else:
            self.do_AUTHHEAD()
            self.wfile.write(self.headers.getheader('Authorization'))
            self.wfile.write('not authenticated')
            pass
	
	#encodpass = self.headers.getheader('Authorization').split(" ")
	#decodpass = base64.b64decode(encodpass[1])
	#userpass  = decodpass.split(":")
	#lpa(userpass[0],userpass[1])

	



httpd = BaseHTTPServer.HTTPServer(('10.224.210.10', 8988), AuthHandler)
httpd.socket = ssl.wrap_socket (httpd.socket, keyfile='./server.key' ,certfile='./server.crt', server_side=True)
httpd.serve_forever()
