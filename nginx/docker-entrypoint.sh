#!/bin/bash

set -e

check_and_set_ssl() {
  local DOMAIN="$1"
  local CERT_PATH="/etc/letsencrypt/live/${DOMAIN}.${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_FILENAME}"
  local KEY_PATH="/etc/letsencrypt/live/${DOMAIN}.${CERTBOT_DOMAIN}/${NGINX_SSL_CERT_KEY_FILENAME}"

  if [ -f "$CERT_PATH" ] && [ -f "$KEY_PATH" ]; then
    SSL_CERTIFICATE_PATH="$CERT_PATH"
    SSL_CERTIFICATE_KEY_PATH="$KEY_PATH"
	export SSL_CERTIFICATE_PATH
	export SSL_CERTIFICATE_KEY_PATH
	DOMAIN="${DOMAIN^^}" 
	local CONFIG_VAR="${DOMAIN}_HTTPS_CONFIG"  # 动态生成变量名
	local CONFIG_CONTENT
    CONFIG_CONTENT=$(envsubst < /etc/nginx/https.conf.template)
    export "$CONFIG_VAR"="$CONFIG_CONTENT"
  fi
}

if [ "${NGINX_HTTPS_ENABLED}" = "true" ]; then
  check_and_set_ssl "web"
  check_and_set_ssl "dash"
  check_and_set_ssl "api"
  check_and_set_ssl "im"
  check_and_set_ssl "ws"
  check_and_set_ssl "jsws"
  check_and_set_ssl "minio"
else
  SSL_CERTIFICATE_PATH="/etc/ssl/${NGINX_SSL_CERT_FILENAME}"
  SSL_CERTIFICATE_KEY_PATH="/etc/ssl/${NGINX_SSL_CERT_KEY_FILENAME}"
  export SSL_CERTIFICATE_PATH
  export SSL_CERTIFICATE_KEY_PATH
  export HTTPS_CONFIG=$(envsubst < /etc/nginx/https.conf.template)
  envsubst '${HTTPS_CONFIG}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
fi

# ACME Challenge Location handling
if [ "${NGINX_ENABLE_CERTBOT_CHALLENGE}" = "true" ]; then
  ACME_CHALLENGE_LOCATION='location /.well-known/acme-challenge/ { root /var/www/html; }'
else
  ACME_CHALLENGE_LOCATION=''
fi
export ACME_CHALLENGE_LOCATION

env_vars=$(printenv | cut -d= -f1 | sed 's/^/$/g' | paste -sd, -)
envsubst "$env_vars" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
envsubst "$env_vars" < /etc/nginx/proxy.conf.template > /etc/nginx/proxy.conf
envsubst "$env_vars" < /etc/nginx/ws.conf.template > /etc/nginx/ws.conf
envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start Nginx
exec nginx -g 'daemon off;'
