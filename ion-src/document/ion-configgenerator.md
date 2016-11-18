##9节点配置文件生成脚本说明
李超  
2016.9.20

脚本执行需要python环境，无需编译

准备原始数据，wiki页面上的satBasic.txt文件

使用之前根据运行环境和实验要求，调整如下参数：  
- conffilepath：生成配置文件的目录，需预先建立  
- infofilepath：数据源文件的路径  
- speed：链路速度  
- timescale：时间缩放尺度，配置文件中的时间会使用数据源中的时间除以这一个值，达到缩放实验时间的效果  
- addressprefix：相同地址的前缀  
- addressport：相同地址的后缀  