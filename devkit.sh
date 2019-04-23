#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 检查权限
[ $(id -u) != "0" ] && { echo "发生错误: 请使用root权限执行脚本"; exit 1; }

# 检查系统
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ]; then
  OS=CentOS
  [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
  [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
  [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ]; then
  OS=CentOS
  CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ]; then
  OS=Ubuntu
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
  [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
  echo "不支持当前操作系统,请与开发者联系"
  kill -9 $$
fi

# 首屏欢迎
cat << EOF
=========================================
|        ___          _  ___ _          |
|       |   \ _____ _| |/ (_) |_        |
|       | |) / -_) V / ' <| |  _|       |
|       |___/\___|\_/|_|\_\_|\__|       |
|                                       |
|                v 1.0.1                |
-----------------------------------------
|        Developed by sKai-Zhang        |
-----------------------------------------
|             按下回车键继续            |
=========================================
EOF
echo "Current Operating System: $OS"
echo "Component: OpenJDK MySQL Redis"
read -n 1

# 安装Java环境
install_java(){
  echo "开始安装OpenJDK...";
  sudo apt-get install default-jdk -y
}

# 检查Java环境
check_java(){
  java_version=`java -version 2> /dev/null`
  if [ $? -ne 0 ]; then
    echo ""
    read -r -p "未检测到Java运行环境,是否安装? [Y/n] " input
    case $input in
      [yY][eE][sS]|[yY])
        install_java
      ;;

      [nN][oO]|[nN])
        echo ""
        echo "跳过Java环境安装"
      ;;

      *)
        echo "无效的选择"
        check_java
      ;;
    esac
  else
    echo ""
    java_version=`java -version 2>&1 |awk 'NR==1{ gsub(/"/,""); print $3 }'`
    echo -e "OPJDK: \033[33m已安装($java_version)\033[0m"
  fi
}

# 安装MySQL
install_mysql(){
  echo "开始安装MySQL...";
  wget -P /root https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb
  dpkg -i /root/mysql-apt-config_0.8.12-1_all.deb
  sudo apt-get update
  sudo apt-get install mysql-server -y
  rm -f /root/mysql-apt-config_0.8.12-1_all.deb
}

# 检查MySQL
check_mysql(){
  sudo service mysql restart
  mysql_start=`service mysql status 2> /dev/null`
  if [ $? -ne 0 ]; then
    echo ""
    read -r -p "未检测到MySQL,是否安装? [Y/n] " input
    case $input in
      [yY][eE][sS]|[yY])
        install_mysql
      ;;

      [nN][oO]|[nN])
        echo ""
        echo "跳过MySQL安装"
      ;;

      *)
        echo "无效的选择"
        check_mysql
      ;;
    esac
  else
    echo ""
    mysql_version=`mysql -V 2>&1 |awk 'NR==1{ gsub(/"/,""); print $3 }'`
    echo -e "MySQL: \033[33m已安装($mysql_version)\033[0m"
  fi
}

# 安装Redis
install_redis(){
  echo "开始安装Redis...";
  sudo apt-get update
  sudo apt-get install redis-server -y
}

# 检查Redis
check_redis(){
  sudo service redis restart
  mysql_start=`service redis status 2> /dev/null`
  if [ $? -ne 0 ]; then
    echo ""
    read -r -p "未检测到Redis,是否安装? [Y/n] " input
    case $input in
      [yY][eE][sS]|[yY])
        install_redis
      ;;

      [nN][oO]|[nN])
        echo ""
        echo "跳过Redis安装"
      ;;

      *)
        echo "无效的选择"
        check_redis
      ;;
    esac
  else
    echo ""
    redis_version=`redis-server -v 2>&1 |awk 'NR==1{ gsub(/"/,""); print $3 }'`
    echo -e "Redis: \033[33m已安装(${redis_version#*=})\033[0m"
  fi
}

# 判断系统是否支持
if [ $OS == "Debian" ]; then
  echo "检查更新..."
  # 更新资源列表
  apt-get update
  # 检查Java环境
  check_java
  # 检查MySQL
  check_mysql
  # 检查Redis
  check_redis
else
  # 不支持的系统
  echo "当前仅支持Debian,安装程序终止"
  exit 1
fi

echo ""
# 程序结束提示
echo "安装程序执行完毕,感谢你的支持";
exit 1