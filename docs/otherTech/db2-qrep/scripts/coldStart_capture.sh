#!/bin/bash

source /home/db2qrepid/sqllib/db2profile

cd /home/db2qrepid/qrep/db2_server 

nohup asnqcap capture_server=db2_server capture_schema=asn startmode=cold capture_path="/home/db2qrepid/qrep/db2_server" logreuse=y logstdout=y commit_interval=500 memory_limit=2048 &
