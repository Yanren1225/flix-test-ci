# flix

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 问题记录
1. 在Windows上的Clash打开Tun mode, 会影响组播数据的发送，导致局域网内其他设备无法发现此Windows设备；
2. ~~在Macos上偶现图片无法发送至Android客户端，删除Android客户端已经接受的内容后，恢复正常；~~
3. ~~在Android上偶现无法发现其他设备~~
4. ~~iPad图片宽高度错误~~
5. ~~iPad WildScreen下，导航条对会话页面的action buttons有遮挡~~
6. ~~iPhone无法发送广播~~
7. ~~发送消息后列表滚到上方~~
8. iPhone选择图片到上屏有延迟，视觉上卡顿
9. ~~Android偶现无法接收文件（可能是App退到后台太久，导致服务掉了？）~~
10. ~~iPhone上频繁点击取消和重新发送按钮有概率触发，modal背景无法消失的问题。~~
11. 已经在会话页面，点击消息会弹出新的会话页面
12. ~~文字消息，没有系统通知~~
13. ~~android发送，macos接收时速度慢，接收速度只有4M/S~~
14. ~~Windows上文字显示怪异~~
15. ~~重新发送时，表现：对方不需要确认，预期：对方需要确认~~
16. ~~侧边栏点击水波纹形状怪异~~
17. ~~大标题向上滑动时没有收起~~
18. iOS收不到通知
19. iOS上返回按钮比较难点击
20. ~~桌面端，快捷键发送~~
21. ~~Android导航栏白条~~
22. ~~通知红点~~
23. ~~pad端点击查看消息后，未读消息角标不会消失~~
24. ~~在iPad上分享日志无法使用~~
25. macos包名需要和ios包名区分
26. 只有android ios支持heif图片格式
27. ~~macos上输入框高度错误~~
28. ~~AP设备无法被发现~~
29. ~~http服务可能启动失败~~
30. ~~切换wifi http服务器需要重新启动。~~
31. ~~android开热点无法发送多播，实测Android原生代码可以发送~~
32. ~~iOS开热点无法发送和接收多播~~
33. 设备页列表滚动不到底部
34. 测试mdns
35. ~~帮助大标题折叠效果和文字太大被裁剪~~
36. ~~多选返回~~
37. ~~不可预览的文件发送完毕删除文件缓存~~
38. ~~图片预览宽高错误~~
39. iOS dsym没有正确上传到firebase
40. 偶现一次macos上刷新，搜索不到Android设备，Android端也看不到macos设备，但是Android端刷新后两端正常
41. 小米手机偶现无法被发现
42. 重新发送没有重新获取ios缓存路径

## 功能
单击消息，打开文件
- Android
  - 预览图片，会申请访问照片和视频的权限
    - 拒绝后，再次点击会没有任何提示
    - 
双击消息，打开文件所在文件夹
- open_file_manager
  - Android：无法打开下载目录
  - iOS：在Files中打开flix目录
  - 不支持其他平台
- open_dir
  - 

还有几个问题：
1. A设备离线后，B设备上仍然会显示A设备在线，需要退出app再进入才能刷新状态，这个有办法解决吗；

2. 三个主页面也是可以上下滚动页面的，所以也需要做超出回弹（大标题还有配套的收缩效果，设计图有）；

3. 首页设备列表需要加点按反馈，进入设备页的动画目前可以直接调用系统动画；

4. 首页需要加入手动下拉刷新；

5. 帮助页-关于我们，在pad上是全屏展示的，能不能做到右半屏；

6. 聊天页面，无论是点击图片，文字还是文件，都没有明显的反馈效果（尤其是图片单击预览还需要跳转到其他应用，中间有明显的延迟像是卡住了），前期可以简单地做压暗效果。

### iOS获取可用的网络接口
获取当前设备上的网络接口列表，您需要使用 NWPathMonitor 类。

以下是一个示例代码，演示了如何使用 NWPathMonitor 来获取设备上的网络接口列表：

```swift
import Network

// 创建一个路径监视器
let monitor = NWPathMonitor()

// 开始监视网络路径更改
monitor.start(queue: DispatchQueue.global()) { path in
// 检查路径状态
if path.status == .satisfied {
// 获取可用接口
let availableInterfaces = path.availableInterfaces
for interface in availableInterfaces {
// 打印接口的名称和类型
print("Interface name: \(interface.name), type: \(interface.type)")

            // 检查接口是否支持 IPv4
            if interface.type == .wifi || interface.type == .cellular {
                print("IPv4 addresses:")
                // 获取并打印接口的 IPv4 地址
                for address in interface.ipv4Addresses ?? [] {
                    print(address)
                }
            }
            
            // 检查接口是否支持 IPv6
            if interface.type == .wifi || interface.type == .cellular {
                print("IPv6 addresses:")
                // 获取并打印接口的 IPv6 地址
                for address in interface.ipv6Addresses ?? [] {
                    print(address)
                }
            }
            
            print("-----------------------------------")
        }
    }
}

// 在适当的时候停止监视器
// monitor.cancel()
```
在此示例中，我们首先创建了一个 NWPathMonitor 对象，并使用 start(queue:) 方法开始监视网络路径更改。当路径状态为满足（即网络连接可用）时，我们通过 path.availableInterfaces 获取可用的网络接口列表。然后，我们对每个接口进行迭代，并打印出接口的名称和类型。最后，我们检查每个接口是否支持 IPv4 和 IPv6，并打印出相应的地址。
