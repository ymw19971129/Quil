# 1.安装节点
function install_node() {

# 增加swap空间
sudo mkdir /swap
sudo fallocate -l 32G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile
echo '/swap/swapfile swap swap defaults 0 0' >> /etc/fstab

# 向/etc/sysctl.conf文件追加内容
echo -e "\n# 自定义最大接收和发送缓冲区大小" >> /etc/sysctl.conf
echo "net.core.rmem_max=600000000" >> /etc/sysctl.conf
echo "net.core.wmem_max=600000000" >> /etc/sysctl.conf

echo "配置已添加到/etc/sysctl.conf"

# 重新加载sysctl配置以应用更改
sysctl -p

sudo apt -q update
sudo apt-get install git wget tmux tar cpulimit base58 ubuntu-advantage-tools gawk -y

##下载go
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz
sudo rm go1.20.14.linux-amd64.tar.gz

##配置go环境
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GO111MODULE=on' >> ~/.bashrc
echo 'export GOPROXY=https://goproxy.cn,direct' >> ~/.bashrc
source ~/.bashrc

##安装grpcurl
cd ~ && wget https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_amd64.deb
dpkg -i grpcurl_1.9.1_linux_amd64.deb && rm grpcurl_1.9.1_linux_amd64.deb

bin_dir="$HOME/go/bin"
if [ ! -d "$bin_dir" ]; then
    echo "Creating directory: $bin_dir"
    mkdir -p "$bin_dir"
fi

mv /usr/bin/grpcurl $HOME/go/bin/grpcurl
echo 'export PATH="$HOME/go/bin:$PATH"' >> /etc/bash.bashrc
source /etc/bash.bashrc

mkdir -p /root/backup/ /root/scripts/ /root/scripts/log/

##切换分支
cd ~ && git clone https://source.quilibrium.com/quilibrium/ceremonyclient.git
cd ~/ceremonyclient/ && git checkout release

##设置cpu使用率
find /root/ceremonyclient/node/ -type f -name release_autorun.sh -exec sed -i 's/cpulimit -l [0-9]\+/cpulimit -l 90/g' {} +

##写入服务文件
echo '[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
ExecStart=/root/ceremonyclient/node/release_autorun.sh
CPUQuota=vcpuconut%

[Install]
WantedBy=multi-user.target' > /lib/systemd/system/ceremonyclient.service

##更改cpu使用率,此设置没效果
vcpuconut=$(nproc)
sed -i "s/CPUQuota=vcpuconut%/CPUQuota=$(($vcpuconut * 90))%/g"  /lib/systemd/system/ceremonyclient.service

##加载服务并启动
sudo systemctl daemon-reload && sudo systemctl enable ceremonyclient
service ceremonyclient start

echo ====================================== 安装完成 请退出脚本使用screen 命令或者使用查看日志功能查询状态=========================================

}

# 2.查看节点日志
function check_service_status() {
    sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
}

# 3.配置监听端口8337和88338
function listen_addr() {
# 修改配置文件 .config/config.yml
sed -i 's/listenGrpcMultiaddr:.*/listenGrpcMultiaddr: "\/ip4\/127.0.0.1\/tcp\/8337"/' ~/ceremonyclient/node/.config/config.yml
sed -i 's/listenRESTMultiaddr:.*/listenRESTMultiaddr: "\/ip4\/127.0.0.1\/tcp\/8338"/' ~/ceremonyclient/node/.config/config.yml
sed -i 's/\/ip4\/0.0.0.0\/udp\/8336\/quic/\/ip4\/0.0.0.0\/tcp\/8336/g' /root/ceremonyclient/node/.config/config.yml

# 检查 .config/config.yml 配置结果
grep -E 'listenGrpcMultiaddr|listenRESTMultiaddr' ~/ceremonyclient/node/.config/config.yml
}

# 4. 检查peerid
function check_peerid() {
	cd ~/ceremonyclient/node && ./node-1.4.18-linux-amd64 --peer-id
}

# 5. 获取PeerManifests信息
function get_PeerManifests() {
	# 检查 .config/config.yml 配置结果
	grep -E 'listenGrpcMultiaddr|listenRESTMultiaddr' ~/ceremonyclient/node/.config/config.yml
	# 获取节点的 peer_id 并使用 base58 解码，再进行 base64 编码，并使用 grpcurl 获取 PeerManifests 信息
	peer_id=$($HOME/go/bin/grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetNodeInfo | grep -o '"peerId": *"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' | base58 -d | base64) && $HOME/go/bin/grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetPeerManifests | grep -A 15 -B 1 "$peer_id"
}

# 6. 检查节点是否可见
function check_vaild() {
	bootstrap_peers=(
	"EiDpYbDwT2rZq70JNJposqAC+vVZ1t97pcHbK8kr5G4ZNA=="
	"EiCcVN/KauCidn0nNDbOAGMHRZ5psz/lthpbBeiTAUEfZQ=="
	"EiDhVHjQKgHfPDXJKWykeUflcXtOv6O2lvjbmUnRrbT2mw=="
	"EiDHhTNA0yf07ljH+gTn0YEk/edCF70gQqr7QsUr8RKbAA=="
	"EiAnwhEcyjsHiU6cDCjYJyk/1OVsh6ap7E3vDfJvefGigw=="
	"EiB75ZnHtAOxajH2hlk9wD1i9zVigrDKKqYcSMXBkKo4SA=="
	"EiDEYNo7GEfMhPBbUo+zFSGeDECB0RhG0GfAasdWp2TTTQ=="
	"EiCzMVQnCirB85ITj1x9JOEe4zjNnnFIlxuXj9m6kGq1SQ=="
	)

	# Run the grpcurl command and capture its output
	output=$($HOME/go/bin/grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetNetworkInfo)

	# Check if any of the specific peers are in the output
	visible=false
	for peer in "${bootstrap_peers[@]}"; do
	    if [[ $output == *"$peer"* ]]; then
	        visible=true
	        echo "You see $peer as a bootstrap peer"
	    else
	        echo "Peer $peer not found"
	    fi
	done

	if $visible ; then
	    echo "Great, your node is visible!"
	else
	    echo "Sorry, your node is not visible. Please restart your node and try again."
	fi
}

# 7.重启节点
function restart_service() {
	service ceremonyclient restart
}

# 8.停止节点
function stop_service() {
	service ceremonyclient stop
}

# 9.卸载节点
function clear_service() {
	service ceremonyclient stop
	rm -rf /root/ceremonyclient
}



# 主菜单
function main_menu() {
	echo "1. 安装服务节点"
    echo "2. 查看节点日志"  
    echo "3. 配置监听端口8337和88338"
    echo "4. 检查peerid"
    echo "5. 获取PeerManifests信息"
    echo "6. 检查节点是否可见"
    echo "7. 重启节点"
    echo "8. 停止节点"
    echo "9. 卸载节点"

    read -p "请输入选项（1-9）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;  
	3) listen_addr ;;
	4) check_peerid ;;
	5) get_PeerManifests ;;
	6) check_vaild ;;
	7) restart_service ;;
	8) stop_service ;;
	9) clear_service ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
