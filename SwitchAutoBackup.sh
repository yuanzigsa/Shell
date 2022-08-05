#!/usr/bin/expect                //此处用的是expect，如果linux没有的话，需要yum安装一下//
set date [exec date "+%Y%m%d"]   //给date变量赋值，后面需要调用//
spawn telnet 192.168.1.104       //这是expect的一个命令，表示从服务器上telnet到192.168.1.104//
expect “Username:"               //在回显的字符串中匹配Username:，如果匹配到，执行下面//
send "admin\r"                   //向交换机发送admin字符串，即输入telnet到交换机的用户名//
expect "Password:"               //在回显的字符串中匹配Password:，如果匹配到，执行下面//
send "Admin@huawei\r"            //向交换机发送Admin@huawei字符串。即输入tel到交换机的密码//

send "save\r"                    //向交换机发送save字符串，相当于在交换机上执行save命令//
send "Y\r"                       //因交换机在save时，会有个交互过程，发送字符串Y，相当于在交换机输入Y//

send "ftp 192.168.1.1\r"         //向交换机发送ftp 192.168.1.1指令，相当于在交换机上输入ftp 192.168.1.1这条命令，意思就是登陆FTP服务器//
send "admin\r"                   //发送字符串admin，即输入登陆FTP服务器的用户名//
send "Admin@huawei\r"            //发送字符串Admin@huawei。即输入登陆FTP服务器的密码//
send "put flash:/vrpcfg.zip /configbck/$date.zip\r"  //执行指令Put，交配置文件上传到FTP服务器//
interact              
~
