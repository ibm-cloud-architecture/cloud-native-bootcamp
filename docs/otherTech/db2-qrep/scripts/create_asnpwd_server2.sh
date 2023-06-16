# Used this script to create the password file needed by the Q-Replication sever for logging# into remote server 1

source ~/db2/instances/sqllib/db2profile

# Change to the desired directory for q-replication
cd /home/db2_server2/qrep/dbname

# Change dbalias1, dbalias2, db2qrepid and password as necessary
asnpwd init encrypt password
asnpwd add alias dbalias1 ID db2qrepid PASSWORD "password"
asnpwd add alias dbalias2 ID db2qrepid PASSWORD "password"
asnpwd list using asnpwd.aut

echo
ls -ld `pwd`/asnpwd.aut
