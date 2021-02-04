#!/bin/bash

bundle exec jekyll serve
# --host=0.0.0.0

# Try the following in an admin powershell session:
# netsh interface portproxy add v4tov4 listenport=4000 connectport=4000 connectaddress=172.21.3.56
# netsh interface portproxy show v4tov4
## Also, add inbound rule to port 4000 on firewall (labelled "jekyll dev")
