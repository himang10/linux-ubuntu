#!/bin/bash
#
# disk-usage.sh - Disk Usage Monitoring Script for Linux Ubuntu
# Compatible with Bash 3.0 and above
#
# Usage: ./disk-usage.sh [threshold]
#        threshold: Alert threshold percentage (default: 80)
#

set -e

# Default threshold
THRESHOLD=${1:-80}

# Colors for output
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

print_header() {
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${YELLOW}========================================${NC}"
}

print_header "Disk Usage Report"
echo "Alert Threshold: ${THRESHOLD}%"
echo ""

# Check if any partition exceeds threshold
alert_found=0

# Get disk usage information and check thresholds
tmpfile=$(mktemp)
df -h > "$tmpfile"

while read -r line; do
    # Skip header line
    case "$line" in
        Filesystem*)
            echo "$line"
            continue
            ;;
    esac
    
    # Extract percentage (5th column)
    percentage=$(echo "$line" | awk '{print $5}' | tr -d '%')
    
    # Check if percentage is a number
    if echo "$percentage" | grep -q '^[0-9]\+$'; then
        if [ "$percentage" -ge "$THRESHOLD" ]; then
            echo -e "${RED}$line${NC} [ALERT]"
            alert_found=1
        else
            echo "$line"
        fi
    else
        echo "$line"
    fi
done < "$tmpfile"

rm -f "$tmpfile"

echo ""

# Large files finder
print_header "Top 10 Largest Files in /var"

if [ -d /var ] && [ -r /var ]; then
    find /var -type f -exec du -h {} + 2>/dev/null | sort -rh | head -10 || echo "Unable to scan /var directory"
else
    echo "Directory /var is not accessible"
fi

# Large directories
print_header "Disk Usage by Directory (Top 10)"

du -h --max-depth=1 / 2>/dev/null | sort -rh | head -10 || echo "Unable to calculate directory sizes"

echo ""
echo -e "${GREEN}Disk usage report completed.${NC}"

# Exit with error code if alerts found
if [ "$alert_found" -eq 1 ]; then
    echo -e "${RED}Warning: Some partitions exceed the threshold!${NC}"
fi
