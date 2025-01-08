#!/bin/bash

# Prompt the user to enter a VLESS URL
echo "Please enter a VLESS URL:"
read vless_url

# Extracting the UUID, Host, Port, and other parameters with default values if not provided
uuid=$(echo "$vless_url" | sed -n 's|vless://\([^@]*\)@.*|\1|p')
host=$(echo "$vless_url" | sed -n 's|vless://.*@\([^:]*\):.*|\1|p')
port=$(echo "$vless_url" | sed -n 's|vless://.*@[^:]*\:\([^?]*\).*|\1|p')
type=$(echo "$vless_url" | sed -n 's|.*type=\([^&]*\).*|\1|p')
security=$(echo "$vless_url" | sed -n 's|.*security=\([^&]*\).*|\1|p')
encryption=$(echo "$vless_url" | sed -n 's|.*encryption=\([^&]*\).*|\1|p')
header_type=$(echo "$vless_url" | sed -n 's|.*headerType=\([^&]*\).*|\1|p')
alpn=$(echo "$vless_url" | sed -n 's|.*alpn=\([^&]*\).*|\1|p')
allow_insecure=$(echo "$vless_url" | sed -n 's|.*allowInsecure=\([^&]*\).*|\1|p')
sni=$(echo "$vless_url" | sed -n 's|.*sni=\([^#&]*\).*|\1|p')
path=$(echo "$vless_url" | sed -n 's|.*path=\([^&]*\).*|\1|p')
tag=$(echo "$vless_url" | sed -n 's|.*#\(.*\)$|\1|p')

# Set default values for parameters if they are empty or missing
if [ -z "$path" ]; then
    path="/"
fi
if [ -z "$encryption" ]; then
    encryption="none"
fi
if [ -z "$header_type" ]; then
    header_type="none"
fi
if [ -z "$tag" ]; then
    tag=""
fi
if [ -z "$allow_insecure" ]; then
    allow_insecure="0"
fi

# Echo the extracted variables
echo "UUID: $uuid"
echo "Host: $host"
echo "Port: $port"
echo "Type: $type"
echo "Security: $security"
echo "Encryption: $encryption"
echo "Header Type: $header_type"
echo "ALPN: $alpn"
echo "Allow Insecure: $allow_insecure"
echo "SNI: $sni"
echo "Path: $path"
echo "Tag: $tag"

# Convert allow_insecure to boolean
if [ "$allow_insecure" = "1" ]; then
    allow_insecure_bool="true"
else
    allow_insecure_bool="false"
fi

# Process ALPN string
# Convert URL-encoded comma to actual comma and split
alpn_list=$(echo "$alpn" | sed 's/%2C/,/g')
IFS=',' read -ra ALPN_ARRAY <<<"$alpn_list"

# Generate ALPN JSON array
alpn_json=""
for i in "${ALPN_ARRAY[@]}"; do
    if [ -n "$alpn_json" ]; then
        alpn_json="$alpn_json,"
    fi
    alpn_json="$alpn_json\"$i\""
done

# If ALPN is empty, use default values
if [ -z "$alpn_json" ]; then
    alpn_json="\"h2\",\"http/1.1\""
fi

# Create the config.json file
cat >~/Downloads/config.json <<EOF
{
  "log": {
    "loglevel": "info"
  },
  "inbounds": [
    {
      "tag": "socks-in",
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "udp": true,
        "auth": "noauth"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "tag": "http-in",
      "port": 10809,
      "protocol": "http",
      "settings": {},
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "$host",
            "port": $port,
            "users": [
              {
                "id": "$uuid",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "serverName": "$sni",
          "allowInsecure": true,
          "fingerprint": "chrome",
          "alpn": [
            $alpn_json
          ]
        },
        "wsSettings": {
          "path": "$path"
        }
      }
    }
  ]
}
EOF

echo "Config file has been saved to ~/Downloads/config.json"
