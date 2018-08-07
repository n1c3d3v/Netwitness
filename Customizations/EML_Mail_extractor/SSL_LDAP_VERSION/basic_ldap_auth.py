import ldap
 
def lpa():
  	ldap_server="10.224.210.11"
	username = "aguy"
	password= "Password123!"
	# the following is the user_dn format provided by the ldap server
	user_dn = "CN="+username+",CN=Users,DC=lab,DC=local"
	# adjust this to your base dn for searching
	base_dn = "dc=lab,dc=local"
	connect = ldap.open(ldap_server)
	search_filter = "uid="+username
	try:
		#if authentication successful, get the full user data
		connect.bind_s("aguy@lab.local",password)
		#result = connect.search_s(base_dn,ldap.SCOPE_SUBTREE,search_filter)
		# return all user data results
		
		ldap_result = connect.search(base_dn, ldap.SCOPE_SUBTREE, "(&(objectClass=Person)(cn=ann))", None)
		res_type, data = connect.result(ldap_result, 0)
		print(data)
		connect.unbind_s()
		#print result
	except ldap.LDAPError as e:
		connect.unbind_s()
		print e
		return 1


lpa()
