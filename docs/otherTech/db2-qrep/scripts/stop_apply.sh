#!/bin/bash
. /home/db2qrepid/sqllib/db2profile

cd /home/db2qrepid/qrep/db2_server

asnqacmd apply_server=db2_server STOP
