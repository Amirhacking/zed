#!/usr/bin/env bash
GrepDuo='/' #key dump
BotH='Lc'
tgcli_version="180329-nightly"
luarocks_version=2.4.2
lualibs=(
'luasec'
'luarepl'
'lbase64 20120807-3'
'luafilesystem'
'lub'
'luaexpat'
'redis-lua'
'lua-cjson'
'fakeredis'
'xml'
'feedparser'
'serpent'
)
red() {
  printf '\e[1;31m%s\n\e[0;39;49m' "$@"
}
blue() {
  printf '\e[1;35m%s\n\e[0;39;49m' "$@"
}
white() {
  printf '\e[1;37m%s\n\e[0;39;49m' "$@"
}

function c() {
sudo apt-get update 
sudo apt-get upgrade
sudo apt-get install git redis-server lua5.2 liblua5.2-dev lua-lgi libnotify-dev unzip tmux -y && add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update 
sudo apt-get upgrade 
sudo apt-get install libconfig++9v5 libstdc++6 
sudo apt autoremove
sudo apt-get install gcc-4.9
sudo apt-get --yes install wget libconfig9 libjansson4 lua5.2 liblua5.2 make unzip git redis-server g++ whois fortune fortunes
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get install g++-4.7 -y c++-4.7 -y
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install libreadline-dev -y libconfig-dev -y libssl-dev -y lua5.2 -y liblua5.2-dev -y lua-socket -y lua-sec -y lua-expat -y libevent-dev -y make unzip git redis-server autoconf g++ -y libjansson-dev -y libpython-dev -y expat libexpat1-dev -y
sudo apt-get install screen -y
sudo apt-get install tmux -y
sudo apt-get install libstdc++6 -y
sudo apt-get install lua-lgi -y
sudo apt-get install libnotify-dev -y
sudo apt install libconfig++9v5
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install gcc-4.9
sudo apt-get upgrade libstdc++6
sudo apt-get install libcurl-dev
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libcurl4-gnutls-dev
wget http://luarocks.org/releases/luarocks-${luarocks_version}.tar.gz;tar zxpf luarocks-${luarocks_version}.tar.gz;cd luarocks-${luarocks_version} && ./configure; sudo make bootstrap;sudo luarocks install luasocket;sudo luarocks install luasec;sudo luarocks install redis-lua;sudo luarocks install lua-term;sudo luarocks install serpent;sudo luarocks install dkjson;sudo luarocks install lanes;sudo luarocks install Lua-cURL
chmod +x run
echo -e "\e[1m\e[32m==> \e[97mInstall Packages completed\e[0m"
echo -e "\e[1m\e[32m==> \e[97mOPEN BY @MR_KOURD19\e[0m"
} 

function loginCLI() {
./tg -p LcCli --login --phone=${1}
} 
function loginApi() {
./tg -p LcApi --login --bot=${1}
} 
case $1 in
loginCli)
blue "• شماره ربات Cli را همراه +98 وارد کنید:"
read Num_MPC
loginCLI ${Num_MPC}
echo -e "\e[1m\e[32m=> \e[97m• با موفقیت انجام شد\e[0m"
echo -e "\e[1m\e[32m=> \e[97mBy : @Mr_Kourd19 , ChTm : @LEADERUPDATE\e[0m"
exit;;
loginApi)
blue "• توکن ربات Api را وارد کنید:"
read Num_MPC
loginApi ${Num_MPC}
echo -e "\e[1m\e[32m=> \e[97m• با موفقیت انجام شد\e[0m"
echo -e "\e[1m\e[32m=> \e[97mBy : @Mr_Kourd19 , ChTm : @LEADERUPDATE\e[0m"
exit;;
install)
c
exit;;
esac
exit 0
