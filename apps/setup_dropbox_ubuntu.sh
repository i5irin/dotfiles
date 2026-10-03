#!/bin/sh
#
#  Install Dropbox
# =========================================================
set -eu

mkdir -p ~/bin/dropbox
cd ~/bin/dropbox && curl -L 'https://www.dropbox.com/download?plat=lnx.x86_64' | tar xzf -
# ここでブラウザが開いて操作を求められてしまう
~/bin/dropbox/.dropbox-dist/dropboxd
curl -O 'https://www.dropbox.com/download?dl=packages/dropbox.py'
cat <<EOS > /lib/systemd/system/dropbox.service
[Unit]
Description=Dropbox auto start script

[Service]
User=${USER}
WorkingDirectory=/home/${USER}/
Type=forking
ExecStart=python3 ${HOME}/bin/dropbox/dropbox.py start
Restart=always

[Install]
WantedBy=multi-user.target
EOS
systemctl daemon-reload
systemctl enable dropbox
