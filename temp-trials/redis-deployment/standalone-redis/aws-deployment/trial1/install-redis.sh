
set -e
set -x

sudo amazon-linux-extras enable redis6
yum clean metadata
sudo yum install redis -y

export PORT=50379

echo "[Unit]
Description=Redis
After=syslog.target

[Service]
ExecStart=/bin/redis-server /etc/redis/redis.conf --port ${PORT}
RestartSec=5s
Restart=on-success

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/redis.service

cat /etc/systemd/system/redis.service

sudo systemctl daemon-reload
sudo systemctl status redis || true
sudo systemctl start redis
sudo systemctl status redis
redis-cli -p ${PORT} PING
