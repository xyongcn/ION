##9节点测试用例以及基本步骤
李超  
2016.9.20

根据原始数据得到的拓扑关系，在程序运行后有如下路径不需要等待时间，可以立即验证路由功能：

（1）3--2--8（持续连接）

（2）3--1--7（持续连接）

（3）1--5--9（700秒以内有效）

运行步骤如下：  
（1）每个节点运行ION：  
ionstart -I 配置文件
  
（2）打开事件通知功能：  
运行bpadmin后出现冒号提示符，输入“w 1”后，输入“q”退出，事件对应符号的含义请参见“ION-document文档”  

（3）开始进行节点间的收发实验

## 自动配置脚本说明
 1. config_files/ipv6-9nodes/auto_step1.sh：
    * 作用是将9个配置文件存放到对应的机器上，并运行ion服务。使用时将所有配置文件与脚本放到同一目录下，并按照“参数说明”修改参数，最后运行。
    * 参数说明：
       * NODE1_IP ~ NODE9_IP：代表机器ip地址，只用ipv6测试过。默认为2000::1~2000::9
       * CONFIG1 ~ CONFIG9：代表9个点的配置文件对应的名字
       * BPCONFIG：代表bpadmin的输入参数，内容为“w 1”
       * CONFIG_LOC：代表远程机器上配置文件需要存放的位置
       * USERNAME：远程机器的访问用户名
       * PASSWORD_FILE：存放远程机器访问用户名的密码（明文），确保这个文件存在。
    * 脚本内容：
       1. 按照CONFIG_LOC在远程机器上建立目录；
       1. 将配置文件传到对应机器上；
       1. 停止所有机器上的ion服务；
       1. 按照新的配置文件启动所有机器上的ion服务。
       1. 将当前窗口拆分成9等份，并在2~8机器上阻塞读取bp状态，机器与窗格对应关系为：
       
          ```
             node1---node4---node7
               |       |       |
             node2---node5---node8
               |       |       |
             node3---node6---node9  
          ```
          
 1. config_files/ipv6-9nodes/tmux.sh：
    * 该脚本作用是将一个shell拆分成9等分。
    * 运行前注意安装tmux：
      * ubuntu: sudo apt-get install tmux
      * centos: sudo yum install tux
