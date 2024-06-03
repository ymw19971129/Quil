#安装节点
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
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

mkdir -p /root/backup/ /root/scripts/ /root/scripts/log/

##切换分支
cd ~ && git clone https://source.quilibrium.com/quilibrium/ceremonyclient.git
cd ~/ceremonyclient/ && git checkout release

##写入服务文件
echo '[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
ExecStart=/root/ceremonyclient/node/release_autorun.sh
CPUQuota=$((`nproc` * 100))%

[Install]
WantedBy=multi-user.target' > /lib/systemd/system/ceremonyclient.service

##加载服务并启动
sudo systemctl daemon-reload && sudo systemctl enable ceremonyclient
service ceremonyclient start

echo ====================================== 安装完成 请退出脚本使用screen 命令或者使用查看日志功能查询状态=========================================

}

# 查看节点日志
function check_service_status() {
    sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
}

# 重启节点
function restart_service() {
	service ceremonyclient restart
}

# 停止节点
function stop_service() {
	service ceremonyclient stop
}

# 卸载节点
function clear_service() {
	service ceremonyclient stop
	rm -rf /root/ceremonyclient
}

# 主菜单
function main_menu() {
	echo "1. 安装服务节点"
    echo "2. 查看节点日志"
    echo "3. 重启节点"
    echo "4. 停止节点"
    echo "5. 卸载节点"

    read -p "请输入选项（1-5）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;  
    3) restart_service ;;
	4) stop_service ;;
	5) clear_service ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu