# Stacks Dev Kit Shell

[![](https://img.shields.io/badge/version-1.0.1-brightgreen.svg)](https://github.com/skai-zhang/DevKit-Shell/commits/master)  [![](https://img.shields.io/badge/license-GLPv3-red.svg)](https://github.com/skai-zhang/DevKit-Shell/blob/master/LICENSE)

支持系统: Debian

支持组件: OpenJDK、MySQL、Redis

## 使用方法

在服务器上使用`root`权限登录, 然后复制粘贴下方代码, 回车开始执行

> wget -N --no-check-certificate https://raw.githubusercontent.com/skai-zhang/DevKit-Shell/master/devkit.sh && bash devkit.sh

## 组件指令

MySQL

* 启动: `service mysql start`
* 停止: `service mysql stop`
* 重启: `service mysql restart`

Redis

* 启动: `service redis start`
* 停止: `service redis stop`
* 重启: `service redis restart`
