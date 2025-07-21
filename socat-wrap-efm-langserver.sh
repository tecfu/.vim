#!/bin/bash

# Usage:
# - In one terminal, start the socat wrapper script
# ./socat-wrap-efm-langserver.sh
# 
#
# - In another terminal, connect to the socat wrapper
# telnet localhost 12345
#
# - If you want to send/receive in yet another terminal, connect to the socat wrapper like this:
# socat TCP-LISTEN:12346,reuseaddr,fork TCP:localhost:12345
#
# - Send the initialization message
# ```
# Content-Length: 177
# 
# {
#   "jsonrpc": "2.0",
#   "id": 1,
#   "method": "initialize",
#   "params": {
#     "processId": null,
#     "rootUri": "file:///path/to/project",
#     "capabilities": {}
#   }
# }
# ```

# Define the log file
LOGFILE="${HOME}/socat-efm.log"

# Clean up any previous log file
rm -f $LOGFILE

# Start socat in two-way mode
socat -v TCP-LISTEN:12345,reuseaddr,fork SYSTEM:"tee -a $LOGFILE | ${HOME}/go/bin/efm-langserver -loglevel 4"
