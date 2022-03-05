# Start an Http server that returns "Hello World.
# Reference Links: http://blog.livedoor.jp/sonots/archives/34703829.html
alias http_server='while true; do ( echo "HTTP/1.0 200 Ok"; echo; echo "Hello World" ) | nc -l 8080; [ $? != 0 ] && break; done'

# Set "core.ignorecase=false" even for file systems that ignore case.
alias git-init='git init && git config core.ignorecase false'
