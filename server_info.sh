#!/bin/bash

echo "【系统信息】"
device_sn=`dmidecode -s system-serial-number`
echo "设备SN：${device_sn}"
#操作系统版本
system_name=`cat /etc/redhat-release`
echo "系统版本：${system_name}"
#操作系统位数
systembit=`getconf LONG_BIT`
echo "系统位数：${systembit}"
#操作系统内核版本
system_kernel=`uname -r`
echo "内核版本：${system_kernel}"


echo "【CPU信息】"
#CPU型号
cpu_model=`cat /proc/cpuinfo | grep "model name" | awk -F ':' '{print $2}' | sort | uniq`
echo "cpu型号：${cpu_model}"
#CPU架构
cpu_architecture=`uname -m`
echo "cpu架构：${cpu_architecture}"
##CPU主频
cpu_main_freq=`cat /proc/cpuinfo | grep "model name" | awk -F '@' 'NR==1 {print $2}'`
echo "cpu主频：${cpu_main_freq}"
#CPU核数
cpu_core_num=`cat /proc/cpuinfo | grep "cpu cores" | uniq | awk -F ': ' '{print $2}'`
echo "cpu核心数：${cpu_core_num}"
#物理CPU个数
cpu_phy_num=`cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l`
echo "物理cpu数量：${cpu_phy_num}"
#逻辑CPU个数
cpu_proc_num=`cat /proc/cpuinfo | grep "processor" | uniq | wc -l`
echo "逻辑cpu数量：${cpu_proc_num}"


echo "【内存信息】"
#单位转换函数
function convert_unit()
{
	result=$1
	if [ $result -ge  1048576 ]
	then
		value=1048576 #1024*1024	
		result_gb=$(awk 'BEGIN{printf"%.2f\n",'$result' / '$value'}') #将KB转换成GB，并保留2位小数
		echo $result_gb"GB"
	elif [ $result -ge  1024 ]
	then
		value=1024 	
		result_mb=$(awk 'BEGIN{printf"%.2f\n",'$result' / '$value'}') #将KB转换成MB，并保留2位小数
		echo $result_mb"MB"
	else
		echo $result"KB"
	fi
}

#单位：KB
MemTotal=$(cat /proc/meminfo | awk '/^MemTotal/{print $2}') #内存总量
MemFree=$(cat /proc/meminfo | awk '/^MemFree/{print $2}')   #空闲内存
MemUsed=$(expr $MemTotal - $MemFree)  #已用内存

echo "内存总量：$(convert_unit $MemTotal)"
echo "闲置内存：$(convert_unit $MemFree)"
echo "已使用内存：$(convert_unit $MemUsed)"
#物理内存规格
meminfo=`sudo dmidecode --type memory | grep "^[[:space:]]*Size.*MB$" | uniq -c | sed 's/ \t*Size: /\*/g' | sed 's/^ *//'`
echo "物理内存规格：${meminfo}"


echo "【磁盘信息】"
sudo yum install smartmontools -y >/dev/null 2>&1
# 查询磁盘列表
disks="$(lsblk | grep disk | awk '{  print $1  }')"

# 查询每个磁盘的容量和类型
for disk in $disks; do
    echo "磁盘编号: $disk"

    # 查询磁盘容量
    fdisk_output="$(fdisk -l "/dev/$disk" 2>/dev/null)"
    if echo "$fdisk_output" | grep -q "Disk /dev/$disk:"; then
        size="$(echo "$fdisk_output" | grep "Disk /dev/$disk:" | awk '{  print $3,$4  }' | sed 's/,//')"
    else
        size="Unknown"
    fi

    # 查询磁盘类型（SSD或HDD）
    type="$(smartctl -i "/dev/$disk" | grep "Solid State Device" &>/dev/null && echo "SSD" || echo "HDD")"

    # 输出磁盘信息
    echo "磁盘大小: ${size}"
    echo "磁盘类型: ${type}"
    echo ""
done

sudo yum install ethtool -y >/dev/null 2>&1
echo "【网卡信息】"
#!/bin/bash
interfaces=$(ip addr | awk '/^[0-9]+:/ { sub(/:/,"",$2); print $2 }' | grep -v lo)
# 循环遍历每个网卡并打印名称和最大速率
for interface in $interfaces; do
  echo "网络接口: $interface"
  if ethtool $interface > /dev/null 2>&1; then
    speed=$(sudo ethtool $interface | grep -E '10000baseT/Full|1000baseT/Full'
)
    echo "$speed"
  fi
done


