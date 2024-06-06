URL="http://accuknox.com/health"  
LOG_FILE="/var/log/application_status.log"
STATUS_UP_CODES=(200 201 202)  # HTTP status codes that indicate the application is up

# Function to log messages
log_messages() {
    local MESSAGE="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S'): ${MESSAGE}" | tee -a ${LOG_FILE}
}

# Function to check application status
check_accuknox_application_status() {
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${URL})
    if [[ " ${STATUS_UP_CODES[@]} " =~ " ${HTTP_STATUS} " ]]; then
        log_messages "Application is UP. HTTP status code: ${HTTP_STATUS}."
    else
        log_messages "Application is DOWN. HTTP status code: ${HTTP_STATUS}."
    fi
}

# Execute the status check
check_accuknox_application_status
