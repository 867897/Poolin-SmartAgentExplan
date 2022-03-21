set -ex
#必填
host_coin=DASH

#选填
proxy_port=
docker_name=

#--------------further founction settings------------
#均为可填选项
#The following are optional options

#连接上一级服务的模式 (代理默认AUTO)
#Mode of connect to the service (default AUTO)
  # - AUTO     : Select the best server according to network automatically
  # - SEQUENCE : Dynamically select the server in ip list according to the priority by order
  # - CONFUSE  : Randomly select a server in ip list and each connection time does not exceed 60 minutes
up_server_mode=

#`list` 指定当前代理的上级服务地址，可用","分隔多个
# List of pool services, which can be separated by ","
up_server_address=''

#钉钉/Slack notify token设置
# Communication software token settings, which will be used for some warning notifications
notify_token=""

#notify当前代理标签
# Tag or label of this proxy-agent when warning notifications
host=""

#设置矿机统一子账号(默认为空,矿机设置生效,非空则以代理设置为准)
# Set the sub-account of miners(When not empty will override the miner's settings)
user_name=""

#健康检查检测失败时间设置
# Settings of Maximum Delay Tolerance Time of Network (minute)
health_check_fail_duration=

#share 拒绝数计量 (ETH A10/A11)
# Numbers of share can be rejected （For ETH A10/A11 ONLY)
reject_share_count=
#----------------------------------------------------


host_coin=`echo $host_coin| tr 'a-z' 'A-Z'`
#  docker_name
if [ -z "${docker_name}" ]; then
  docker_name=proxy_`echo $host_coin| tr 'A-Z' 'a-z'`
  echo "docker_name not set, default value: ${docker_name}"
fi

# proxy_port
if [ -z "${proxy_port}" ]; then
        case $host_coin in
                "BTC")
                        proxy_port=8001
                        ;;
                "LTC")
                        proxy_port=8002
                        ;;
                "DASH")
                        proxy_port=8003
                        ;;
                "ETH")
                        proxy_port=8005
                        ;;
                "ZEC")
                        proxy_port=8006
                        ;;
                "BCH")
                        proxy_port=8010
                        ;;
                "DCR")
                        proxy_port=8012
                        ;;
                "BSV")
                        proxy_port=8017
                        ;;
                "HNS")
                        proxy_port=8020
                        ;;
                "CKB")
                        proxy_port=8023
                        ;;
                "ZEN")
                        proxy_port=8024
                        ;;
                "STC")
                        proxy_port=8026
                        ;;
                *)
                        echo "$host_coin not support by proxy yet!"
                        exit 1;
                        ;;
        esac
  echo "proxy_port not set, default value: ${proxy_port}"
fi

docker system prune -a -f

docker_version=registry.cn-beijing.aliyuncs.com/poolin_public/proxy_dash:latest
docker pull ${docker_version}

docker stop -t 3 ${docker_name} || /bin/true
docker rm ${docker_name} || /bin/true

docker run -it --restart always -d \
        --dns 119.29.29.29 \
        --dns 223.5.5.5 \
        --privileged=true \
        --env EXEC_FILE=${exec_file} \
        --env UP_SERVER_ADDRESS=${up_server_address} \
        --env UP_SERVER_MODE=${up_server_mode} \
        --env HOST_COIN=${host_coin} \
        --env USER_NAME=${user_name} \
        --env NOTIFY_TOKEN=${notify_token} \
        --env HOST=${host} \
        --env HEALTH_CHECK_FAIL_DURATION=${health_check_fail_duration} \
        --env REJECT_SHARE_COUNT=${reject_share_count} \
        --log-opt mode=non-blocking --log-opt max-buffer-size=4m --log-driver journald \
        -v /work:/work \
        --name ${docker_name} \
        -p ${proxy_port}:1801 \
	-p 18003:1812 \
        ${docker_version}
