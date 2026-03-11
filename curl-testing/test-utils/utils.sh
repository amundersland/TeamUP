cyan "utils.sh"

bg_start_spring_boot(){
    local sleepSec=${1:-7}

    ./mvnw spring-boot:run > /tmp/app.log 2>&1 &
    local pid=$!
    echo $pid > /tmp/app.pid
    
    echo -e "\033[33mStarted\033[0m spring-boot in the background. PID: \033[36m$pid\033[0m. Waiting $sleepSec seconds..."
    sleep $sleepSec
}

bg_stop_spring_boot(){
    local pid=$(cat /tmp/app.pid)
    kill $pid
    sleep 1
    
    if kill -0 $pid 2>/dev/null; then
        kill -9 $pid
    fi

    if kill -0 $pid 2>/dev/null; then
        echo "Could not stop process with PID $pid"
    else
        echo -e "Stopped process with PID \033[36m$pid\033[0m"
    fi
}

echo  " $(symbol_green_checkmark)"