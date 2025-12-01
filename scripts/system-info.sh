#!/bin/bash
#
# system-info.sh - Linux Ubuntu System Information Script
# Compatible with Bash 3.0 and above
#
# Usage: ./system-info.sh
#

set -e

# Colors for output (if terminal supports it)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
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

# System Information
print_header "System Information"

if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    print_info "OS" "$NAME $VERSION"
else
    print_info "OS" "$(uname -s)"
fi

print_info "Kernel" "$(uname -r)"
print_info "Architecture" "$(uname -m)"
print_info "Hostname" "$(hostname)"

# CPU Information
print_header "CPU Information"

if [ -f /proc/cpuinfo ]; then
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ":" -f2 | sed 's/^ //')
    cpu_cores=$(grep -c "processor" /proc/cpuinfo)
    print_info "Model" "$cpu_model"
    print_info "Cores" "$cpu_cores"
fi

# Memory Information
print_header "Memory Information"

if [ -f /proc/meminfo ]; then
    total_mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    free_mem=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
    available_mem=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
    
    # Convert to MB
    total_mb=$((total_mem / 1024))
    free_mb=$((free_mem / 1024))
    available_mb=$((available_mem / 1024))
    
    print_info "Total Memory" "${total_mb} MB"
    print_info "Free Memory" "${free_mb} MB"
    print_info "Available Memory" "${available_mb} MB"
fi

# Disk Usage
print_header "Disk Usage"
df -h --output=source,size,used,avail,pcent,target 2>/dev/null | head -10 || df -h | head -10

# Uptime
print_header "System Uptime"
uptime

# Current User
print_header "Current User Information"
print_info "User" "$(whoami)"
print_info "User ID" "$(id -u)"
print_info "Group ID" "$(id -g)"

echo ""
echo -e "${GREEN}System information collected successfully!${NC}"
