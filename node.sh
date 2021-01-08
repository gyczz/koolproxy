#!/bin/sh
clear
function menu ()
{
    cat << EOF

#######  #####  #######  #####   #####   #####  
#       #     # #    #  #     # #     # #     # 
#       #     #     #   #     # #     # #     # 
######   #####     #     #####   #####   #####  
      # #     #   #     #     # #     # #     # 
#     # #     #   #     #     # #     # #     # 
 #####   #####    #      #####   #####   #####                                                

==============================================
    填写邀请码：587888  免费获取15张加成卡！
==============================================
玩客云刷armbian视频教程：https://post.smzdm.com/p/awx4rqkk/

`echo -e "\033[35m 1)32位设备安装（玩客云）\033[0m"`
`echo -e "\033[35m 2)64位设备安装（斐讯N1）\033[0m"`
`echo -e "\033[35m 3)更换Mac地址\033[0m"`
`echo -e "\033[35m 4)卸载甜糖\033[0m"`
`echo -e "\033[35m 5)星愿一键领取\033[0m"`
`echo -e "\033[35m 6)重启设备\033[0m"`
`echo -e "\033[35m 7)退出\033[0m"`
EOF
	if [ -d /root/587888/1/ ]; then
		zhuangtai="甜糖已安装！"
	else
		zhuangtai="甜糖未安装！"
	fi

read -p "${zhuangtai}请确认操作：" num
case $num in
    1)
		install32
      ;;
    2)
		install64
      ;;
    3)
		changeMac
	;;
    4)
		uninstall
	;;
	5)
	echo "功能已完善正式上线~~~

	脚本引用开源Jq解析json，部署过程中会自动安装Jq，可能需要输入Y回车继续。

	开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！

	"
	read -p "按任意键继续..."
	sudo apt-get install jq
	login
		;;
    6)
		reboot
		;;
	7)
		exit 0
esac
}

