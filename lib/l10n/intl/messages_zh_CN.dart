// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(count) => "发送 (${count})";

  static String m1(time) => "昨天 ${time}";

  static String m2(device) => "到${device}";

  static String m3(error) => "无法选择文件夹：${error}";

  static String m4(platform) => "保存并跳转到${platform}扫一扫";

  static String m5(newVersion) => "新版本 v${newVersion}";

  static String m6(version) => "当前软件版本：v${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "android_app_send": m0,
        "android_apps_title": MessageLookupByLibrary.simpleMessage("选择本机应用"),
        "app_name": MessageLookupByLibrary.simpleMessage("Flix"),
        "base_storage_permission": MessageLookupByLibrary.simpleMessage("存储权限"),
        "base_storage_permission_des":
            MessageLookupByLibrary.simpleMessage("接收文件需要设备的存储权限"),
        "bubbles_accept": MessageLookupByLibrary.simpleMessage("点击接收"),
        "bubbles_click_to_accept":
            MessageLookupByLibrary.simpleMessage("点击确认接收"),
        "bubbles_copied": MessageLookupByLibrary.simpleMessage("已复制到剪切板"),
        "bubbles_dir": MessageLookupByLibrary.simpleMessage("文件夹内容"),
        "bubbles_dir_load_error":
            MessageLookupByLibrary.simpleMessage("加载错误了哦，一会再试试吧~"),
        "bubbles_dir_no_data": MessageLookupByLibrary.simpleMessage("无数据"),
        "bubbles_downloaded": MessageLookupByLibrary.simpleMessage("已下载"),
        "bubbles_menu_copy": MessageLookupByLibrary.simpleMessage("复制"),
        "bubbles_menu_delete": MessageLookupByLibrary.simpleMessage("删除"),
        "bubbles_menu_forward": MessageLookupByLibrary.simpleMessage("转发"),
        "bubbles_menu_free_copy": MessageLookupByLibrary.simpleMessage("自由复制"),
        "bubbles_menu_location": MessageLookupByLibrary.simpleMessage("文件位置"),
        "bubbles_menu_multiple": MessageLookupByLibrary.simpleMessage("多选"),
        "bubbles_menu_open": MessageLookupByLibrary.simpleMessage("文件打开"),
        "bubbles_menu_save_as": MessageLookupByLibrary.simpleMessage("另存为"),
        "bubbles_receive_cancel": MessageLookupByLibrary.simpleMessage("已取消"),
        "bubbles_receive_failed": MessageLookupByLibrary.simpleMessage("接收失败"),
        "bubbles_send_cancel": MessageLookupByLibrary.simpleMessage("已取消"),
        "bubbles_send_done": MessageLookupByLibrary.simpleMessage("已发送"),
        "bubbles_send_failed": MessageLookupByLibrary.simpleMessage("发送异常"),
        "bubbles_toast_re_receive":
            MessageLookupByLibrary.simpleMessage("重新接收文件"),
        "bubbles_toast_resend": MessageLookupByLibrary.simpleMessage("重新发送文件"),
        "bubbles_toast_save_success":
            MessageLookupByLibrary.simpleMessage("保存成功"),
        "bubbles_wait_for_confirm":
            MessageLookupByLibrary.simpleMessage("等待对方确认"),
        "bubbles_wait_for_receive": MessageLookupByLibrary.simpleMessage("待接收"),
        "bubbles_yesterday": m1,
        "button_cancel_send": MessageLookupByLibrary.simpleMessage("取消发送"),
        "button_resend": MessageLookupByLibrary.simpleMessage("重新发送"),
        "device_ap_connected": MessageLookupByLibrary.simpleMessage("已连接"),
        "device_delete": MessageLookupByLibrary.simpleMessage("删除"),
        "device_name_input": MessageLookupByLibrary.simpleMessage("输入本机名称"),
        "device_name_input_action": MessageLookupByLibrary.simpleMessage("完成"),
        "device_no_network": MessageLookupByLibrary.simpleMessage("网络未连接"),
        "device_offline": MessageLookupByLibrary.simpleMessage("设备已离线"),
        "device_wifi_connected":
            MessageLookupByLibrary.simpleMessage("WiFi已连接"),
        "device_wifi_not_connected":
            MessageLookupByLibrary.simpleMessage("WiFi未连接"),
        "dialog_confirm_send_button":
            MessageLookupByLibrary.simpleMessage("发送"),
        "dialog_confirm_send_subtitle": m2,
        "dialog_confirm_send_title":
            MessageLookupByLibrary.simpleMessage("发送文件"),
        "dialog_exit_button": MessageLookupByLibrary.simpleMessage("退出"),
        "dialog_exit_subtitle":
            MessageLookupByLibrary.simpleMessage("退出后，将无法被附近设备发现。"),
        "dialog_exit_title": MessageLookupByLibrary.simpleMessage("退出软件"),
        "dialog_new_version_button": MessageLookupByLibrary.simpleMessage("升级"),
        "dialog_new_version_subtitle":
            MessageLookupByLibrary.simpleMessage("建议升级到新版本，获得更好的体验哦～"),
        "dialog_new_version_title":
            MessageLookupByLibrary.simpleMessage("发现新版本"),
        "file_pick_error": m3,
        "file_pick_error_0": MessageLookupByLibrary.simpleMessage("无法选择文件夹"),
        "file_pick_error_1": MessageLookupByLibrary.simpleMessage("无权限发送此文件夹"),
        "file_pick_error_20":
            MessageLookupByLibrary.simpleMessage("点击「打开」选择文件夹"),
        "help_a_1": MessageLookupByLibrary.simpleMessage(
            "请确认发送端和接收端设备处于同一个网络状态下。如：同一个WIFI，或者使用本机热点给其他设备连接使用。"),
        "help_a_2": MessageLookupByLibrary.simpleMessage("不会。"),
        "help_a_3": MessageLookupByLibrary.simpleMessage(
            "请先按照以下步骤，尝试将flix添加到Windows网络防火墙白名单中：\n1. 搜索「允许应用通过Windows防火墙」\n2. 点击「更改设置」\n3. 点击「允许其他应用」\n4. 添加flix.exe路径（C:\\Users\\[用户名]\\AppData\\Roaming\\Flix\\Flix\\flix.exe或C:\\Program Files\\Flix\\flix.exe）\n5. 点击「添加」返回到上一页面\n6. 查看列表中的flix项，勾选「专用」和「公用」\n7. 保存\n尝试上述步骤仍旧无法接收，请联系我们。"),
        "help_a_4": MessageLookupByLibrary.simpleMessage(
            "请保证PC和其他设备在一个子网下，即它们的直接上层设备是同一个路由器。若PC通过连接的光猫，其他设备通过Wifi连接的路由器是无法正常接收文件的。"),
        "help_about": MessageLookupByLibrary.simpleMessage("关于我们"),
        "help_check_update": MessageLookupByLibrary.simpleMessage("检查更新"),
        "help_description": MessageLookupByLibrary.simpleMessage(
            "这里是 Flix，一个快速简洁的多端互传软件，希望你能喜欢 😆"),
        "help_dev_team": MessageLookupByLibrary.simpleMessage(
            "Flix 制作小组\n------\n✅设计：\nlemo\nkailun\n\n✅开发：\nMovenLecker\nEava_wu\n炎忍\nMashiro.\nGnayoah\n张建\n广靓\nChengi\nxkeyC\n小灰灰\n何言\ngggxbbb\n一季或微凉\n暮间雾\nyuzh"),
        "help_donate": MessageLookupByLibrary.simpleMessage("捐赠"),
        "help_donate_alipay": MessageLookupByLibrary.simpleMessage("支付宝"),
        "help_donate_go": m4,
        "help_donate_title": MessageLookupByLibrary.simpleMessage("捐赠"),
        "help_donate_wechat": MessageLookupByLibrary.simpleMessage("微信"),
        "help_finally": MessageLookupByLibrary.simpleMessage("最后，你也可以"),
        "help_hello": MessageLookupByLibrary.simpleMessage("👋 你好，很高兴认识你！"),
        "help_join_qq": MessageLookupByLibrary.simpleMessage("欢迎加入QQ群和我们联系~\n"),
        "help_latest_version": MessageLookupByLibrary.simpleMessage("已是最新版本"),
        "help_new_version": m5,
        "help_q_1": MessageLookupByLibrary.simpleMessage("列表里找不到设备？"),
        "help_q_2": MessageLookupByLibrary.simpleMessage("传输文件会消耗流量吗？"),
        "help_q_3": MessageLookupByLibrary.simpleMessage("Windows端无法接收/发送文件？"),
        "help_q_4": MessageLookupByLibrary.simpleMessage("PC使用网线时无法接收/发送文件？"),
        "help_q_title": MessageLookupByLibrary.simpleMessage("关于连接"),
        "help_qq_1": MessageLookupByLibrary.simpleMessage("用户QQ群1:\n"),
        "help_qq_2": MessageLookupByLibrary.simpleMessage("\n用户QQ群2:\n"),
        "help_qq_3": MessageLookupByLibrary.simpleMessage("\n用户QQ群3:\n"),
        "help_recommend": MessageLookupByLibrary.simpleMessage("推荐给朋友"),
        "help_sponsor": MessageLookupByLibrary.simpleMessage("点我进入捐赠渠道"),
        "help_thanks":
            MessageLookupByLibrary.simpleMessage("，非常感谢你来支持我们的持续开发 🙏"),
        "help_title": MessageLookupByLibrary.simpleMessage("帮助"),
        "help_version": m6,
        "homepage_select_device": MessageLookupByLibrary.simpleMessage("请选择设备"),
        "hotspot_connect_failed":
            MessageLookupByLibrary.simpleMessage("热点连接失败"),
        "hotspot_connect_failed_action":
            MessageLookupByLibrary.simpleMessage("重试"),
        "hotspot_connect_success":
            MessageLookupByLibrary.simpleMessage("热点连接成功"),
        "hotspot_connect_success_action":
            MessageLookupByLibrary.simpleMessage("返回传输"),
        "hotspot_connecting": MessageLookupByLibrary.simpleMessage("正在连接热点"),
        "hotspot_disabled": MessageLookupByLibrary.simpleMessage("热点已关闭"),
        "hotspot_disabled_action": MessageLookupByLibrary.simpleMessage("重新开启"),
        "hotspot_enable_failed": MessageLookupByLibrary.simpleMessage("开启热点失败"),
        "hotspot_enable_failed_action":
            MessageLookupByLibrary.simpleMessage("重新尝试"),
        "hotspot_enable_failed_tip":
            MessageLookupByLibrary.simpleMessage("请关闭系统热点\n重新打开WiFi后重试。"),
        "hotspot_enabling": MessageLookupByLibrary.simpleMessage("正在开启热点"),
        "hotspot_get_ap_info_failed":
            MessageLookupByLibrary.simpleMessage("未能获取热点信息"),
        "hotspot_get_ap_info_failed_action":
            MessageLookupByLibrary.simpleMessage("重试"),
        "hotspot_info_password": MessageLookupByLibrary.simpleMessage("热点密码："),
        "hotspot_info_ssid": MessageLookupByLibrary.simpleMessage("热点名称："),
        "hotspot_initializing": MessageLookupByLibrary.simpleMessage("正在初始化热点"),
        "hotspot_missing_permission":
            MessageLookupByLibrary.simpleMessage("缺少必要权限"),
        "hotspot_missing_permission_action":
            MessageLookupByLibrary.simpleMessage("授予必要权限"),
        "hotspot_my_qrcode": MessageLookupByLibrary.simpleMessage("我的二维码"),
        "hotspot_qrcode_tip":
            MessageLookupByLibrary.simpleMessage("打开 Flix 扫一扫，快速建立热点连接。"),
        "hotspot_wifi_disabled":
            MessageLookupByLibrary.simpleMessage("WiFi未开启"),
        "hotspot_wifi_disabled_action":
            MessageLookupByLibrary.simpleMessage("开启"),
        "hotspot_wifi_initializing":
            MessageLookupByLibrary.simpleMessage("正在初始化WiFi"),
        "intro_last": MessageLookupByLibrary.simpleMessage("上一步"),
        "intro_next": MessageLookupByLibrary.simpleMessage("继续"),
        "intro_permission_1":
            MessageLookupByLibrary.simpleMessage("给 Flix 必要的权限"),
        "intro_permission_2":
            MessageLookupByLibrary.simpleMessage("为了保证软件的正常使用，我们需要向你申请\n以下权限："),
        "intro_permission_3a":
            MessageLookupByLibrary.simpleMessage("打开和关闭WIFI"),
        "intro_permission_3b": MessageLookupByLibrary.simpleMessage("扫描附近的设备"),
        "intro_permission_4a": MessageLookupByLibrary.simpleMessage("存储"),
        "intro_permission_4b": MessageLookupByLibrary.simpleMessage("保存接收到的文件"),
        "intro_permission_5a": MessageLookupByLibrary.simpleMessage("通知"),
        "intro_permission_5b": MessageLookupByLibrary.simpleMessage("接收新文件通知"),
        "intro_permission_6a": MessageLookupByLibrary.simpleMessage("定位"),
        "intro_permission_6b": MessageLookupByLibrary.simpleMessage("获取网络名称"),
        "intro_permission_7a": MessageLookupByLibrary.simpleMessage("相机"),
        "intro_permission_7b": MessageLookupByLibrary.simpleMessage("扫描二维码"),
        "intro_permission_8a": MessageLookupByLibrary.simpleMessage("已阅读并同意 "),
        "intro_permission_8b": MessageLookupByLibrary.simpleMessage("用户协议"),
        "intro_permission_8c": MessageLookupByLibrary.simpleMessage(" 和 "),
        "intro_permission_8d": MessageLookupByLibrary.simpleMessage("隐私政策"),
        "intro_permission_9": MessageLookupByLibrary.simpleMessage("开始使用"),
        "intro_welcome_1":
            MessageLookupByLibrary.simpleMessage("Flix，\n像聊天一样传文件。"),
        "intro_welcome_2": MessageLookupByLibrary.simpleMessage("开始探索"),
        "intro_wifi_1": MessageLookupByLibrary.simpleMessage("连接其他设备"),
        "intro_wifi_2": MessageLookupByLibrary.simpleMessage(
            "让设备处于同一网络环境下，打开 Flix，即可\n发现设备。"),
        "menu_add_manually": MessageLookupByLibrary.simpleMessage("手动添加设备"),
        "menu_add_manually_input":
            MessageLookupByLibrary.simpleMessage("手动输入添加"),
        "menu_add_this_device": MessageLookupByLibrary.simpleMessage("添加此设备"),
        "menu_hotspot": MessageLookupByLibrary.simpleMessage("我的热点码"),
        "menu_scan": MessageLookupByLibrary.simpleMessage("扫一扫"),
        "navigation_config": MessageLookupByLibrary.simpleMessage("配置"),
        "navigation_help": MessageLookupByLibrary.simpleMessage("帮助"),
        "navigation_send": MessageLookupByLibrary.simpleMessage("互传"),
        "net_ap_close": MessageLookupByLibrary.simpleMessage("关闭"),
        "net_info": MessageLookupByLibrary.simpleMessage("网络连接信息"),
        "net_toast_ap_close": MessageLookupByLibrary.simpleMessage("热点已关闭"),
        "paircode_add_IP": MessageLookupByLibrary.simpleMessage("IP"),
        "paircode_add_device": MessageLookupByLibrary.simpleMessage("添加设备"),
        "paircode_add_failed": MessageLookupByLibrary.simpleMessage("添加失败"),
        "paircode_add_manually": MessageLookupByLibrary.simpleMessage("手动输入添加"),
        "paircode_add_port": MessageLookupByLibrary.simpleMessage("网络端口"),
        "paircode_add_success": MessageLookupByLibrary.simpleMessage("添加成功"),
        "paircode_dialog_add_device":
            MessageLookupByLibrary.simpleMessage("添加设备"),
        "paircode_dialog_add_device_action":
            MessageLookupByLibrary.simpleMessage("重试"),
        "paircode_dialog_adding_device":
            MessageLookupByLibrary.simpleMessage("正在添加设备…"),
        "paircode_local_IP": MessageLookupByLibrary.simpleMessage("本机 IP"),
        "paircode_local_port": MessageLookupByLibrary.simpleMessage("本机网络端口"),
        "paircode_scan_to_add":
            MessageLookupByLibrary.simpleMessage("Flix 扫一扫，添加本设备"),
        "paircode_toast_config_incorrect":
            MessageLookupByLibrary.simpleMessage("IP或者端口不正确"),
        "permission_confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "pick_one": MessageLookupByLibrary.simpleMessage("选择一个设备"),
        "qr_no_camera_permission":
            MessageLookupByLibrary.simpleMessage("没有相机权限"),
        "qr_scan": MessageLookupByLibrary.simpleMessage("扫一扫"),
        "qr_scan_tip":
            MessageLookupByLibrary.simpleMessage("打开 Flix 二维码，快速建立热点连接。"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "setting_accessibility": MessageLookupByLibrary.simpleMessage("辅助功能"),
        "setting_accessibility_add_devices":
            MessageLookupByLibrary.simpleMessage("手动添加设备"),
        "setting_accessibility_add_devices_des":
            MessageLookupByLibrary.simpleMessage("输入其他设备连接信息以手动添加设备"),
        "setting_accessibility_add_self":
            MessageLookupByLibrary.simpleMessage("添加此设备"),
        "setting_accessibility_add_self_des":
            MessageLookupByLibrary.simpleMessage("查看此设备连接信息以在其他设备上手动添加"),
        "setting_advances": MessageLookupByLibrary.simpleMessage("进阶功能"),
        "setting_auto_start": MessageLookupByLibrary.simpleMessage("开机时自动启动"),
        "setting_confirm_clean_cache":
            MessageLookupByLibrary.simpleMessage("清除缓存"),
        "setting_confirm_clean_cache_action":
            MessageLookupByLibrary.simpleMessage("清除"),
        "setting_confirm_clean_cache_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "由于系统限制，发送的文件会被缓存，清除缓存可能中断正在发送的文件，并导致部分已发送文件无法预览，清除缓存不影响接收的文件"),
        "setting_cross_device_clipboard":
            MessageLookupByLibrary.simpleMessage("跨设备复制粘贴"),
        "setting_cross_device_clipboard_des":
            MessageLookupByLibrary.simpleMessage("关联设备后，复制的文字可共享"),
        "setting_cross_device_clipboard_other_devices":
            MessageLookupByLibrary.simpleMessage("当前网络下的其他可用设备："),
        "setting_cross_device_clipboard_paircode":
            MessageLookupByLibrary.simpleMessage("查看本机关联码"),
        "setting_cross_device_clipboard_paired_devices":
            MessageLookupByLibrary.simpleMessage("已关联的设备"),
        "setting_cross_device_clipboard_popup_input_paircode":
            MessageLookupByLibrary.simpleMessage("输入关联码"),
        "setting_cross_device_clipboard_popup_input_paircode_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "输入对方设备上的4位数字，即可开启跨设备复制粘贴。5分钟内有效。"),
        "setting_cross_device_clipboard_popup_self_paircode":
            MessageLookupByLibrary.simpleMessage("本机关联码"),
        "setting_cross_device_clipboard_popup_self_paircode_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "对方输入你的关联码，即可开启跨设备复制粘贴。5分钟内有效。"),
        "setting_cross_device_clipboard_tip":
            MessageLookupByLibrary.simpleMessage("关联设备后，复制的文字可共享"),
        "setting_cross_device_clipboard_too_low_to_pair":
            MessageLookupByLibrary.simpleMessage("目标设备版本过低，不支持配对"),
        "setting_device_name": MessageLookupByLibrary.simpleMessage("本机名称"),
        "setting_exit": MessageLookupByLibrary.simpleMessage("退出软件"),
        "setting_more": MessageLookupByLibrary.simpleMessage("更多"),
        "setting_more_clean_cache":
            MessageLookupByLibrary.simpleMessage("清除缓存"),
        "setting_more_dark_mode": MessageLookupByLibrary.simpleMessage("深色模式"),
        "setting_more_dark_mode_off":
            MessageLookupByLibrary.simpleMessage("始终关闭"),
        "setting_more_dark_mode_on":
            MessageLookupByLibrary.simpleMessage("始终开启"),
        "setting_more_dark_mode_sync":
            MessageLookupByLibrary.simpleMessage("跟随系统"),
        "setting_more_new_discover":
            MessageLookupByLibrary.simpleMessage("启用新的设备发现方式"),
        "setting_more_new_discover_des": MessageLookupByLibrary.simpleMessage(
            "开启后可解决开热点后无法发现设备的问题。若遇到兼容问题，请尝试关闭此开关，并反馈给我们❤️"),
        "setting_receive": MessageLookupByLibrary.simpleMessage("接收设置"),
        "setting_receive_auto": MessageLookupByLibrary.simpleMessage("自动接收"),
        "setting_receive_auto_des":
            MessageLookupByLibrary.simpleMessage("收到的文件将自动保存"),
        "setting_receive_folder":
            MessageLookupByLibrary.simpleMessage("文件接收目录"),
        "setting_receive_to_album":
            MessageLookupByLibrary.simpleMessage("自动将图片视频保存到相册"),
        "setting_receive_to_album_des":
            MessageLookupByLibrary.simpleMessage("不保存到接收目录"),
        "setting_title": MessageLookupByLibrary.simpleMessage("软件设置"),
        "share_flix": MessageLookupByLibrary.simpleMessage("推荐给朋友"),
        "share_flix_action": MessageLookupByLibrary.simpleMessage("完成"),
        "share_flix_copied": MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
        "share_flix_website":
            MessageLookupByLibrary.simpleMessage("官网（点击复制）:  flix.center"),
        "toast_copied": MessageLookupByLibrary.simpleMessage("已复制到剪切板"),
        "toast_msg_empty_folder":
            MessageLookupByLibrary.simpleMessage("文件夹为空，发送取消咯"),
        "tray_menu_display": MessageLookupByLibrary.simpleMessage("显示"),
        "tray_menu_exit": MessageLookupByLibrary.simpleMessage("退出"),
        "tray_menu_hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "widget_delete_msg_history":
            MessageLookupByLibrary.simpleMessage("删除消息记录"),
        "widget_delete_msg_history_action":
            MessageLookupByLibrary.simpleMessage("删除"),
        "widget_delete_msg_history_subtitle":
            MessageLookupByLibrary.simpleMessage("如果文件正在传输，删除消息会中断传输"),
        "widget_multiple_delete": MessageLookupByLibrary.simpleMessage("删除"),
        "widget_toast_prepare_sending":
            MessageLookupByLibrary.simpleMessage("正在准备发送，请稍候"),
        "widget_verification_action": MessageLookupByLibrary.simpleMessage("完成")
      };
}
