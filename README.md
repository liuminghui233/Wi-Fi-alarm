# WIFI_alarm——基于WIFI CSI的环境异常感知

项目详情见[项目报告书](https://github.com/liuminghui233/Wi-Fi-alarm/blob/master/WiFi_alarm%E9%A1%B9%E7%9B%AE%E6%8A%A5%E5%91%8A.pdf)

## 1 实验环境

### 1.1 发射方

- 普通路由器（型号待补充）：2.4GHZ天线2根

### 1.2 接收方

- 普通台式电脑
- Ubuntu 12.04 LTS 64位
- Intel 5300 网卡
- Linux 802.11n CSI tool
  - Github：https://github.com/dhalperi/linux-80211n-csitool
  - 安装配置教程：https://blog.csdn.net/u014645508/article/details/81359409

### 1.3 分析方

- 普通笔记本电脑（TinkPad S3）
- Windows 10
- MATLAB R2018b
- 与接收方配置在同一局域网内

## 2 测试方法

### 2.1 采集模式

Step1：接收方运行

```shell
ping <ip> -i <time>
```

其中：

- `<ip>`为路由器IP地址（如192.168.1.1）
- `<time>`为发包间隔

Step2：接收方将工作目录切换到`netlink`目录下，运行以下命令：

```shell
sudo ./log_to_file test.dat
```

- 其中`test.dat`可替换为采集数据存放路径及文件名

### 2.2 实时监测模式

Step1：接收方运行

```shell
ping <ip> -i <time>
```

其中：

- `<ip>`为路由器IP地址（如192.168.1.1）
- `<time>`为发包间隔

Step2：分析方在`matlab`目录下运行`read_bf_socket.m`

Step3：接收方将工作目录切换到`netlink`目录下，运行以下命令：

```shell
gcc log_to_server.c -o log_to_server
sudo ./log_to_server
```

## Reference

- dhalperi/linux-80211n-csitool[[Github]](https://github.com/dhalperi/linux-80211n-csitool)
- dhalperi/linux-80211n-csitool-supplementary[[Github]](https://github.com/dhalperi/linux-80211n-csitool-supplementary)
- lubingxian/Realtime-processing-for-csitool[[Github]](https://github.com/lubingxian/Realtime-processing-for-csitool)
- WIFI Radar[[Website]](http://tns.thss.tsinghua.edu.cn/wifiradar/index_chi.html)
- [Paper]Kun Qian, Chenshu Wu, Zheng Yang, Yunhao Liu, Zimu Zhou, **"PADS: Passive Detection of Moving Targets with Dynamic Speed using PHY Layer Information"**, IEEE ICPADS, Hsinchu, Taiwan, December 16 - 19, 2014. (Best Paper Candidate) [[PDF]](http://tns.thss.tsinghua.edu.cn/~cswu/papers/ICPADS14_PADS_paper.pdf)
- [Paper]岳国玉. 基于WiFi信号的室内人体动作检测研究及应用[D]. 郑州大学.[[CAJ Download]](http://search.cnki.net/down/default.aspx?filename=1018107902.nh&dbcode=CMFD&year=2018&dflag=cajdown)
- Challenger1132/CSI_research[[Github]](https://github.com/Challenger1132/CSI_research)
