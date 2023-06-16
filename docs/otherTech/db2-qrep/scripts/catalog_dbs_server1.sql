# Use this script to catalog the databases for local and remmote access

# Change server1 to the desired node name, and db2server1 to the instance name
CATALOG LOCAL NODE server1 INSTANCE db2server1

# Change server2 to the desire node name, db-ip-2 to the ip address of server2.
# 25010 to the port number of the database instance on server2. Change as necessary. 
# db2-server2 is the name of the database instance at server2
CATALOG TCPIP NODE server2 REMOTE "db-ip-2" SERVER 25010
CATALOG DB db-server2 AT NODE server2

TERMINATE
