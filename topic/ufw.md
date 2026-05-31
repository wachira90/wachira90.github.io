# UFW COMMAND

```sh
ufw enable
ufw status
ufw disable
ufw status numbered
ufw app list
ufw allow 22/tcp
ufw allow proto tcp from 0.0.0.0/0 to any port 22
ufw limit 22/tcp
ufw app list
ufw status numbered
ufw delete 6
ufw status numbered
ufw delete 1
ufw status numbered
ufw default allow outgoing
ufw default deny incoming
ufw status numbered
apt update
ufw logging medium
ufw allow proto tcp from 0.0.0.0/0 to any port 22
tail -f /var/log/ufw.log
tail -f /var/log/auth.log
tail -f /var/log/kern.log
cd /var/log
rm *.log.*.gz
rm *.gz
```