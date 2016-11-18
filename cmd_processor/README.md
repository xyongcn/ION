# 文件说明
1. cmd.json: 命令的存储文件，一次只能写一条命令
2. json_cmd_listener.sh: 后台循环处理程序
	* 放到不同机器上运行时需要修改内部的“THIS_ADDR”变量为该节点的ion地址
	* 1号端口指定为CMD_PORT，专门用来处理命令。
3. json_start_cmd.sh:应用示例程序，用来从cmd.json读取命令并发给本节点的命令处理程序进行处理。

# 命令格式：

1. 按照大项-小项进行安排，
2. Retrieval/Replying
	1. Retrieval:
		1. 数据类型-> 文件名
		2. 其它选项（回传端口号等）
	3. Replying
		1. 命令回复

3. Json命令示例：

```
{
	"retrieval": {
		"file": "xxx.jpg",
		"saddr": "ipn:1",
		
		"daddr": "ipn:1",
		"recv_port": "2"
		"application": "demoapp"
	}
}
```

  * file字段指定需要获取的文件名，可以指定绝对路径
  * saddr为命令发送端的ion地址
  * daddr为目的节点的ion地址
  * recv_port指定文件发回时的端口
  * application指定发送应用（目前没有使用）


```
{
  "replying": {
	"retrieval": "1",
    "port": "2"
	"application": "demoapp"
  }
}
```
 *　retrieval字段说明该回复的类型，后跟的数字指定命令执行结果，见“FILE_VALID”
 *　port指定文件发回时的端口

```
FILE_VALID
0:正确
-1：错误
```

			
# 演示方式：
1. 节点一向指定节点发送命令报文（取回某文件），目的节点收到该报文后解析报文获取命令，并按照命令将指定文件发回。命令执行完成后发送命令反馈。
