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
2. 在Macos上偶现图片无法发送至Android客户端，删除Android客户端已经接受的内容后，恢复正常；
3. 在Android上偶现无法发现其他设备
4. ~~iPad图片宽高度错误~~
5. ~~iPad WildScreen下，导航条对会话页面的action buttons有遮挡~~
6. ~~iPhone无法发送广播~~
7. ~~发送消息后列表滚到上方~~
8. iPhone选择图片到上屏有延迟，视觉上卡顿
9. Android偶现无法接收文件（可能是App退到后台太久，导致服务掉了？）
10. ~~iPhone上频繁点击取消和重新发送按钮有概率触发，modal背景无法消失的问题。~~
11. 已经在会话页面，点击消息会弹出新的会话页面
12. 文字消息，没有系统通知
13. ~~android发送，macos接收时速度慢，接收速度只有4M/S~~
14. ~~Windows上文字显示怪异~~
15. ~~重新发送时，表现：对方不需要确认，预期：对方需要确认~~
16. ~~侧边栏点击水波纹形状怪异~~
17. 大标题向上滑动时没有收起
18. iOS收不到通知
19. iOS上返回按钮比较难点击
20. ~~桌面端，快捷键发送~~
21. ~~Android导航栏白条~~
22. 通知红点

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