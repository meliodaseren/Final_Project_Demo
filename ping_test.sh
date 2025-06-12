#!/bin/bash

# Network connectivity test script for SDN NFV v-router project
# This script tests connectivity between different AS web containers

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # no color

WEBS="00 10 20 21"
IPS="192.168.0.100 10.0.0.3 10.1.0.3 10.2.0.3"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Additional Quick Ping Tests         ${NC}"
echo -e "${BLUE}========================================${NC}"

check_container() {
    local container_name="web650$1"
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "${RED}ERROR: Container ${container_name} is not running!${NC}"
        return 1
    fi
    return 0
}

ping_test() {
    local web=$1
    local ip=$2
    local container_name="web650$web"

    if check_container "$web"; then
        local pid=$(get_container_pid "$web")
        if [ $? -eq 0 ]; then
            echo -n -e "${YELLOW}PING $container_name -> $ip: ${NC}"
            if sudo nsenter -t "$pid" -n ping -c 1 -W 2 "$ip" >/dev/null 2>&1; then
                echo -e "${GREEN}OK${NC}"
            else
                echo -e "${RED}FAIL${NC}"
            fi
        fi
    fi
}

echo "Quick ping connectivity matrix:"
echo ""
for web in $WEBS; do
    for ip in $IPS; do
        ping_test "$web" "$ip"
    done
done

echo ""
echo -e "${GREEN}Test completed!${NC}"
