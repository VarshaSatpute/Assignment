#!/bin/bash

# Configuration
SRC_DIR="/path/to/source/directory"
REM_USER="remote_user"
REM_HOST="remote_host"
REM_DIR="/path/to/remote/directory"
LOG_FILE="/var/log/backup.log"
BACKUP_NAME="backup-$(date +'%Y-%m-%d_%H-%M-%S').tar.gz"

# Function to log messages
log_message() {
    local MSG="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S'): ${MSG}" | tee -a ${LOG_FILE}
}

# Function to create a compressed archive of the source directory
create_archive() {
    tar -czf "/tmp/${BACKUP_NAME}" -C "$(dirname ${SRC_DIR})" "$(basename ${SRC_DIR})"
    if [[ $? -ne 0 ]]; then
        log_message "Failed to create archive of ${SRC_DIR}."
        exit 1
    else
        log_message "Successfully created archive: /tmp/${BACKUP_NAME}."
    fi
}

# Function to transfer the archive to the remote server
transfer_backup() {
    rsync -avz -e ssh "/tmp/${BACKUP_NAME}" "${REM_USER}@${REM_HOST}:${REM_DIR}"
    if [[ $? -ne 0 ]]; then
        log_message "Failed to transfer archive to ${REM_HOST}:${REM_DIR}."
        exit 1
    else
        log_message "Successfully transferred archive to ${REM_HOST}:${REM_DIR}."
    fi
}

# Function to clean up local archive file
cleanup() {
    rm -f "/tmp/${BACKUP_NAME}"
    if [[ $? -ne 0 ]]; then
        log_message "Failed to delete local archive: /tmp/${BACKUP_NAME}."
    else
        log_message "Successfully deleted local archive: /tmp/${BACKUP_NAME}."
    fi
}

# Main function to perform the backup
perform_backup() {
    log_message "Starting backup process for ${SRC_DIR}."
    create_archive
    transfer_backup
    cleanup
    log_message "Backup process completed successfully."
}

# Execute the backup
perform_backup
