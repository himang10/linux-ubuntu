#!/bin/bash
#
# network-info.sh - Network Information Script for Linux Ubuntu
# Compatible with Bash 3.0 and above
#
# Usage: ./network-info.sh
#

set -e

# Colors for output
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_info() {
    echo -e "${YELLOW}$1:${NC} $2"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

# Hostname Information
print_header "Hostname Information"
print_info "Hostname" "$(hostname)"
print_info "FQDN" "$(hostname -f 2>/dev/null || echo 'N/A')"

# Network Interfaces
print_header "Network Interfaces"

if command -v ip >/dev/null 2>&1; then
    # Using ip command (preferred)
    ip -br addr show 2>/dev/null || ip addr show
elif command -v ifconfig >/dev/null 2>&1; then
    # Fallback to ifconfig
    ifconfig
else
    echo "Neither 'ip' nor 'ifconfig' command found"
fi

# IP Addresses
print_header "IP Address Summary"

if command -v ip >/dev/null 2>&1; then
    # Get all IPv4 addresses
    ip -4 addr show 2>/dev/null | grep inet | while read -r line; do
        iface=$(echo "$line" | awk '{print $NF}')
        ip_addr=$(echo "$line" | awk '{print $2}')
        print_info "$iface" "$ip_addr"
    done
fi

# Default Gateway
print_header "Default Gateway"

if command -v ip >/dev/null 2>&1; then
    gateway=$(ip route | grep default | awk '{print $3}' | head -1)
    if [ -n "$gateway" ]; then
        print_info "Gateway" "$gateway"
    else
        echo "No default gateway found"
    fi
elif command -v route >/dev/null 2>&1; then
    route -n | grep "^0.0.0.0" | awk '{print "Gateway: " $2}'
fi

# DNS Configuration
print_header "DNS Configuration"

if [ -f /etc/resolv.conf ]; then
    grep "^nameserver" /etc/resolv.conf | while read -r line; do
        dns_server=$(echo "$line" | awk '{print $2}')
        print_info "DNS Server" "$dns_server"
    done
else
    echo "DNS configuration file not found"
fi

# Network Statistics
print_header "Network Statistics"

if command -v netstat >/dev/null 2>&1; then
    echo "Active connections:"
    netstat -tuln 2>/dev/null | head -20 || echo "Unable to get network statistics"
elif command -v ss >/dev/null 2>&1; then
    echo "Active connections:"
    ss -tuln 2>/dev/null | head -20 || echo "Unable to get network statistics"
fi

# Listening Ports
print_header "Listening Ports (TCP)"

if command -v ss >/dev/null 2>&1; then
    ss -tlnp 2>/dev/null | head -15 || echo "Unable to list listening ports"
elif command -v netstat >/dev/null 2>&1; then
    netstat -tlnp 2>/dev/null | head -15 || echo "Unable to list listening ports"
fi

# Connectivity Test
print_header "Connectivity Test"

echo "Testing connectivity..."

# Test local loopback
if ping -c 1 127.0.0.1 >/dev/null 2>&1; then
    print_info "Loopback" "OK"
else
    print_info "Loopback" "FAILED"
fi

# Test gateway (if available)
if [ -n "$gateway" ]; then
    if ping -c 1 -W 2 "$gateway" >/dev/null 2>&1; then
        print_info "Gateway ($gateway)" "OK"
    else
        print_info "Gateway ($gateway)" "UNREACHABLE"
    fi
fi

# Test external connectivity
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    print_info "Internet (8.8.8.8)" "OK"
else
    print_info "Internet (8.8.8.8)" "UNREACHABLE"
fi

echo ""
echo -e "${GREEN}Network information collected successfully!${NC}"
