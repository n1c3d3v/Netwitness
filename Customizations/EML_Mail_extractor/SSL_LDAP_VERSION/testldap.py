
## Author: Simon Brennan
## This will literally vomit all the entries in your ldap onto the screen :)
## Useful for automating things linked to LDAP.

import ldap

## first you must open a connection to the server
try:
	l = ldap.open("10.224.210.11",389)
	## searching doesn't require a bind in LDAP V3.  If you're using LDAP v2, set the next line appropriately
	## and do a bind as shown in the above example.
	# you can also set this to ldap.VERSION2 if you're using a v2 directory
	# you should  set the next option to ldap.VERSION2 if you're using a v2 directory
	l.protocol_version = ldap.VERSION2
	l.simple_bind_s("Administrator@lab.local", "Password123!")	
except ldap.LDAPError, e:
	print e
	# handle error however you like


## The next lines will also need to be changed to support your search requirements and directory
baseDN = "cn=Users,dc=lab,dc=local"
searchScope = ldap.SCOPE_SUBTREE
## retrieve all attributes - again adjust to your needs - see documentation for more options
retrieveAttributes = None
searchFilter = "objectclass=person"

#Get a list of everyone in LDAP 

try:
        entries = 0
        ldap_result_id = l.search(baseDN, searchScope, searchFilter, retrieveAttributes)
        result_set = []
        while 1:
                result_type, result_data = l.result(ldap_result_id, 0)
                if (result_data == []):
                        break
                else:
                        ## here you don't have to append to a list
                        ## you could do whatever you want with the individual entry
                        ## The appending to list is just for illustration. 
                        if result_type == ldap.RES_SEARCH_ENTRY:
				result_set.append(result_data)
				#print result_set
                        entries = entries + 1
        #print result_set
        #print entries

except ldap.LDAPError, e:
        print e

print "\n\n"

for i in range(len(result_set)):
#	for entry in result_set[i]:
#		uid = entry[1]['uid'][0]
#		name = entry[1]['cn'][0]
#                email = entry[1]['mail'][0]
#                phone = entry[1]['telephoneNumber'][0]
#                desc = entry[1]['description'][0]
#		#print uid + "\n"
#		print name + "\n"


	print result_set[i][0][1]['memberOf']
