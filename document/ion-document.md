##ION说明文档
李超  
2016.9.1
### 一、配置文件基本结构 ###
以下粗体为配置文件的内容，后面的文字为说明  
**## begin ionadmin**  
ionadmin配置部分开始
  
**1 1 ''**  
第1个参数：1，初始化命令  
第2个参数：1，指定此节点的编号为1  
第3个参数：""，配置文件名为空，即使用默认SDR配置  

**s**  
节点启动命令

**a contact +1 +3600 1 2 100000**  
第1个参数：a，添加命令  
第2个参数：contact，连接  
第3个参数：+1，开始时间  
第4个参数：+3600，结束时间  
第5个参数：1，源节点  
第6个参数：1，目标节点  
第7个参数：100000，最大传输速度  
※注意：连接具有单向性，如果节点之间存在双向连接需要分别进行配置  


**a range +1 +3600 1 2 1**  
第1个参数：添加命令  
第2个参数：range，范围  
第3个参数：+1，开始时间  
第4个参数：+3600，结束时间  
第5个参数：1，源节点  
第6个参数：2，目标节点  
第7个参数：1，以“光秒“为单位的节点间距离  
注意：范围具有对称性，两个节点之间只需要一条记录  

**## end ionadmin**  
ionadmin配置部分结束  

**## begin bpadmin**  
bpadmin配置部分开始  

**1**  
初始化命令  

**a scheme ipn 'ipnfw' 'ipnadminep'**  
第1个参数：a，添加命令  
第2个参数：scheme，命名方案  
第3个参数：ipn，命名方式为ipn  
第4个参数：'ipnfw'，与ipn这种命名方案对应的转发处理程序为ipnfw  
第5个参数：'ipnadminep'，与ipn这种命名方案对应的管理程序为ipnadminep  

**a endpoint ipn:1.1 q**  
第1个参数：a，添加命令  
第2个参数：endpoint，节点  
第3个参数：ipn:1.1，节点名称，采用“节点编号：服务编号”的形式  
第4个参数：q，节点在收到数据包后的行为，“q”表示将数据包插入队列等待，直至应用接受，“x”表示如果当前没有应用监听就丢弃  

**a protocol tcp 1400 100**  
第1个参数：a，添加命令  
第2个参数：protocol，传输协议  
第3个参数：tcp，使用tcp协议  
第4个参数：1400，每一帧中有1400字节用于数据负载  
第5个参数：100，每一帧中有100字节用于开销  

**a induct tcp 192.168.1.187:4556 tcpcli**  
第1个参数：a，添加命令  
第2个参数：induct，表示从外部节点到本节点的连接方向  
第3个参数：tcp，使用tcp协议  
第4个参数：192.168.1.187:4556，本地节点地址和端口  
第5个参数：tcpcli，连接使用“tcpcli”命令建立  


**a outduct tcp 192.168.1.184:4556 tcpclo**
第1个参数：a，添加命令  
第2个参数：outduct，表示从本节点到外部节点的连接方向  
第3个参数：tcp，使用tcp协议  
第4个参数：192.168.1.184:4556，远端节点地址和端口  
第5个参数：tcpclo，连接使用“tcpclo”命令建立  

**s**  
启动命令

**## end bpadmin**  
bpadmin配置部分结束

**## begin ipnadmin**  
ipnadmin配置部分开始  

**a plan 2 tcp/192.168.1.184:4556**
第1个参数：a，添加命令  
第2个参数：plan，路由信息  
第3个参数：2，远端节点的编号  
第四个参数：tcp/192.168.1.184:4556，连接建立的协议和地址  

**## end ipnadmin**  
ipnadmin配置部分结束  



如果使用的是ltp协议，还需要以下配置：

**## begin ltpadmin**  
ltpadmin配置部分开始

**1 32**  
第1个参数：1，初始化命令  
第2个参数：32，LTP传输会话的最大数目

**a span 1 32 32 1400 10000 1 'udplso localhost:1113'**  
第1个参数：a，添加命令，span表示ltp接收  
第2个参数：1，远端节点的编号  
第3个参数：32，LTP传输会话的最大数目  
第4个参数：32，LTP接收会话的最大数目  
第5个参数：1400，每个分片的大小  
第6个参数：10000，LTP聚合小Bundle为大Bundle进行统一传输的大小  
第7个参数：1，聚合时间限制，在聚合开始后后1秒钟进行传输，无论是否到达门限值  
第8个参数：'udplso localhost:1113'，远端节点连接协议和地址信息  

**s 'udplsi localhost:1113'**  
第1个参数：s，启动本地ltp服务  
第2个参数：'udplsi localhost:1113'，远端节点连接协议和地址信息  

**## end ltpadmin**  
ltpadmin配置部分结束


### 二、Bundle信息查看

（1）程序运行过程中，可以通过**bpstats**命令结合查看ion.log文件获取数据收发的统计信息。

信息为如下格式：  
{yyyy/mm/dd hh:mm:ss}[x] xxx from tttttttt to TTTTTTTT:(0) aaaa bbbbbbbbbb (1) cccc
dddddddddd (2) eeee ffffffffff (+) gggg hhhhhhhhhh  
xxx：信息类型，共分为如下几种：  
- src：本地节点生成bundle  
- fwd：本地节点转发bundle  
- xmt：bundle交付汇聚层  
- rcv：本地节点接收bundle  
- dlv：bundle投递至应用  
- ctr：本地节点接收到了保管拒绝的消息  
- rfw：汇聚层传输失败  
- exp：bundle超时  

tttttttt：统计开始时间（格式：yyyy/mm/dd−hh:mm:ss）  
TTTTTTTT：统计结束时间（格式：yyyy/mm/dd−hh:mm:ss）  
0：大型bundle  
1：普通bundle  
2：加急bundle  
每部分中前面的值是bundle个数，后面的值是总大小



（2）当Bundle处于尚未成功转发的状态时，可以使用bplist命令查看bundle的信息和具体内容


（3）管理程序bpadmin提供了一个显示当前节点bundle处理事件的工具。输入命令bpadmin后出现“：”提示符，输入“w 1”打开这个功能。在运行过程中如果有事件发生，屏幕上会出现对应的字母代号，具体如下：

- a：新Bundle进入转发队列
- b：Bundle进入传输队列
- c：Bundle从传输队列中取出
- m：接收到保管传递的信号
- w：Bundle的保管传递请求被接受
- x：Bundle的保管传递请求被拒绝
- y：到达的Bundle被接受
- z：Bundle等待投递至应用
- ~：Bundle被丢弃
- ！：Bundle超时
- &：接收到拒绝保管传递的信号
- #：Bundle由于错误需要重新转发
- j：Bundle进入推迟队列
- k：Bundle离开推迟队列等待重新转发
