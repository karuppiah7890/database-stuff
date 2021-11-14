#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset
set -o xtrace

email=$1
domain_name=$2
ip=$3
tls_port=$4

if [[ -z "${email}" ]]; then
    echo "Email has not been passed to the script. Usage example: ./run-redis.sh abc@example.com redis-server.example.com 156.165.10.5 6379"
    exit 1
fi

if [[ -z "${domain_name}" ]]; then
    echo "Domain name has not been passed to the script. Usage example: ./run-redis.sh abc@example.com redis-server.example.com 156.165.10.5 6379"
    exit 1
fi

if [[ -z "${ip}" ]]; then
    echo "IP address has not been passed to the script. Usage example: ./run-redis.sh abc@example.com redis-server.example.com 156.165.10.5 6379"
    exit 1
fi

if [[ -z "${tls_port}" ]]; then
    echo "TLS port number has not been passed to the script. Usage example: ./run-redis.sh abc@example.com redis-server.example.com 156.165.10.5 6379"
    exit 1
fi

function install_redis {
    add-apt-repository ppa:redislabs/redis --yes;
    apt install redis-server --yes;
    systemctl status redis-server;
    redis-cli -e PING;
    redis-cli -e INFO server;
}

function check_malloc_is_jemalloc {
    redis-cli -e MEMORY MALLOC-STATS | grep jemalloc;
}

function configure_password {
    password=$(redis-cli -e ACL GENPASS);
    redis-cli -e CONFIG GET requirepass;
    redis-cli -e CONFIG SET requirepass ${password};
    export REDISCLI_AUTH=${password};
    redis-cli -e CONFIG GET requirepass;
    redis-cli -e CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "requirepass \"${password}\"";
}

function install_certbot {
    sudo snap install --classic certbot;
    sudo ln --force --symbolic /snap/bin/certbot /usr/bin/certbot;
}

function obtain_ssl_certificate {
    sudo certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --email ${email} \
        --domains ${domain_name}
}

function give_redis_user_access_to_ssl_certificate {
    chown -R redis:redis /etc/letsencrypt/;
}

function configure_private_key {
    private_key_path="/etc/letsencrypt/live/${domain_name}/privkey.pem"
    redis-cli -e CONFIG GET tls-key-file;
    redis-cli -e CONFIG SET tls-key-file ${private_key_path};
    redis-cli -e CONFIG GET tls-key-file;
    redis-cli -e CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-key-file \"${private_key_path}\"";
}

function configure_ssl_certificate {
    ssl_certificate_path="/etc/letsencrypt/live/${domain_name}/fullchain.pem"
    redis-cli -e CONFIG GET tls-cert-file;
    redis-cli -e CONFIG SET tls-cert-file ${ssl_certificate_path};
    redis-cli -e CONFIG GET tls-cert-file;
    redis-cli -e CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-cert-file \"${ssl_certificate_path}\"";
}

function disable_tls_auth {
    redis-cli -e CONFIG GET tls-auth-clients;
    redis-cli -e CONFIG SET tls-auth-clients no;
    redis-cli -e CONFIG GET tls-auth-clients;
    redis-cli -e CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-auth-clients no";
}

function configure_tls_port {
    redis-cli -e CONFIG GET tls-port;
    redis-cli -e CONFIG SET tls-port ${tls_port};
    redis-cli -e CONFIG GET tls-port;
    redis-cli -e CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "tls-port ${tls_port}";
}

function configure_tls {
    configure_private_key;
    configure_ssl_certificate;
    disable_tls_auth;
    configure_tls_port;
}

function disable_non_tls_port {
    redis-cli -e --tls -p ${tls_port} CONFIG GET port;
    redis-cli -e --tls -p ${tls_port} CONFIG SET port 0;
    redis-cli -e --tls -p ${tls_port} CONFIG GET port;
    redis-cli -e --tls -p ${tls_port} CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "port 0";
}

function configure_bind {
    redis-cli -e --tls -p ${tls_port} CONFIG GET bind;
    redis-cli -e --tls -p ${tls_port} CONFIG SET bind "${ip} 127.0.0.1 -::1";
    redis-cli -e --tls -p ${tls_port} CONFIG GET bind;
    redis-cli -e --tls -p ${tls_port} CONFIG REWRITE;
    cat /etc/redis/redis.conf | grep "bind ${ip} 127.0.0.1 -::1";
}

install_redis

check_malloc_is_jemalloc

configure_password

install_certbot

obtain_ssl_certificate

give_redis_user_access_to_ssl_certificate

configure_tls

disable_non_tls_port

configure_bind

echo "Redis has been installed and configured and is running with TLS support and password protection!!"

echo -e "\nConnection details - "

echo "Username - No user name"

echo "Password - ${REDISCLI_AUTH}"

echo "Host - ${domain_name}"

echo "Port - ${tls_port}"

echo -e "\nRedis CLI (redis-cli) command - "

echo "redis-cli --tls -h ${domain_name} -a ${REDISCLI_AUTH} -p ${tls_port}"
