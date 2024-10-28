# 1. 拉取节点客户端和安装qclient客户端
function install_node() {

cd ~ && apt update && apt install wget sudo vim tar curl bsdmainutils base58 screen git -y
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz
sudo rm go1.20.14.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GO111MODULE=on' >> ~/.bashrc
echo 'export GOPROXY=https://goproxy.cn,direct' >> ~/.bashrc
source ~/.bashrc
cd ~ && git clone https://github.com/quilibriumnetwork/ceremonyclient.git
cd ~/ceremonyclient/ && git checkout release
cd ~/ceremonyclient/client/
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.1" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.2" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.3" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.4" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.6" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.8" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.12" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.13" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.15" \
wget "https://releases.quilibrium.com/qclient-2.0.1-linux-amd64.dgst.sig.16"
chmod +x qclient-2*

}

# 2. 检查peerid
function check_peerid() {
	cd ~/ceremonyclient/node && ./node-2.0.2.2-linux-amd64 --peer-id
}

# 3. 用qclient查询余额
function Unclaimed_alance() {
cd ~/ceremonyclient/node/
./../client/qclient-2.0.1-linux-amd64 token balance
}

# 主菜单
function main_menu() {
	echo "1. 安装节点"
    echo "2. 检查peerid"  
    echo "3. 用qclient查询余额"

    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_peerid ;;  
	3) Unclaimed_alance ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
