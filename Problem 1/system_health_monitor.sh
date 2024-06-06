#!/bin/bash

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Log file location
LOG_FILE="/var/log/system_health.log"

# Function to log messages

log_message() {
    local MSG="$1"
    echo "$(date): ${MSG}" | tee -a ${LOG_FILE}
}

# Function to check CPU usage
check_cpu_usage() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    if (( $(echo "${CPU_USAGE} > ${CPU_THRESHOLD}" | bc -l) )); then
        log_message "High CPU usage detected: ${CPU_USAGE}%"
    fi
}

# Function to check memory usage
check_memory_usage() {
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    if (( $(echo "${MEM_USAGE} > ${MEMORY_THRESHOLD}" | bc -l) )); then
        log_message "High memory usage detected: ${MEM_USAGE}%"
    fi
}

# Function to check disk usage
check_disk_usage() {
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    if (( DISK_USAGE > DISK_THRESHOLD )); then
        log_message "High disk usage detected: ${DISK_USAGE}%"
    fi
}

# Function to check running processes
check_running_processes() {
    RUNNING_PROCESSES=$(ps aux | wc -l)
    log_message "Number of running processes: ${RUNNING_PROCESSES}"
}

# Main function to run checks
run_checks() {
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_running_processes
}

# Infinite loop to run checks periodically
while true; do
    run_checks
    sleep 60  # Run checks every 60 seconds
done
