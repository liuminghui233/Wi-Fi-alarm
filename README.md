# WIFI_alarm——基于WIFI CSI的环境异常感知

##   [顶 置] 项 目 中 期 汇 报

### 1 目前项目进展

- 完成实验环境的搭建——购置安装Intel 5300网卡、配置路由器、系统安装

- 完成CSI数据采集工具的配置

- 利用CSI数据采集工具实现了两种工作模式

  - 采集模式（将数据保存为文件）：用于采集测试数据
  - 实时监测模式（利用socket传输数据）：可实时观察CSI数据，后期可扩充为实时异常监测观察

- 进行了初步的数据处理，并可以实时观察

  - 提取出CSI信号的信噪比、赋值、相位
  - 对CSI信号的相位进行线性变换以增强稳定性

- 进行了初步的实验观察，初步有以下几点结论：

  - 通过观察信噪比，可以直观看出，测试环境中有人与无人信号有明显区别，验证了CSI信号做为特征的可行性

    ![空环境下的信噪比](https://s2.ax1x.com/2019/12/05/Q3fwFS.png)

    ![有人经过时的信噪比](https://s2.ax1x.com/2019/12/05/Q3fsQs.png)

  - 所提取出CSI信号的赋值、相位等稳定性很差，达不到可以做为特征的条件，需进行进一步的处理

    ![幅值与相位信息](https://s2.ax1x.com/2019/12/05/Q3f6Lq.png)

- 采集了用于进一步信号处理的实验数据

  - 实验环境

    ![](https://s2.ax1x.com/2019/12/05/Q3fyyn.png)

  - 数据情况

    | 文件名            | 环境状态                    | 采集时间 | 采集频率 | 采集数据组数 |
    | ----------------- | --------------------------- | -------- | -------- | ------------ |
    | static0X.dat      | 空环境                      | 30s左右  | 2次/s    | 60组左右     |
    | place10X.dat      | 人静立于1位置               | 30s左右  | 2次/s    | 60组左右     |
    | place20X.dat      | 人静立于2位置               | 30s左右  | 2次/s    | 60组左右     |
    | place30X.dat      | 人静立于3位置               | 30s左右  | 2次/s    | 60组左右     |
    | place40X.dat      | 人静立于4位置               | 30s左右  | 2次/s    | 60组左右     |
    | place50X.dat      | 人静立于5位置               | 30s左右  | 2次/s    | 60组左右     |
    | go_and_stay0X.dat | 人走入实验环境并在1位置停止 | 30s左右  | 2次/s    | 60组左右     |
    | go_go0X.dat       | 人穿过实验环境              | 30s左右  | 2次/s    | 60组左右     |

### 2 下一步项目计划

- 完成对CSI信号幅值的处理，增强其稳定性，使其可作为特征

  ![CSI数据预处理方案](https://s2.ax1x.com/2019/12/05/Q3f0Jg.png)

- 从处理后CSI信号幅值中提取特征进行环境异常判别，初步有以下想法：
  - 指数加权平均算法
  - 支持向量机SVM
  - 人工神经网络
- （如果还有时间）用户方面：
  - 通过Web/APP等远程监测环境
  - 出现环境异常时发出通知（如短信）

### 3 最终目标

- 实现对最简单的环境异常（有人进入监测环境）的实时监测







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
sudo ./log_to_server <ip> <port>
```

其中：

- `<ip>`为分析方IP地址（如192.168.1.102）
- `<port>`为分析方监听端口（默认为8090）



## Reference

- dhalperi/linux-80211n-csitool[[Github]](https://github.com/dhalperi/linux-80211n-csitool)
- dhalperi/linux-80211n-csitool-supplementary[[Github]](https://github.com/dhalperi/linux-80211n-csitool-supplementary)
- lubingxian/Realtime-processing-for-csitool[[Github]](https://github.com/lubingxian/Realtime-processing-for-csitool)
- WIFI Radar[[Website]](http://tns.thss.tsinghua.edu.cn/wifiradar/index_chi.html)
- [Paper]Kun Qian, Chenshu Wu, Zheng Yang, Yunhao Liu, Zimu Zhou, **"PADS: Passive Detection of Moving Targets with Dynamic Speed using PHY Layer Information"**, IEEE ICPADS, Hsinchu, Taiwan, December 16 - 19, 2014. (Best Paper Candidate) [[PDF]](http://tns.thss.tsinghua.edu.cn/~cswu/papers/ICPADS14_PADS_paper.pdf)
- [Paper]岳国玉. 基于WiFi信号的室内人体动作检测研究及应用[D]. 郑州大学.[[CAJ Download]](http://search.cnki.net/down/default.aspx?filename=1018107902.nh&dbcode=CMFD&year=2018&dflag=cajdown)
- Challenger1132/CSI_research[[Github]](https://github.com/Challenger1132/CSI_research)