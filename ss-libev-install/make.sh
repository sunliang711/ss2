#!/bin/bash
proxy=0
if [[ "$1" == "-p" ]];then
	proxy=1
fi
shopt -s expand_aliases
if (("$proxy"==1));then
	echo "Using proxy..."
    socksproxy="socks5://10.0.0.1:23456"
	git config --global http.proxy "$socksproxy"
	git config --global https.proxy "$socksproxy"
	alias curl="curl --socks5 $socksproxy"
fi
#sh -c 'printf "deb http://httpredir.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list'
apt-get update -y
apt install -y curl gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libudns-dev automake git

ROOT=~/build-ss-libev
sodiumVer=1.0.12
mbedtlsVer=2.5.1
rm -rf "$ROOT" >/dev/null 2>&1
mkdir -pv "$ROOT"
outputdir="$ROOT"/output
mkdir -pv "$outputdir"

cd "$ROOT"

#download shadowsocks-libev
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init --recursive
cd ..

#remove libsodium
apt-get remove libsodium* -y
apt purge libsodium* -y

#compile libsodium
echo "downloading libsodium..."
curl  https://download.libsodium.org/libsodium/releases/libsodium-${sodiumVer}.tar.gz -O
echo "extract libsodium..."
tar xf libsodium-${sodiumVer}.tar.gz
cd libsodium*
./configure --prefix=/usr && make
make install
cp ./src/libsodium/.libs/libsodium.so.* "$outputdir"
#ldconfig

cd ..

#compile mbedtls
echo "downloading mbedtls..."
curl  https://tls.mbed.org/download/mbedtls-${mbedtlsVer}-gpl.tgz -O
echo "extract mbedtls..."
tar xf mbedtls*tgz
cd mbedtls*
make SHARED=1 CFLAGS=-fPIC
make install
cp ./library/lib* "$outputdir"
#ldconfig

cd ..

cd shadowsocks-libev
./autogen.sh && ./configure && make
cp ./src/ss-* "$outputdir"
#make install

echo "All files generated are in $outputdir"

#apt install -y rng-tools
#systemctl start rng-tools
#systemctl enable rng-tools

#configDir="/etc/shadowsocks-libev"
#mkdir "$configDir"
#cat<<EOF>"$configDir/config.json"
#{
#    "server":"0.0.0.0",
#    "server_port":8388,
#    "password":"8388",
#    "method":"chacha20",
##    "local_port":1080,
#    "timeout":60
#}
#EOF



# 然后进入 shadowsocks-libev 目录下进行编译
# $ cd shadowsocks-libev
# $ dpkg-buildpackage -b -us -uc -i
# $ cd ..
# $ dpkg -i shadowsocks-libev*.deb
# 编译是通过生成 deb 包然后进行安装，其实也可以通过 make 的方式来进行安装，但使用 deb 包安装会自动生成开启启动的脚步在 /etc/init.d 目录下,采用哪种方式安装就因人而异了
