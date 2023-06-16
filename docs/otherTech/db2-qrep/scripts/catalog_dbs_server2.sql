# Use this script to catalog the databases for local and remmote access

# Change server2 to the desired node name, and db2server2 to the instance name
CATALOG LOCAL NODE server2 INSTANCE db2server2

# Change server1 to the desire node name, db-ip-1 to the ip address of server1.
# 25010 to the port number of the database instance on server1. Change as necessary. 
# db2-server1 is the name of the database instance at server1
CATALOG TCPIP NODE server1 REMOTE "db-ip-1" SERVER 25010
CATALOG DB db-server1 AT NODE server1

TERMINATE
