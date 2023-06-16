#!/bin/bash
. /home/db2qrepid/sqllib/db2profile

cd /home/db2qrepid/qrep/db2_server

asnqccmd CAPTURE_SERVER=db2_server stop
