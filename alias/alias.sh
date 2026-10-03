# Start an Http server that returns "Hello World.
# Reference Links: http://blog.livedoor.jp/sonots/archives/34703829.html
alias http_server='while true; do ( echo "HTTP/1.0 200 Ok"; echo; echo "Hello World" ) | nc -l 8080; [ $? != 0 ] && break; done'

# Set "core.ignorecase=false" even for file systems that ignore case.
alias git-init='git init && git config core.ignorecase false'

# Obtain the IP address of the WAN side.
# Reference Links: https://unix.stackexchange.com/a/81699/37512
alias wanip4='dig @resolver4.opendns.com myip.opendns.com +short -4'
alias wanip6='dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6'
