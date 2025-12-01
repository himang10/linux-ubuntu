#!/bin/bash
#
# backup.sh - Basic Backup Script for Linux Ubuntu
# Compatible with Bash 3.0 and above
#
# Usage: ./backup.sh <source_directory> <backup_directory>
#

set -e

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

print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_info() {
    echo -e "${YELLOW}$1${NC}"
}

usage() {
    echo "Usage: $0 <source_directory> <backup_directory>"
    echo ""
    echo "Arguments:"
    echo "  source_directory   Directory to backup"
    echo "  backup_directory   Directory where backup will be stored"
    echo ""
    echo "Example:"
    echo "  $0 /home/user/documents /backup"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    print_error "Missing arguments"
    usage
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    print_info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Generate timestamp for backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${TIMESTAMP}.tar.gz"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

print_info "=========================================="
print_info "Backup Configuration"
print_info "=========================================="
echo "Source: $SOURCE_DIR"
echo "Destination: $BACKUP_PATH"
echo "Date: $(date)"
echo ""

# Create backup
print_info "Creating backup..."

if tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"; then
    # Get backup file size
    if [ -f "$BACKUP_PATH" ]; then
        BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
        print_success "=========================================="
        print_success "Backup completed successfully!"
        print_success "=========================================="
        echo "Backup file: $BACKUP_PATH"
        echo "Backup size: $BACKUP_SIZE"
        
        # Generate checksum
        if command -v md5sum >/dev/null 2>&1; then
            CHECKSUM=$(md5sum "$BACKUP_PATH" | cut -d' ' -f1)
            echo "MD5 Checksum: $CHECKSUM"
        fi
    fi
else
    print_error "Backup failed!"
    exit 1
fi

# List recent backups
echo ""
print_info "Recent backups in $BACKUP_DIR:"
find "$BACKUP_DIR" -maxdepth 1 -name "backup_*.tar.gz" -exec ls -lh {} \; 2>/dev/null | tail -5 || echo "No previous backups found"

echo ""
print_success "Backup operation completed."
