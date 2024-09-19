while true; do psql -h 192.168.1.11,192.168.1.12,192.168.1.13,192.168.1.14 -U enterprisedb -p 6432 -d bdrdb -f pgd-demo-app.sql; date; done
