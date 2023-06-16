#!/bin/bash

source /home/db2qrepid/sqllib/db2profile

cd /home/db2qrepid/qrep/db2_server 

nohup asnqcap capture_server=db2_server capture_schema=asn startmode=WARMSI capture_path="/home/db2qrepid/qrep/db2_server" LSN=FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF MAXCMTSEQ=FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF &
