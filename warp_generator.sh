#!/bin/bash

clear
if [ -d "/home/runner" ] || [ ! -z "$REPL_ID" ]; then
    echo "[INFO] Запуск в Replit — пропускаем установку системных пакетов"
else
    echo "[INFO] Не Replit — выполняем установку зависимостей"

    mkdir -p ~/.cloudshell && touch ~/.cloudshell/no-apt-get-warning
    apt update -y && apt install sudo -y
    out="$(sudo apt-get update -y --fix-missing 2>&1)" || {
      echo "$out" | grep -qiE "dl\.yarnpkg\.com|NO_PUBKEY 62D54FD4003F6525|is not signed" || { echo "$out"; exit 1; }
      echo "[WARN] Yarn repo ломает apt update — удаляю yarn.list и повторяю..."
      sudo rm -f /etc/apt/sources.list.d/yarn.list
    }
    sudo apt-get update -y --fix-missing && sudo apt-get install wireguard-tools jq wget qrencode -y --fix-missing
fi

echo "Выберите DNS-сервер для конфигурации:"
echo "  1) Cloudflare"
echo "  2) Google"
echo "  3) Quad9"
echo "  4) AdGuard"
echo "  5) Comss.one"
echo "  6) XBoxDNS"
echo "  7) GeoHide"
read -p "Ваш выбор [1]: " DNS_CHOICE
DNS_CHOICE="${DNS_CHOICE:-1}"

case "$DNS_CHOICE" in
    2)
        DNS1="8.8.8.8"; DNS2="8.8.4.4"
        DNS3="2001:4860:4860::8888"; DNS4="2001:4860:4860::8844"
        ;;
    3)
        DNS1="9.9.9.9"; DNS2="9.9.9.10"
        DNS3="2620:fe::fe"; DNS4="2620:fe::9"
        ;;
    4)
        DNS1="94.140.14.14"; DNS2="94.140.15.15"
        DNS3="2a10:50c0::ad1:ff"; DNS4="2a10:50c0::ad2:ff"
        ;;
    5)
        DNS1="83.220.169.155"; DNS2="212.109.195.93"
        DNS3=""; DNS4=""
        ;;
    6)
        DNS1="111.88.96.54"; DNS2="111.88.96.55"
        DNS3="2a00:ab00:1233:26::50"; DNS4="2a00:ab00:1233:26::51"
        ;;
    7)
        DNS1="217.60.245.219"; DNS2="217.60.245.233"
        DNS3=""; DNS4=""
        ;;
    *)
        DNS1="1.1.1.1"; DNS2="1.0.0.1"
        DNS3="2606:4700:4700::1111"; DNS4="2606:4700:4700::1001"
        ;;
esac

DNS_LINE="$DNS1"
[ -n "$DNS2" ] && DNS_LINE="$DNS_LINE, $DNS2"
[ -n "$DNS3" ] && DNS_LINE="$DNS_LINE, $DNS3"
[ -n "$DNS4" ] && DNS_LINE="$DNS_LINE, $DNS4"

echo ""
echo "Выберите режим маршрутизации:"
echo "  1) Весь трафик через VPN"
echo "  2) Исключить локальную сеть"
read -p "Ваш выбор [1]: " ROUTING_CHOICE
ROUTING_CHOICE="${ROUTING_CHOICE:-1}"

if [ "$ROUTING_CHOICE" = "2" ]; then
    ALLOWED_IPS="1.0.0.0/8, 2.0.0.0/7, 4.0.0.0/6, 8.0.0.0/7, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/3, 96.0.0.0/4, 112.0.0.0/5, 120.0.0.0/6, 124.0.0.0/7, 126.0.0.0/8, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/8, 169.0.0.0/9, 169.128.0.0/10, 169.192.0.0/11, 169.224.0.0/12, 169.240.0.0/13, 169.248.0.0/14, 169.252.0.0/15, 169.255.0.0/16, 170.0.0.0/7, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/4, ::/1, 8000::/2, c000::/3, e000::/4, f000::/5, f800::/6, fe00::/9, fec0::/10, ff00::/8"
else
    ALLOWED_IPS="0.0.0.0/0, ::/0"
fi

echo ""
echo "Выберите параметры Jc / Jmin / Jmax:"
echo "  1) Jc = 3,   Jmin = 10, Jmax = 30"
echo "  2) Jc = 4,   Jmin = 40, Jmax = 70"
echo "  3) Jc = 6,   Jmin = 70, Jmax = 100"
echo "  4) Jc = 120, Jmin = 23, Jmax = 911"
echo "  5) Ввести свои значения"
read -p "Ваш выбор [1]: " JC_CHOICE
JC_CHOICE="${JC_CHOICE:-1}"

case "$JC_CHOICE" in
    1) JC=3;   JMIN=10; JMAX=30;  ;;
    2) JC=4;   JMIN=40; JMAX=70;  ;;
    3) JC=6;   JMIN=70; JMAX=100; ;;
    4) JC=120; JMIN=23; JMAX=911; ;;
    5)
        read -p "Jc [120]: "   JC;   JC="${JC:-120}"
        read -p "Jmin [23]: "  JMIN; JMIN="${JMIN:-23}"
        read -p "Jmax [911]: " JMAX; JMAX="${JMAX:-911}"
        if ! [[ "$JC" =~ ^[0-9]+$ ]] || ! [[ "$JMIN" =~ ^[0-9]+$ ]] || ! [[ "$JMAX" =~ ^[0-9]+$ ]]; then
            echo "[WARN] Некорректные значения — используем дефолт Jc=120, Jmin=23, Jmax=911"
            JC=120; JMIN=23; JMAX=911
        fi
        ;;
    *) JC=3; JMIN=10; JMAX=30 ;;
esac

echo ""
read -p "Значение MTU [1280]: " MTU_VALUE
MTU_VALUE="${MTU_VALUE:-1280}"
if ! [[ "$MTU_VALUE" =~ ^[0-9]+$ ]]; then
    echo "[WARN] Некорректное значение MTU, используем 1280"
    MTU_VALUE=1280
fi

echo ""
read -p "Включить IPv6 в конфигурации? (y/n) [y]: " ENABLE_IPV6
ENABLE_IPV6="${ENABLE_IPV6:-y}"

if [ "$ENABLE_IPV6" = "y" ] || [ "$ENABLE_IPV6" = "Y" ]; then
    DNS_LINE="$DNS1"
    [ -n "$DNS2" ] && DNS_LINE="$DNS_LINE, $DNS2"
    [ -n "$DNS3" ] && DNS_LINE="$DNS_LINE, $DNS3"
    [ -n "$DNS4" ] && DNS_LINE="$DNS_LINE, $DNS4"
else
    DNS_LINE="$DNS1"
    [ -n "$DNS2" ] && DNS_LINE="$DNS_LINE, $DNS2"
fi

echo ""
read -p "Включить PersistentKeepalive? (y/n) [y]: " ENABLE_KEEPALIVE
ENABLE_KEEPALIVE="${ENABLE_KEEPALIVE:-y}"

KEEPALIVE_LINE=""
if [ "$ENABLE_KEEPALIVE" = "y" ] || [ "$ENABLE_KEEPALIVE" = "Y" ]; then
    read -p "Значение PersistentKeepalive в секундах [25]: " KEEPALIVE_VALUE
    KEEPALIVE_VALUE="${KEEPALIVE_VALUE:-25}"
    if ! [[ "$KEEPALIVE_VALUE" =~ ^[0-9]+$ ]]; then
        echo "[WARN] Некорректное значение, используем 25"
        KEEPALIVE_VALUE=25
    fi
    KEEPALIVE_LINE="PersistentKeepalive = ${KEEPALIVE_VALUE}"
fi

echo ""
read -p "Сгенерировать собственный I1 по домену? (y/n) [n]: " CUSTOM_I1
CUSTOM_I1="${CUSTOM_I1:-n}"

CUSTOM_I1_VAL=""
if [ "$CUSTOM_I1" = "y" ] || [ "$CUSTOM_I1" = "Y" ]; then
    read -p "Введите домен: " I1_DOMAIN
    if [ -n "$I1_DOMAIN" ]; then
        I1_FULL=""
        SEED="$I1_DOMAIN"
        for _ in $(seq 1 16); do
            SEED=$(printf "%s" "$SEED" | sha256sum | cut -d' ' -f1)
            I1_FULL="${I1_FULL}${SEED}"
        done
        CUSTOM_I1_VAL="<b 0x${I1_FULL}>"
        echo "[INFO] Сгенерирован I1 на основе домена: ${I1_DOMAIN}"
    else
        echo "[WARN] Домен не указан — используем I1 по умолчанию"
    fi
fi

priv="${1:-$(wg genkey | tr -d '\n')}"
pub="${2:-$(printf "%s" "${priv}" | wg pubkey | tr -d '\n')}"
api="https://api.cloudflareclient.com/v0i1909051800"
ins() { curl -s -H 'User-Agent: okhttp/3.12.1' -H 'Content-Type: application/json' -X "$1" "${api}/$2" "${@:3}"; }
sec() { ins "$1" "$2" -H "Authorization: Bearer $3" "${@:4}"; }
response=$(ins POST "reg" -d "{\"install_id\":\"\",\"tos\":\"$(date -u +%FT%TZ)\",\"key\":\"${pub}\",\"fcm_token\":\"\",\"type\":\"ios\",\"locale\":\"en_US\"}")

clear
id=$(echo "$response" | jq -r '.result.id')
token=$(echo "$response" | jq -r '.result.token')
# Если Cloudflare вернул ошибку
if [ "$id" = "null" ] || [ -z "$id" ] || [ "$token" = "null" ] || [ -z "$token" ]; then
  echo "[ERROR] Registration failed:"
  echo "$response" | jq .
  exit 1
fi
response=$(sec PATCH "reg/${id}" "$token" -d '{"warp_enabled":true}')
peer_pub=$(echo "$response" | jq -r '.result.config.peers[0].public_key')
#peer_endpoint=$(echo "$response" | jq -r '.result.config.peers[0].endpoint.host')
client_ipv4=$(echo "$response" | jq -r '.result.config.interface.addresses.v4')
client_ipv6=$(echo "$response" | jq -r '.result.config.interface.addresses.v6')

if [ "$ENABLE_IPV6" = "y" ] || [ "$ENABLE_IPV6" = "Y" ]; then
    ADDRESS_LINE="${client_ipv4}, ${client_ipv6}"
else
    ADDRESS_LINE="${client_ipv4}"
fi

if [ -n "$CUSTOM_I1_VAL" ]; then
    I1_FINAL="$CUSTOM_I1_VAL"
else
    I1_FINAL="<b 0xc2000000011419fa4bb3599f336777de79f81ca9a8d80d91eeec000044c635cef024a885dcb66d1420a91a8c427e87d6cf8e08b563932f449412cddf77d3e2594ea1c7a183c238a89e9adb7ffa57c133e55c59bec101634db90afb83f75b19fe703179e26a31902324c73f82d9354e1ed8da39af610afcb27e6590a44341a0828e5a3d2f0e0f7b0945d7bf3402feea0ee6332e19bdf48ffc387a97227aa97b205a485d282cd66d1c384bafd63dc42f822c4df2109db5b5646c458236ddcc01ae1c493482128bc0830c9e1233f0027a0d262f92b49d9d8abd9a9e0341f6e1214761043c021d7aa8c464b9d865f5fbe234e49626e00712031703a3e23ef82975f014ee1e1dc428521dc23ce7c6c13663b19906240b3efe403cf30559d798871557e4e60e86c29ea4504ed4d9bb8b549d0e8acd6c334c39bb8fb42ede68fb2aadf00cfc8bcc12df03602bbd4fe701d64a39f7ced112951a83b1dbbe6cd696dd3f15985c1b9fef72fa8d0319708b633cc4681910843ce753fac596ed9945d8b839aeff8d3bf0449197bd0bb22ab8efd5d63eb4a95db8d3ffc796ed5bcf2f4a136a8a36c7a0c65270d511aebac733e61d414050088a1c3d868fb52bc7e57d3d9fd132d78b740a6ecdc6c24936e92c28672dbe00928d89b891865f885aeb4c4996d50c2bbbb7a99ab5de02ac89b3308e57bcecf13f2da0333d1420e18b66b4c23d625d836b538fc0c221d6bd7f566a31fa292b85be96041d8e0bfe655d5dc1afed23eb8f2b3446561bbee7644325cc98d31cea38b865bdcc507e48c6ebdc7553be7bd6ab963d5a14615c4b81da7081c127c791224853e2d19bafdc0d9f3f3a6de898d14abb0e2bc849917e0a599ed4a541268ad0e60ea4d147dc33d17fa82f22aa505ccb53803a31d10a7ca2fea0b290a52ee92c7bf4aab7cea4e3c07b1989364eed87a3c6ba65188cd349d37ce4eefde9ec43bab4b4dc79e03469c2ad6b902e28e0bbbbf696781ad4edf424ffb35ce0236d373629008f142d04b5e08a124237e03e3149f4cdde92d7fae581a1ac332e26b2c9c1a6bdec5b3a9c7a2a870f7a0c25fc6ce245e029b686e346c6d862ad8df6d9b62474fbc31dbb914711f78074d4441f4e6e9edca3c52315a5c0653856e23f681558d669f4a4e6915bcf42b56ce36cb7dd3983b0b1d6fdf0f8efddb68e7ca0ae9dd4570fe6978fbb524109f6ec957ca61f1767ef74eb803b0f16abd0087cf2d01bc1db1c01d97ac81b3196c934586963fe7cf2d310e0739621e8bd00dc23fded18576d8c8f285d7bb5f43b547af3c76235de8b6f757f817683b2151600b11721219212bf27558edd439e73fce951f61d582320e5f4d6c315c71129b719277fc144bbe8ded25ab6d29b6e189c9bd9b16538faf60cc2aab3c3bb81fc2213657f2dd0ceb9b3b871e1423d8d3e8cc008721ef03b28e0ee7bb66b8f2a2ac01ef88df1f21ed49bf1ce435df31ac34485936172567488812429c269b49ee9e3d99652b51a7a614b7c460bf0d2d64d8349ded7345bedab1ea0a766a8470b1242f38d09f7855a32db39516c2bd4bcc538c52fa3a90c8714d4b006a15d9c7a7d04919a1cab48da7cce0d5de1f9e5f8936cffe469132991c6eb84c5191d1bcf69f70c58d9a7b66846440a9f0eef25ee6ab62715b50ca7bef0bc3013d4b62e1639b5028bdf757454356e9326a4c76dabfb497d451a3a1d2dbd46ec283d255799f72dfe878ae25892e25a2542d3ca9018394d8ca35b53ccd94947a8>"
fi

conf=$(cat <<-EOM
[Interface]
PrivateKey = ${priv}
Jc = ${JC}
Jmin = ${JMIN}
Jmax = ${JMAX}
S1 = 0
S2 = 0
S3 = 0
S4 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4
I1 = ${I1_FINAL}
Address = ${ADDRESS_LINE}
DNS = ${DNS_LINE}
MTU = ${MTU_VALUE}

[Peer]
PublicKey = ${peer_pub}
AllowedIPs = ${ALLOWED_IPS}
Endpoint = 162.159.192.1:500
${KEEPALIVE_LINE}
EOM
)

I1_VAL=$(echo "${conf}" | grep '^I1 = ' | sed 's/^I1 = //')

AWG_JSON=$(jq -n \
    --arg pr "$priv" \
    --arg i1 "$I1_VAL" \
    --arg v4 "$client_ipv4" \
    --arg v6 "$client_ipv6" \
    --arg pp "$peer_pub" \
    --arg cf "$conf" \
    --arg allowed_ips "$ALLOWED_IPS" \
    --arg mtu "$MTU_VALUE" \
    --arg jc "$JC" \
    --arg jmin "$JMIN" \
    --arg jmax "$JMAX" \
    '{
        H1: "1", H2: "2", H3: "3", H4: "4",
        I1: $i1, Jc: $jc, Jmax: $jmax, Jmin: $jmin, S1: "0", S2: "0", S3: "0", S4: "0",
        allowed_ips: ($allowed_ips | split(", ") | map(select(length>0))),
        client_ip: ($v4 + ", " + $v6),
        client_priv_key: $pr,
        config: ($cf | gsub("\n"; "\r\n")),
        hostName: "162.159.192.1",
        mtu: ($mtu | tonumber),
        port: 500,
        server_pub_key: $pp
    }')

AMNEZIA_JSON=$(jq -n \
    --arg last "$AWG_JSON" \
    --arg name "Cloudflare WARP" \
    '{
        containers: [
            {
                container: "amnezia-awg",
                awg: {
                    isThirdPartyConfig: true,
                    last_config: $last,
                    port: "500",
                    transport_proto: "udp"
                }
            }
        ],
        defaultContainer: "amnezia-awg",
        description: $name,
        hostName: "162.159.192.1"
    }')

VPN_KEY="vpn://$(echo -n "$AMNEZIA_JSON" | base64 -w 0)"

if [ -t 1 ]; then
    echo "########## QR-КОД ##########"
fi
echo "$conf" | qrencode -t UTF8
if [ -t 1 ]; then
    echo "########## КОНЕЦ QR-КОДА ##########"
fi

echo -e "\n\n\n"
[ -t 1 ] && echo "########## СТРОКА ДЛЯ AMNEZIAVPN ##########"
echo "$VPN_KEY"
[ -t 1 ] && echo "########### КОНЕЦ СТРОКИ ДЛЯ AMNEZIAVPN ###########"

echo -e "\n\n\n"
[ -t 1 ] && echo "########## НАЧАЛО КОНФИГА ##########"
echo "${conf}"
[ -t 1 ] && echo "########### КОНЕЦ КОНФИГА ###########"

echo "Импортируйте конфигурацию в приложение AmneziaVPN или AmneziaWG 2.0!"