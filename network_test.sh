#!/bin/bash

# Network connectivity test script for SDN NFV v-router project
# This script tests connectivity between different AS web containers

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # no color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    SDN NFV Network Connectivity Test   ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

WEBS="00 10 20 21"
IPS="192.168.0.100 10.0.0.3 10.1.0.3 10.2.0.3"

check_container() {
    local container_name="web650$1"
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "${RED}ERROR: Container ${container_name} is not running!${NC}"
        return 1
    fi
    return 0
}

get_container_pid() {
    local container_name="web650$1"
    local pid=$(docker inspect -f '{{ .State.Pid }}' "$container_name" 2>/dev/null)
    if [ -z "$pid" ] || [ "$pid" = "0" ]; then
        echo -e "${RED}ERROR: Could not get PID for container ${container_name}${NC}"
        return 1
    fi
    echo "$pid"
}

run_mtr_test() {
    local web=$1
    local ip=$2
    local container_name="web650$web"

    echo -e "${YELLOW}info: container $container_name, ip $ip${NC}"

    # check if container exists
    if ! check_container "$web"; then
        echo -e "${RED}SKIP${NC}"
        echo ""
        return 1
    fi

    # container PID
    local pid=$(get_container_pid "$web")
    if [ $? -ne 0 ]; then
        echo -e "${RED}SKIP${NC}"
        echo ""
        return 1
    fi

    # mtr test
    echo "Running: sudo nsenter -t $pid -n mtr -c 3 -r $ip"
    if sudo nsenter -t "$pid" -n mtr -c 3 -r "$ip" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi
    echo ""
}

echo -e "${BLUE}Starting connectivity tests...${NC}"
echo ""
for web in $WEBS; do
    echo -e "${BLUE}--- Testing from AS650$web ---${NC}"
    for ip in $IPS; do
        run_mtr_test "$web" "$ip"
    done
    echo -e "${BLUE}--- End AS650$web tests ---${NC}"
    echo ""
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Test Summary                        ${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Tested containers: AS65000, AS65010, AS65020, AS65021${NC}"
echo -e "${YELLOW}Target IPs:${NC}"
echo -e "  • 192.168.0.100 (AS65000 web container)"
echo -e "  • 10.0.0.3      (AS65010 web container)"
echo -e "  • 10.1.0.3      (AS65020 web container)"
echo -e "  • 10.2.0.3      (AS65021 web container)"
echo ""
echo -e "${GREEN}Test completed!${NC}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Additional Quick Ping Tests         ${NC}"
echo -e "${BLUE}========================================${NC}"

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
echo -e "${GREEN}Additional Test completed!${NC}"