function login()
{
read -p "请输入手机号码：" tel
if [ ${#tel} = 11 ];then
	codeText=$(curl -X POST http://tiantang.mogencloud.com/web/api/login/code?phone=$tel|jq '.errCode')
	if [ $codeText = 0 ];then
		read -p "验证码发送成功，请输入：" code
		if [ ${#code} = 6 ];then
			tokenText=$(curl -X POST http://tiantang.mogencloud.com/web/api/login?phone=$tel\&authCode=$code|jq '.data.token' | sed 's/\"//g')
			if [ $tokenText = null ];then
				echo "登录失败，请重试！"
			else
				echo $tokenText > token.txt
				read -p "登录成功，请输入Server酱监控SCKEY,不使用直接按回车：" sckey
				if [ ${#sckey} -gt 30 ];then 
					echo $sckey > sckey.txt
				fi
				#写监控脚本
				cd /root/587888/
				wget https://dachui.co/ttnode/587888.sh
				chmod -R 777 *
				sed -i '15a 30 4 * * *	root	/root/587888/587888.sh' /etc/crontab
				echo "部署成功，每天凌晨4点30分准时收取星愿！5秒后返回主菜单！"
				sleep 5s
				menu
			fi
		else
			echo "验证码输入错误！"
		fi
	else
	echo "发送验证码失败，请重试！"
	fi
else
	echo "手机号码输入错误！"
fi
}





function uninstall()
{
	rm -rf /etc/rc.local
	rm -rf /etc/crontab
	rm -rf /etc/network/interfaces

	cp -pdr /root/587888/rc.local.default /etc/rc.local
	cp -pdr /root/587888/crontab.default /etc/crontab
	cp -pdr /root/587888/interfaces.default /etc/network/interfaces
	rm -rf /root/587888/1/

	echo "卸载甜糖成功！重启生效！

	3秒后返回主菜单..."
	sleep 3s
	menu
}

function changeMac()
{
	if [ ! -d /root/587888/1/ ]; then
	echo "甜糖未安装，请安装后修改Mac地址、、、"
	else
	rm -rf /etc/network/interfaces
	cp -pdr /root/587888/interfaces.default /etc/network/interfaces
	mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
	sed -i "6a hwaddress $mac" /etc/network/interfaces
	echo "修改Mac成功，重启生效。
	新Mac是：$mac 请重启后重新绑定设备！

	3秒后返回主菜单..."
	sleep 3s
	menu
	fi
}

function backup()
{
	myPath="/root/587888/"

	if [ ! -d "$myPath" ]; then
	mkdir "$myPath"
	cp -pdr /etc/rc.local "$myPath"rc.local.default
	cp -pdr /etc/crontab "$myPath"crontab.default
	cp -pdr /etc/network/interfaces "$myPath"interfaces.default

	else
	echo "备份文件已存在，跳过备份步骤。"
	fi
}



function install32()
{
			read -p '
欢迎使用32位armbian甜糖CDN自动部署程序
		                                       
==============================================
    填写邀请码：888  免费获取15张加成卡！
==============================================
		
请输入邀请码 888 开始自动部署：' number
		 
		if [ $number = 888 ];then
			echo "输入正确，开始部署！"         
			backup
			rm -rf /mnts
			mkdir /mnts
			fdisk -l
			read -p "
tips：建议看容量挂载，或者填入【 LABEL="587888" 】并把磁盘名改为【 587888 】
请填入要挂载的分区，例如/dev/sda1:" fenqu
			mount $fenqu /mnts/
		
			rm -rf /usr/node
			mkdir /usr/node
			cd /usr/node/
			
			wget https://dachui.co/ttnode/ttnode32 -O ttnode
			wget https://dachui.co/ttnode/crash_monitor.sh
			wget https://dachui.co/ttnode/log.log
			chmod -R 777 *
			
			sed -i "12a mount $fenqu /mnts/\nservice sshd start\n/usr/node/ttnode -p /mnts" /etc/rc.local
			
			mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
			
			sed -i "6a hwaddress $mac" /etc/network/interfaces
			
			sed -i '14a */1 * * * *	root	/usr/node/crash_monitor.sh' /etc/crontab
			mkdir /root/587888/1/
			clear
			echo "
--------------------------------------------------------------------------------------------------
			
部署成功，请输入命令：reboot 重启！

bug反馈链接：https://www.right.com.cn/forum/forum.php?mod=viewthread&tid=4057372
			
===================================================
===================================================
      请大力填写我的甜糖发财邀请码：587888
===================================================
===================================================
			
此脚本由「折了个腾」原创发布，没有shell开发经验，现学现卖写的
			
开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！
			
--------------------------------------------------------------------------------------------------
			"
		
		else
			echo "输入有误！我的邀请码是：587888"
		fi


}

function install64()
{
			read -p '
欢迎使用64位armbian甜糖CDN自动部署程序
		                                       
==============================================
    填写邀请码：587888  免费获取15张加成卡！
==============================================
		
请输入邀请码 587888 开始自动部署：' number
		 
		if [ $number = 587888 ];then
			echo "输入正确，开始部署！"         
			backup
			
			rm -rf /mnts
			mkdir /mnts
			fdisk -l
			read -p "
tips：建议看容量挂载，或者填入【 LABEL="587888" 】并把磁盘名改为【 587888 】
请填入要挂载的分区，例如/dev/sda1:" fenqu
			mount $fenqu /mnts/
		
			rm -rf /usr/node
			mkdir /usr/node
			cd /usr/node/
			
			wget https://dachui.co/ttnode/ttnode64 -O ttnode
			wget https://dachui.co/ttnode/crash_monitor.sh
			wget https://dachui.co/ttnode/log.log
			chmod -R 777 *
			
			sed -i "12a mount $fenqu /mnts/\nservice sshd start\n/usr/node/ttnode -p /mnts" /etc/rc.local
			
			mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
			
			sed -i "6a hwaddress $mac" /etc/network/interfaces
			
			sed -i '14a */1 * * * *	root	/usr/node/crash_monitor.sh' /etc/crontab
			mkdir /root/587888/1/
			clear
			echo "
--------------------------------------------------------------------------------------------------
			
部署成功，请输入命令：reboot 重启！

bug反馈链接：https://www.right.com.cn/forum/forum.php?mod=viewthread&tid=4057372
			
===================================================
===================================================
      请大力填写我的甜糖发财邀请码：587888
===================================================
===================================================
			
此脚本由「折了个腾」原创发布，没有shell开发经验，现学现卖写的
			
开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！
			
--------------------------------------------------------------------------------------------------
			"
		
		else
			echo "输入有误！我的邀请码是：587888"
			sleep 3s
			menu
		fi

}

menu
