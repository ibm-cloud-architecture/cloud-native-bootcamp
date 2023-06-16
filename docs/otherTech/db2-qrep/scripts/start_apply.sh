#!/bin/bash
. /home/db2qrepid/sqllib/db2profile

cd /home/db2qrepid/qrep/db2_server
nohup asnqapp apply_server=db2_server APPLY_SCHEMA=ASN  apply_path="/home/db2qrepid/qrep/db2_server" logreuse=y  &
