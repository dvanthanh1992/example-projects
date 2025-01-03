#!/bin/bash

set -e

ACTION=$1
NUM_CONTAINERS=$2
HUB_IP=$3

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 {install|hub|node|restart|stop} NUM_CONTAINERS [HUB_IP]"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    SUDO_CMD="sudo"
else
    SUDO_CMD=""
fi

function check_dns() {
    echo "Checking DNS resolution..."
    if ping -c 1 google.com &> /dev/null; then
        echo "DNS resolution is working."
    else
        echo "DNS resolution failed. Retrying..."
        for i in {1..30}; do
            sleep 6
            if ping -c 1 google.com &> /dev/null; then
                echo "DNS resolution is working now."
                return 0
            fi
            echo "Retrying DNS resolution ($i/30)..."
        done
        echo "DNS resolution failed after multiple attempts."
        exit 1
    fi
}

function docker_install() {
    check_dns
    $SUDO_CMD apt-get update -y && $SUDO_CMD apt-get install -y ca-certificates curl gnupg
    $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.asc
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO_CMD apt-get update -y
    $SUDO_CMD apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    $SUDO_CMD chmod 600 /var/run/docker.sock
    $SUDO_CMD docker version
}

function selenium_hub {
    echo "Starting Selenium Hub ..."
    $SUDO_CMD docker run -d -p 4442-4444:4442-4444 \
                        --name selenium-hub \
                        selenium/hub:4.26.0-20241101
    echo "Completed running Selenium Hub Container"
    echo "-----------------------------------------"
    echo "Starting Performance Testing Management UI ..."
    $SUDO_CMD docker run -d -p 8888:8888 \
                        -e HUB_PUBLIC_IP=${HUB_IP} \
                        --network host \
                        --name mgmt-ui \
                        dvanthanh1992/iij-selenium-test:latest
    echo "Completed running Performance Testing Management UI Container"
}

function selenium_node() {
    echo "Starting $NUM_CONTAINERS containers with hub IP: $HUB_IP"
    for ((i = 1; i <= NUM_CONTAINERS; i++)); do
        PORT=$((5560 + $i))
        $SUDO_CMD docker run -d -p ${PORT}:${PORT} \
            --name grid-$i \
            --shm-size="30g" \
            -e SE_EVENT_BUS_HOST=${HUB_IP} \
            -e SE_EVENT_BUS_PUBLISH_PORT=4442 \
            -e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
            -e SE_NODE_HOST=$(hostname -I | awk '{print $1}') \
            -e SE_NODE_PORT=${PORT} \
            -e SE_VNC_NO_PASSWORD=1 \
            -e SE_NODE_OVERRIDE_MAX_SESSIONS=true \
            -e SE_NODE_MAX_SESSIONS=1 \
            selenium/node-chrome:4.26.0-20241101
    done
    echo "-----------------------------------------"
    echo "Completed running Selenium Node Container"
    echo "-----------------------------------------"
}

function docker_restart() {
    running_containers=$($SUDO_CMD docker ps -q)
    if [ -n "$running_containers" ]; then
        echo "Stopping running containers..."
        $SUDO_CMD docker stop $running_containers
        echo "Running containers stopped."
    else
        echo "No running containers to stop."
    fi

    echo "------------"
    all_containers=$($SUDO_CMD docker ps -aq)
    if [ -n "$all_containers" ]; then
        echo "Starting all containers..."
        $SUDO_CMD docker start $all_containers
        echo "All containers restarted."
    else
        echo "No containers to start."
    fi

    echo "----------------------------------"
    echo "Operation completed."
}

function docker_stop() {
    running_containers=$($SUDO_CMD docker ps -q)
    if [ -n "$running_containers" ]; then
        echo "Stopping running containers..."
        $SUDO_CMD docker stop $running_containers
        echo "Running containers stopped."
    else
        echo "No running containers to stop."
    fi

    echo "------------"

    all_containers=$($SUDO_CMD docker ps -aq)
    if [ -n "$all_containers" ]; then
        echo "Removing all containers..."
        $SUDO_CMD docker rm $all_containers
        echo "All containers removed."
    else
        echo "No containers to remove."
    fi

    echo "----------------------------------"
    echo "Operation completed."
}

case $ACTION in
    install)
        docker_install
        ;;
    hub)
        selenium_hub
        ;;
    node)
        selenium_node
        ;;
    restart)
        docker_restart
        ;;
    stop)
        docker_stop
        ;;
    *)
        echo "Invalid option: $ACTION"
        echo "Usage: $0 {install|hub|node|restart|stop} NUM_CONTAINERS [HUB_IP]"
        exit 1
        ;;
esac
