// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flix`
  String get app_name {
    return Intl.message(
      'Flix',
      name: 'app_name',
      desc: '软件名称',
      args: [],
    );
  }

  /// `显示`
  String get tray_menu_display {
    return Intl.message(
      '显示',
      name: 'tray_menu_display',
      desc: '',
      args: [],
    );
  }

  /// `隐藏`
  String get tray_menu_hide {
    return Intl.message(
      '隐藏',
      name: 'tray_menu_hide',
      desc: '',
      args: [],
    );
  }

  /// `退出`
  String get tray_menu_exit {
    return Intl.message(
      '退出',
      name: 'tray_menu_exit',
      desc: '',
      args: [],
    );
  }

  /// `互传`
  String get navigation_send {
    return Intl.message(
      '互传',
      name: 'navigation_send',
      desc: '',
      args: [],
    );
  }

  /// `配置`
  String get navigation_config {
    return Intl.message(
      '配置',
      name: 'navigation_config',
      desc: '',
      args: [],
    );
  }

  /// `帮助`
  String get navigation_help {
    return Intl.message(
      '帮助',
      name: 'navigation_help',
      desc: '',
      args: [],
    );
  }

  /// `请选择设备`
  String get homepage_select_device {
    return Intl.message(
      '请选择设备',
      name: 'homepage_select_device',
      desc: '',
      args: [],
    );
  }

  /// `退出软件`
  String get dialog_exit_title {
    return Intl.message(
      '退出软件',
      name: 'dialog_exit_title',
      desc: '',
      args: [],
    );
  }

  /// `退出后，将无法被附近设备发现。`
  String get dialog_exit_subtitle {
    return Intl.message(
      '退出后，将无法被附近设备发现。',
      name: 'dialog_exit_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `退出`
  String get dialog_exit_button {
    return Intl.message(
      '退出',
      name: 'dialog_exit_button',
      desc: '',
      args: [],
    );
  }

  /// `发现新版本`
  String get dialog_new_version_title {
    return Intl.message(
      '发现新版本',
      name: 'dialog_new_version_title',
      desc: '',
      args: [],
    );
  }

  /// `建议升级到新版本，获得更好的体验哦～`
  String get dialog_new_version_subtitle {
    return Intl.message(
      '建议升级到新版本，获得更好的体验哦～',
      name: 'dialog_new_version_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `升级`
  String get dialog_new_version_button {
    return Intl.message(
      '升级',
      name: 'dialog_new_version_button',
      desc: '',
      args: [],
    );
  }

  /// `发送文件`
  String get dialog_confirm_send_title {
    return Intl.message(
      '发送文件',
      name: 'dialog_confirm_send_title',
      desc: '',
      args: [],
    );
  }

  /// `到{device}`
  String dialog_confirm_send_subtitle(String device) {
    return Intl.message(
      '到$device',
      name: 'dialog_confirm_send_subtitle',
      desc: '',
      args: [device],
    );
  }

  /// `发送`
  String get dialog_confirm_send_button {
    return Intl.message(
      '发送',
      name: 'dialog_confirm_send_button',
      desc: '',
      args: [],
    );
  }

  /// `文件夹为空，发送取消咯`
  String get toast_msg_empty_folder {
    return Intl.message(
      '文件夹为空，发送取消咯',
      name: 'toast_msg_empty_folder',
      desc: '',
      args: [],
    );
  }

  /// `软件帮助`
  String get help_title {
    return Intl.message(
      '软件帮助',
      name: 'help_title',
      desc: '',
      args: [],
    );
  }

  /// `关于我们`
  String get help_about {
    return Intl.message(
      '关于我们',
      name: 'help_about',
      desc: '',
      args: [],
    );
  }

  /// `新版本 v{newVersion}`
  String help_new_version(String newVersion) {
    return Intl.message(
      '新版本 v$newVersion',
      name: 'help_new_version',
      desc: '',
      args: [newVersion],
    );
  }

  /// `已是最新版本`
  String get help_latest_version {
    return Intl.message(
      '已是最新版本',
      name: 'help_latest_version',
      desc: '',
      args: [],
    );
  }

  /// `检查更新`
  String get help_check_update {
    return Intl.message(
      '检查更新',
      name: 'help_check_update',
      desc: '',
      args: [],
    );
  }

  /// `❤️ 捐赠支持我们`
  String get help_donate {
    return Intl.message(
      '❤️ 捐赠支持我们',
      name: 'help_donate',
      desc: '',
      args: [],
    );
  }

  /// `👍 推荐给朋友`
  String get help_recommend {
    return Intl.message(
      '👍 推荐给朋友',
      name: 'help_recommend',
      desc: '',
      args: [],
    );
  }

  /// `👋 你好，很高兴认识你！`
  String get help_hello {
    return Intl.message(
      '👋 你好，很高兴认识你！',
      name: 'help_hello',
      desc: '',
      args: [],
    );
  }

  /// `关于连接`
  String get help_q_title {
    return Intl.message(
      '关于连接',
      name: 'help_q_title',
      desc: '',
      args: [],
    );
  }

  /// `列表里找不到设备？`
  String get help_q_1 {
    return Intl.message(
      '列表里找不到设备？',
      name: 'help_q_1',
      desc: '',
      args: [],
    );
  }

  /// `请确认发送端和接收端设备处于同一个网络状态下。如：同一个WIFI，或者使用本机热点给其他设备连接使用。`
  String get help_a_1 {
    return Intl.message(
      '请确认发送端和接收端设备处于同一个网络状态下。如：同一个WIFI，或者使用本机热点给其他设备连接使用。',
      name: 'help_a_1',
      desc: '',
      args: [],
    );
  }

  /// `传输文件会消耗流量吗？`
  String get help_q_2 {
    return Intl.message(
      '传输文件会消耗流量吗？',
      name: 'help_q_2',
      desc: '',
      args: [],
    );
  }

  /// `不会。`
  String get help_a_2 {
    return Intl.message(
      '不会。',
      name: 'help_a_2',
      desc: '',
      args: [],
    );
  }

  /// `Windows端无法接收/发送文件？`
  String get help_q_3 {
    return Intl.message(
      'Windows端无法接收/发送文件？',
      name: 'help_q_3',
      desc: '',
      args: [],
    );
  }

  /// `请先按照以下步骤，尝试将flix添加到Windows网络防火墙白名单中：\n1. 搜索「允许应用通过Windows防火墙」\n2. 点击「更改设置」\n3. 点击「允许其他应用」\n4. 添加flix.exe路径（C:\Users\[用户名]\AppData\Roaming\Flix\Flix\flix.exe或C:\Program Files\Flix\flix.exe）\n5. 点击「添加」返回到上一页面\n6. 查看列表中的flix项，勾选「专用」和「公用」\n7. 保存\n尝试上述步骤仍旧无法接收，请联系我们。`
  String get help_a_3 {
    return Intl.message(
      '请先按照以下步骤，尝试将flix添加到Windows网络防火墙白名单中：\n1. 搜索「允许应用通过Windows防火墙」\n2. 点击「更改设置」\n3. 点击「允许其他应用」\n4. 添加flix.exe路径（C:\\Users\\[用户名]\\AppData\\Roaming\\Flix\\Flix\\flix.exe或C:\\Program Files\\Flix\\flix.exe）\n5. 点击「添加」返回到上一页面\n6. 查看列表中的flix项，勾选「专用」和「公用」\n7. 保存\n尝试上述步骤仍旧无法接收，请联系我们。',
      name: 'help_a_3',
      desc: '',
      args: [],
    );
  }

  /// `PC使用网线时无法接收/发送文件？`
  String get help_q_4 {
    return Intl.message(
      'PC使用网线时无法接收/发送文件？',
      name: 'help_q_4',
      desc: '',
      args: [],
    );
  }

  /// `请保证PC和其他设备在一个子网下，即它们的直接上层设备是同一个路由器。若PC通过连接的光猫，其他设备通过Wifi连接的路由器是无法正常接收文件的。`
  String get help_a_4 {
    return Intl.message(
      '请保证PC和其他设备在一个子网下，即它们的直接上层设备是同一个路由器。若PC通过连接的光猫，其他设备通过Wifi连接的路由器是无法正常接收文件的。',
      name: 'help_a_4',
      desc: '',
      args: [],
    );
  }

  /// `这里是 Flix，一个快速简洁的多端互传软件，希望你能喜欢 😆`
  String get help_description {
    return Intl.message(
      '这里是 Flix，一个快速简洁的多端互传软件，希望你能喜欢 😆',
      name: 'help_description',
      desc: '',
      args: [],
    );
  }

  /// `Flix 制作小组\n------\n✅设计：\nlemo\nkailun\n\n✅开发：\nMovenLecker\nEava_wu\n炎忍\nMashiro.\nGnayoah\n张建\n广靓\nChengi\nxkeyC\n小灰灰\n何言\ngggxbbb\n一季或微凉\n暮间雾\nyuzh`
  String get help_dev_team {
    return Intl.message(
      'Flix 制作小组\n------\n✅设计：\nlemo\nkailun\n\n✅开发：\nMovenLecker\nEava_wu\n炎忍\nMashiro.\nGnayoah\n张建\n广靓\nChengi\nxkeyC\n小灰灰\n何言\ngggxbbb\n一季或微凉\n暮间雾\nyuzh',
      name: 'help_dev_team',
      desc: '',
      args: [],
    );
  }

  /// `欢迎加入QQ群和我们联系~\n`
  String get help_join_qq {
    return Intl.message(
      '欢迎加入QQ群和我们联系~\n',
      name: 'help_join_qq',
      desc: '',
      args: [],
    );
  }

  /// `用户QQ群1:\n`
  String get help_qq_1 {
    return Intl.message(
      '用户QQ群1:\n',
      name: 'help_qq_1',
      desc: '',
      args: [],
    );
  }

  /// `\n用户QQ群2:\n`
  String get help_qq_2 {
    return Intl.message(
      '\n用户QQ群2:\n',
      name: 'help_qq_2',
      desc: '',
      args: [],
    );
  }

  /// `\n用户QQ群3:\n`
  String get help_qq_3 {
    return Intl.message(
      '\n用户QQ群3:\n',
      name: 'help_qq_3',
      desc: '',
      args: [],
    );
  }

  /// `最后，你也可以`
  String get help_finally {
    return Intl.message(
      '最后，你也可以',
      name: 'help_finally',
      desc: '',
      args: [],
    );
  }

  /// `点我进入捐赠渠道`
  String get help_sponsor {
    return Intl.message(
      '点我进入捐赠渠道',
      name: 'help_sponsor',
      desc: '',
      args: [],
    );
  }

  /// `，非常感谢你来支持我们的持续开发 🙏`
  String get help_thanks {
    return Intl.message(
      '，非常感谢你来支持我们的持续开发 🙏',
      name: 'help_thanks',
      desc: '',
      args: [],
    );
  }

  /// `当前软件版本：v{version}`
  String help_version(String version) {
    return Intl.message(
      '当前软件版本：v$version',
      name: 'help_version',
      desc: '',
      args: [version],
    );
  }

  /// `捐赠`
  String get help_donate_title {
    return Intl.message(
      '捐赠',
      name: 'help_donate_title',
      desc: '',
      args: [],
    );
  }

  /// `微信`
  String get help_donate_wechat {
    return Intl.message(
      '微信',
      name: 'help_donate_wechat',
      desc: '',
      args: [],
    );
  }

  /// `支付宝`
  String get help_donate_alipay {
    return Intl.message(
      '支付宝',
      name: 'help_donate_alipay',
      desc: '',
      args: [],
    );
  }

  /// `保存并跳转到{platform}扫一扫`
  String help_donate_go(Object platform) {
    return Intl.message(
      '保存并跳转到$platform扫一扫',
      name: 'help_donate_go',
      desc: '',
      args: [platform],
    );
  }

  /// `正在初始化WiFi`
  String get hotspot_wifi_initializing {
    return Intl.message(
      '正在初始化WiFi',
      name: 'hotspot_wifi_initializing',
      desc: '',
      args: [],
    );
  }

  /// `正在连接热点`
  String get hotspot_connecting {
    return Intl.message(
      '正在连接热点',
      name: 'hotspot_connecting',
      desc: '',
      args: [],
    );
  }

  /// `WiFi未开启`
  String get hotspot_wifi_disabled {
    return Intl.message(
      'WiFi未开启',
      name: 'hotspot_wifi_disabled',
      desc: '',
      args: [],
    );
  }

  /// `开启`
  String get hotspot_wifi_disabled_action {
    return Intl.message(
      '开启',
      name: 'hotspot_wifi_disabled_action',
      desc: '',
      args: [],
    );
  }

  /// `热点连接成功`
  String get hotspot_connect_success {
    return Intl.message(
      '热点连接成功',
      name: 'hotspot_connect_success',
      desc: '',
      args: [],
    );
  }

  /// `返回传输`
  String get hotspot_connect_success_action {
    return Intl.message(
      '返回传输',
      name: 'hotspot_connect_success_action',
      desc: '',
      args: [],
    );
  }

  /// `热点连接失败`
  String get hotspot_connect_failed {
    return Intl.message(
      '热点连接失败',
      name: 'hotspot_connect_failed',
      desc: '',
      args: [],
    );
  }

  /// `重试`
  String get hotspot_connect_failed_action {
    return Intl.message(
      '重试',
      name: 'hotspot_connect_failed_action',
      desc: '',
      args: [],
    );
  }

  /// `正在初始化热点`
  String get hotspot_initializing {
    return Intl.message(
      '正在初始化热点',
      name: 'hotspot_initializing',
      desc: '',
      args: [],
    );
  }

  /// `正在开启热点`
  String get hotspot_enabling {
    return Intl.message(
      '正在开启热点',
      name: 'hotspot_enabling',
      desc: '',
      args: [],
    );
  }

  /// `开启热点失败`
  String get hotspot_enable_failed {
    return Intl.message(
      '开启热点失败',
      name: 'hotspot_enable_failed',
      desc: '',
      args: [],
    );
  }

  /// `重新尝试`
  String get hotspot_enable_failed_action {
    return Intl.message(
      '重新尝试',
      name: 'hotspot_enable_failed_action',
      desc: '',
      args: [],
    );
  }

  /// `请关闭系统热点\n重新打开WiFi后重试。`
  String get hotspot_enable_failed_tip {
    return Intl.message(
      '请关闭系统热点\n重新打开WiFi后重试。',
      name: 'hotspot_enable_failed_tip',
      desc: '',
      args: [],
    );
  }

  /// `缺少必要权限`
  String get hotspot_missing_permission {
    return Intl.message(
      '缺少必要权限',
      name: 'hotspot_missing_permission',
      desc: '',
      args: [],
    );
  }

  /// `授予必要权限`
  String get hotspot_missing_permission_action {
    return Intl.message(
      '授予必要权限',
      name: 'hotspot_missing_permission_action',
      desc: '',
      args: [],
    );
  }

  /// `未能获取热点信息`
  String get hotspot_get_ap_info_failed {
    return Intl.message(
      '未能获取热点信息',
      name: 'hotspot_get_ap_info_failed',
      desc: '',
      args: [],
    );
  }

  /// `重试`
  String get hotspot_get_ap_info_failed_action {
    return Intl.message(
      '重试',
      name: 'hotspot_get_ap_info_failed_action',
      desc: '',
      args: [],
    );
  }

  /// `热点已关闭`
  String get hotspot_disabled {
    return Intl.message(
      '热点已关闭',
      name: 'hotspot_disabled',
      desc: '',
      args: [],
    );
  }

  /// `重新开启`
  String get hotspot_disabled_action {
    return Intl.message(
      '重新开启',
      name: 'hotspot_disabled_action',
      desc: '',
      args: [],
    );
  }

  /// `我的二维码`
  String get hotspot_my_qrcode {
    return Intl.message(
      '我的二维码',
      name: 'hotspot_my_qrcode',
      desc: '',
      args: [],
    );
  }

  /// `打开 Flix 扫一扫，快速建立热点连接。`
  String get hotspot_qrcode_tip {
    return Intl.message(
      '打开 Flix 扫一扫，快速建立热点连接。',
      name: 'hotspot_qrcode_tip',
      desc: '',
      args: [],
    );
  }

  /// `热点名称：`
  String get hotspot_info_ssid {
    return Intl.message(
      '热点名称：',
      name: 'hotspot_info_ssid',
      desc: '',
      args: [],
    );
  }

  /// `热点密码：`
  String get hotspot_info_password {
    return Intl.message(
      '热点密码：',
      name: 'hotspot_info_password',
      desc: '',
      args: [],
    );
  }

  /// `已复制到剪切板`
  String get toast_copied {
    return Intl.message(
      '已复制到剪切板',
      name: 'toast_copied',
      desc: '',
      args: [],
    );
  }

  /// `手动输入添加`
  String get paircode_add_manually {
    return Intl.message(
      '手动输入添加',
      name: 'paircode_add_manually',
      desc: '',
      args: [],
    );
  }

  /// `本机 IP`
  String get paircode_local_IP {
    return Intl.message(
      '本机 IP',
      name: 'paircode_local_IP',
      desc: '',
      args: [],
    );
  }

  /// `IP`
  String get paircode_add_IP {
    return Intl.message(
      'IP',
      name: 'paircode_add_IP',
      desc: '',
      args: [],
    );
  }

  /// `本机网络端口`
  String get paircode_local_port {
    return Intl.message(
      '本机网络端口',
      name: 'paircode_local_port',
      desc: '',
      args: [],
    );
  }

  /// `网络端口`
  String get paircode_add_port {
    return Intl.message(
      '网络端口',
      name: 'paircode_add_port',
      desc: '',
      args: [],
    );
  }

  /// `添加设备`
  String get paircode_add_device {
    return Intl.message(
      '添加设备',
      name: 'paircode_add_device',
      desc: '',
      args: [],
    );
  }

  /// `Flix 扫一扫，添加本设备`
  String get paircode_scan_to_add {
    return Intl.message(
      'Flix 扫一扫，添加本设备',
      name: 'paircode_scan_to_add',
      desc: '',
      args: [],
    );
  }

  /// `添加设备`
  String get paircode_dialog_add_device {
    return Intl.message(
      '添加设备',
      name: 'paircode_dialog_add_device',
      desc: '',
      args: [],
    );
  }

  /// `正在添加设备…`
  String get paircode_dialog_adding_device {
    return Intl.message(
      '正在添加设备…',
      name: 'paircode_dialog_adding_device',
      desc: '',
      args: [],
    );
  }

  /// `重试`
  String get paircode_dialog_add_device_action {
    return Intl.message(
      '重试',
      name: 'paircode_dialog_add_device_action',
      desc: '',
      args: [],
    );
  }

  /// `IP或者端口不正确`
  String get paircode_toast_config_incorrect {
    return Intl.message(
      'IP或者端口不正确',
      name: 'paircode_toast_config_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `添加成功`
  String get paircode_add_success {
    return Intl.message(
      '添加成功',
      name: 'paircode_add_success',
      desc: '',
      args: [],
    );
  }

  /// `添加失败`
  String get paircode_add_failed {
    return Intl.message(
      '添加失败',
      name: 'paircode_add_failed',
      desc: '',
      args: [],
    );
  }

  /// `清除缓存`
  String get setting_confirm_clean_cache {
    return Intl.message(
      '清除缓存',
      name: 'setting_confirm_clean_cache',
      desc: '',
      args: [],
    );
  }

  /// `由于系统限制，发送的文件会被缓存，清除缓存可能中断正在发送的文件，并导致部分已发送文件无法预览，清除缓存不影响接收的文件`
  String get setting_confirm_clean_cache_subtitle {
    return Intl.message(
      '由于系统限制，发送的文件会被缓存，清除缓存可能中断正在发送的文件，并导致部分已发送文件无法预览，清除缓存不影响接收的文件',
      name: 'setting_confirm_clean_cache_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `清除`
  String get setting_confirm_clean_cache_action {
    return Intl.message(
      '清除',
      name: 'setting_confirm_clean_cache_action',
      desc: '',
      args: [],
    );
  }

  /// `跨设备复制粘贴`
  String get setting_cross_device_clipboard {
    return Intl.message(
      '跨设备复制粘贴',
      name: 'setting_cross_device_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `关联设备后，复制的文字可共享`
  String get setting_cross_device_clipboard_tip {
    return Intl.message(
      '关联设备后，复制的文字可共享',
      name: 'setting_cross_device_clipboard_tip',
      desc: '',
      args: [],
    );
  }

  /// `查看本机关联码`
  String get setting_cross_device_clipboard_paircode {
    return Intl.message(
      '查看本机关联码',
      name: 'setting_cross_device_clipboard_paircode',
      desc: '',
      args: [],
    );
  }

  /// `已关联的设备`
  String get setting_cross_device_clipboard_paired_devices {
    return Intl.message(
      '已关联的设备',
      name: 'setting_cross_device_clipboard_paired_devices',
      desc: '',
      args: [],
    );
  }

  /// `当前网络下的其他可用设备：`
  String get setting_cross_device_clipboard_other_devices {
    return Intl.message(
      '当前网络下的其他可用设备：',
      name: 'setting_cross_device_clipboard_other_devices',
      desc: '',
      args: [],
    );
  }

  /// `目标设备版本过低，不支持配对`
  String get setting_cross_device_clipboard_too_low_to_pair {
    return Intl.message(
      '目标设备版本过低，不支持配对',
      name: 'setting_cross_device_clipboard_too_low_to_pair',
      desc: '',
      args: [],
    );
  }

  /// `输入关联码`
  String get setting_cross_device_clipboard_popup_input_paircode {
    return Intl.message(
      '输入关联码',
      name: 'setting_cross_device_clipboard_popup_input_paircode',
      desc: '',
      args: [],
    );
  }

  /// `输入对方设备上的4位数字，即可开启跨设备复制粘贴。5分钟内有效。`
  String get setting_cross_device_clipboard_popup_input_paircode_subtitle {
    return Intl.message(
      '输入对方设备上的4位数字，即可开启跨设备复制粘贴。5分钟内有效。',
      name: 'setting_cross_device_clipboard_popup_input_paircode_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `本机关联码`
  String get setting_cross_device_clipboard_popup_self_paircode {
    return Intl.message(
      '本机关联码',
      name: 'setting_cross_device_clipboard_popup_self_paircode',
      desc: '',
      args: [],
    );
  }

  /// `对方输入你的关联码，即可开启跨设备复制粘贴。5分钟内有效。`
  String get setting_cross_device_clipboard_popup_self_paircode_subtitle {
    return Intl.message(
      '对方输入你的关联码，即可开启跨设备复制粘贴。5分钟内有效。',
      name: 'setting_cross_device_clipboard_popup_self_paircode_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `软件设置`
  String get setting_title {
    return Intl.message(
      '软件设置',
      name: 'setting_title',
      desc: '',
      args: [],
    );
  }

  /// `本机名称`
  String get setting_device_name {
    return Intl.message(
      '本机名称',
      name: 'setting_device_name',
      desc: '',
      args: [],
    );
  }

  /// `开机时自动启动`
  String get setting_auto_start {
    return Intl.message(
      '开机时自动启动',
      name: 'setting_auto_start',
      desc: '',
      args: [],
    );
  }

  /// `辅助功能`
  String get setting_accessibility {
    return Intl.message(
      '辅助功能',
      name: 'setting_accessibility',
      desc: '',
      args: [],
    );
  }

  /// `添加此设备`
  String get setting_accessibility_add_self {
    return Intl.message(
      '添加此设备',
      name: 'setting_accessibility_add_self',
      desc: '',
      args: [],
    );
  }

  /// `查看此设备连接信息以在其他设备上手动添加`
  String get setting_accessibility_add_self_des {
    return Intl.message(
      '查看此设备连接信息以在其他设备上手动添加',
      name: 'setting_accessibility_add_self_des',
      desc: '',
      args: [],
    );
  }

  /// `手动添加设备`
  String get setting_accessibility_add_devices {
    return Intl.message(
      '手动添加设备',
      name: 'setting_accessibility_add_devices',
      desc: '',
      args: [],
    );
  }

  /// `输入其他设备连接信息以手动添加设备`
  String get setting_accessibility_add_devices_des {
    return Intl.message(
      '输入其他设备连接信息以手动添加设备',
      name: 'setting_accessibility_add_devices_des',
      desc: '',
      args: [],
    );
  }

  /// `进阶功能`
  String get setting_advances {
    return Intl.message(
      '进阶功能',
      name: 'setting_advances',
      desc: '',
      args: [],
    );
  }

  /// `关联设备后，复制的文字可共享`
  String get setting_cross_device_clipboard_des {
    return Intl.message(
      '关联设备后，复制的文字可共享',
      name: 'setting_cross_device_clipboard_des',
      desc: '',
      args: [],
    );
  }

  /// `接收设置`
  String get setting_receive {
    return Intl.message(
      '接收设置',
      name: 'setting_receive',
      desc: '',
      args: [],
    );
  }

  /// `自动接收`
  String get setting_receive_auto {
    return Intl.message(
      '自动接收',
      name: 'setting_receive_auto',
      desc: '',
      args: [],
    );
  }

  /// `收到的文件将自动保存`
  String get setting_receive_auto_des {
    return Intl.message(
      '收到的文件将自动保存',
      name: 'setting_receive_auto_des',
      desc: '',
      args: [],
    );
  }

  /// `文件接收目录`
  String get setting_receive_folder {
    return Intl.message(
      '文件接收目录',
      name: 'setting_receive_folder',
      desc: '',
      args: [],
    );
  }

  /// `自动将图片视频保存到相册`
  String get setting_receive_to_album {
    return Intl.message(
      '自动将图片视频保存到相册',
      name: 'setting_receive_to_album',
      desc: '',
      args: [],
    );
  }

  /// `不保存到接收目录`
  String get setting_receive_to_album_des {
    return Intl.message(
      '不保存到接收目录',
      name: 'setting_receive_to_album_des',
      desc: '',
      args: [],
    );
  }

  /// `更多`
  String get setting_more {
    return Intl.message(
      '更多',
      name: 'setting_more',
      desc: '',
      args: [],
    );
  }

  /// `启用新的设备发现方式`
  String get setting_more_new_discover {
    return Intl.message(
      '启用新的设备发现方式',
      name: 'setting_more_new_discover',
      desc: '',
      args: [],
    );
  }

  /// `开启后可解决开热点后无法发现设备的问题。若遇到兼容问题，请尝试关闭此开关，并反馈给我们❤️`
  String get setting_more_new_discover_des {
    return Intl.message(
      '开启后可解决开热点后无法发现设备的问题。若遇到兼容问题，请尝试关闭此开关，并反馈给我们❤️',
      name: 'setting_more_new_discover_des',
      desc: '',
      args: [],
    );
  }

  /// `深色模式`
  String get setting_more_dark_mode {
    return Intl.message(
      '深色模式',
      name: 'setting_more_dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `始终开启`
  String get setting_more_dark_mode_on {
    return Intl.message(
      '始终开启',
      name: 'setting_more_dark_mode_on',
      desc: '',
      args: [],
    );
  }

  /// `始终关闭`
  String get setting_more_dark_mode_off {
    return Intl.message(
      '始终关闭',
      name: 'setting_more_dark_mode_off',
      desc: '',
      args: [],
    );
  }

  /// `跟随系统`
  String get setting_more_dark_mode_sync {
    return Intl.message(
      '跟随系统',
      name: 'setting_more_dark_mode_sync',
      desc: '',
      args: [],
    );
  }

  /// `清除缓存`
  String get setting_more_clean_cache {
    return Intl.message(
      '清除缓存',
      name: 'setting_more_clean_cache',
      desc: '',
      args: [],
    );
  }

  /// `退出软件`
  String get setting_exit {
    return Intl.message(
      '退出软件',
      name: 'setting_exit',
      desc: '',
      args: [],
    );
  }

  /// `选择本机应用`
  String get android_apps_title {
    return Intl.message(
      '选择本机应用',
      name: 'android_apps_title',
      desc: '',
      args: [],
    );
  }

  /// `发送 ({count})`
  String android_app_send(int count) {
    return Intl.message(
      '发送 ($count)',
      name: 'android_app_send',
      desc: '',
      args: [count],
    );
  }

  /// `存储权限`
  String get base_storage_permission {
    return Intl.message(
      '存储权限',
      name: 'base_storage_permission',
      desc: '',
      args: [],
    );
  }

  /// `接收文件需要设备的存储权限`
  String get base_storage_permission_des {
    return Intl.message(
      '接收文件需要设备的存储权限',
      name: 'base_storage_permission_des',
      desc: '',
      args: [],
    );
  }

  /// `已连接`
  String get device_ap_connected {
    return Intl.message(
      '已连接',
      name: 'device_ap_connected',
      desc: '',
      args: [],
    );
  }

  /// `WiFi已连接`
  String get device_wifi_connected {
    return Intl.message(
      'WiFi已连接',
      name: 'device_wifi_connected',
      desc: '',
      args: [],
    );
  }

  /// `WiFi未连接`
  String get device_wifi_not_connected {
    return Intl.message(
      'WiFi未连接',
      name: 'device_wifi_not_connected',
      desc: '',
      args: [],
    );
  }

  /// `网络未连接`
  String get device_no_network {
    return Intl.message(
      '网络未连接',
      name: 'device_no_network',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get device_delete {
    return Intl.message(
      '删除',
      name: 'device_delete',
      desc: '',
      args: [],
    );
  }

  /// `选择一个设备`
  String get pick_one {
    return Intl.message(
      '选择一个设备',
      name: 'pick_one',
      desc: '',
      args: [],
    );
  }

  /// `没有相机权限`
  String get qr_no_camera_permission {
    return Intl.message(
      '没有相机权限',
      name: 'qr_no_camera_permission',
      desc: '',
      args: [],
    );
  }

  /// `扫一扫`
  String get qr_scan {
    return Intl.message(
      '扫一扫',
      name: 'qr_scan',
      desc: '',
      args: [],
    );
  }

  /// `打开 Flix 二维码，快速建立热点连接。`
  String get qr_scan_tip {
    return Intl.message(
      '打开 Flix 二维码，快速建立热点连接。',
      name: 'qr_scan_tip',
      desc: '',
      args: [],
    );
  }

  /// `正在准备发送，请稍候`
  String get widget_toast_prepare_sending {
    return Intl.message(
      '正在准备发送，请稍候',
      name: 'widget_toast_prepare_sending',
      desc: '',
      args: [],
    );
  }

  /// `删除消息记录`
  String get widget_delete_msg_history {
    return Intl.message(
      '删除消息记录',
      name: 'widget_delete_msg_history',
      desc: '',
      args: [],
    );
  }

  /// `如果文件正在传输，删除消息会中断传输`
  String get widget_delete_msg_history_subtitle {
    return Intl.message(
      '如果文件正在传输，删除消息会中断传输',
      name: 'widget_delete_msg_history_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get widget_delete_msg_history_action {
    return Intl.message(
      '删除',
      name: 'widget_delete_msg_history_action',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get widget_multiple_delete {
    return Intl.message(
      '删除',
      name: 'widget_multiple_delete',
      desc: '',
      args: [],
    );
  }

  /// `推荐给朋友`
  String get widget_recommend {
    return Intl.message(
      '推荐给朋友',
      name: 'widget_recommend',
      desc: '',
      args: [],
    );
  }

  /// `扫码即可下载`
  String get widget_recommend_subtitle {
    return Intl.message(
      '扫码即可下载',
      name: 'widget_recommend_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `完成`
  String get widget_recommend_action {
    return Intl.message(
      '完成',
      name: 'widget_recommend_action',
      desc: '',
      args: [],
    );
  }

  /// `完成`
  String get widget_verification_action {
    return Intl.message(
      '完成',
      name: 'widget_verification_action',
      desc: '',
      args: [],
    );
  }

  /// `点击接收`
  String get bubbles_accept {
    return Intl.message(
      '点击接收',
      name: 'bubbles_accept',
      desc: '',
      args: [],
    );
  }

  /// `点击确认接收`
  String get bubbles_click_to_accept {
    return Intl.message(
      '点击确认接收',
      name: 'bubbles_click_to_accept',
      desc: '',
      args: [],
    );
  }

  /// `文件夹内容`
  String get bubbles_dir {
    return Intl.message(
      '文件夹内容',
      name: 'bubbles_dir',
      desc: '',
      args: [],
    );
  }

  /// `加载错误了哦，一会再试试吧~`
  String get bubbles_dir_load_error {
    return Intl.message(
      '加载错误了哦，一会再试试吧~',
      name: 'bubbles_dir_load_error',
      desc: '',
      args: [],
    );
  }

  /// `无数据`
  String get bubbles_dir_no_data {
    return Intl.message(
      '无数据',
      name: 'bubbles_dir_no_data',
      desc: '',
      args: [],
    );
  }

  /// `等待对方确认`
  String get bubbles_wait_for_confirm {
    return Intl.message(
      '等待对方确认',
      name: 'bubbles_wait_for_confirm',
      desc: '',
      args: [],
    );
  }

  /// `已发送`
  String get bubbles_send_done {
    return Intl.message(
      '已发送',
      name: 'bubbles_send_done',
      desc: '',
      args: [],
    );
  }

  /// `发送异常`
  String get bubbles_send_failed {
    return Intl.message(
      '发送异常',
      name: 'bubbles_send_failed',
      desc: '',
      args: [],
    );
  }

  /// `已取消`
  String get bubbles_send_cancel {
    return Intl.message(
      '已取消',
      name: 'bubbles_send_cancel',
      desc: '',
      args: [],
    );
  }

  /// `待接收`
  String get bubbles_wait_for_receive {
    return Intl.message(
      '待接收',
      name: 'bubbles_wait_for_receive',
      desc: '',
      args: [],
    );
  }

  /// `已下载`
  String get bubbles_downloaded {
    return Intl.message(
      '已下载',
      name: 'bubbles_downloaded',
      desc: '',
      args: [],
    );
  }

  /// `接收失败`
  String get bubbles_receive_failed {
    return Intl.message(
      '接收失败',
      name: 'bubbles_receive_failed',
      desc: '',
      args: [],
    );
  }

  /// `已取消`
  String get bubbles_receive_cancel {
    return Intl.message(
      '已取消',
      name: 'bubbles_receive_cancel',
      desc: '',
      args: [],
    );
  }

  /// `重新发送文件`
  String get bubbles_toast_resend {
    return Intl.message(
      '重新发送文件',
      name: 'bubbles_toast_resend',
      desc: '',
      args: [],
    );
  }

  /// `重新接收文件`
  String get bubbles_toast_re_receive {
    return Intl.message(
      '重新接收文件',
      name: 'bubbles_toast_re_receive',
      desc: '',
      args: [],
    );
  }

  /// `已复制到剪切板`
  String get bubbles_copied {
    return Intl.message(
      '已复制到剪切板',
      name: 'bubbles_copied',
      desc: '',
      args: [],
    );
  }

  /// `昨天 {time}`
  String bubbles_yesterday(String time) {
    return Intl.message(
      '昨天 $time',
      name: 'bubbles_yesterday',
      desc: '',
      args: [time],
    );
  }

  /// `输入本机名称`
  String get device_name_input {
    return Intl.message(
      '输入本机名称',
      name: 'device_name_input',
      desc: '',
      args: [],
    );
  }

  /// `完成`
  String get device_name_input_action {
    return Intl.message(
      '完成',
      name: 'device_name_input_action',
      desc: '',
      args: [],
    );
  }

  /// `推荐给朋友`
  String get share_flix {
    return Intl.message(
      '推荐给朋友',
      name: 'share_flix',
      desc: '',
      args: [],
    );
  }

  /// `完成`
  String get share_flix_action {
    return Intl.message(
      '完成',
      name: 'share_flix_action',
      desc: '',
      args: [],
    );
  }

  /// `官网（点击复制）:  flix.center`
  String get share_flix_website {
    return Intl.message(
      '官网（点击复制）:  flix.center',
      name: 'share_flix_website',
      desc: '',
      args: [],
    );
  }

  /// `已复制到剪贴板`
  String get share_flix_copied {
    return Intl.message(
      '已复制到剪贴板',
      name: 'share_flix_copied',
      desc: '',
      args: [],
    );
  }

  /// `扫一扫`
  String get menu_scan {
    return Intl.message(
      '扫一扫',
      name: 'menu_scan',
      desc: '',
      args: [],
    );
  }

  /// `我的热点码`
  String get menu_hotspot {
    return Intl.message(
      '我的热点码',
      name: 'menu_hotspot',
      desc: '',
      args: [],
    );
  }

  /// `手动添加设备`
  String get menu_add_manually {
    return Intl.message(
      '手动添加设备',
      name: 'menu_add_manually',
      desc: '',
      args: [],
    );
  }

  /// `添加此设备`
  String get menu_add_this_device {
    return Intl.message(
      '添加此设备',
      name: 'menu_add_this_device',
      desc: '',
      args: [],
    );
  }

  /// `手动输入添加`
  String get menu_add_manually_input {
    return Intl.message(
      '手动输入添加',
      name: 'menu_add_manually_input',
      desc: '',
      args: [],
    );
  }

  /// `网络连接信息`
  String get net_info {
    return Intl.message(
      '网络连接信息',
      name: 'net_info',
      desc: '',
      args: [],
    );
  }

  /// `关闭`
  String get net_ap_close {
    return Intl.message(
      '关闭',
      name: 'net_ap_close',
      desc: '',
      args: [],
    );
  }

  /// `热点已关闭`
  String get net_toast_ap_close {
    return Intl.message(
      '热点已关闭',
      name: 'net_toast_ap_close',
      desc: '',
      args: [],
    );
  }

  /// `确认`
  String get permission_confirm {
    return Intl.message(
      '确认',
      name: 'permission_confirm',
      desc: '',
      args: [],
    );
  }

  /// `复制`
  String get bubbles_menu_copy {
    return Intl.message(
      '复制',
      name: 'bubbles_menu_copy',
      desc: '',
      args: [],
    );
  }

  /// `转发`
  String get bubbles_menu_forward {
    return Intl.message(
      '转发',
      name: 'bubbles_menu_forward',
      desc: '',
      args: [],
    );
  }

  /// `文件打开`
  String get bubbles_menu_open {
    return Intl.message(
      '文件打开',
      name: 'bubbles_menu_open',
      desc: '',
      args: [],
    );
  }

  /// `文件位置`
  String get bubbles_menu_location {
    return Intl.message(
      '文件位置',
      name: 'bubbles_menu_location',
      desc: '',
      args: [],
    );
  }

  /// `另存为`
  String get bubbles_menu_save_as {
    return Intl.message(
      '另存为',
      name: 'bubbles_menu_save_as',
      desc: '',
      args: [],
    );
  }

  /// `多选`
  String get bubbles_menu_multiple {
    return Intl.message(
      '多选',
      name: 'bubbles_menu_multiple',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get bubbles_menu_delete {
    return Intl.message(
      '删除',
      name: 'bubbles_menu_delete',
      desc: '',
      args: [],
    );
  }

  /// `自由复制`
  String get bubbles_menu_free_copy {
    return Intl.message(
      '自由复制',
      name: 'bubbles_menu_free_copy',
      desc: '',
      args: [],
    );
  }

  /// `取消发送`
  String get button_cancel_send {
    return Intl.message(
      '取消发送',
      name: 'button_cancel_send',
      desc: '',
      args: [],
    );
  }

  /// `重新发送`
  String get button_resend {
    return Intl.message(
      '重新发送',
      name: 'button_resend',
      desc: '',
      args: [],
    );
  }

  /// `保存成功`
  String get bubbles_toast_save_success {
    return Intl.message(
      '保存成功',
      name: 'bubbles_toast_save_success',
      desc: '',
      args: [],
    );
  }

  /// `无法选择文件夹：{error}`
  String file_pick_error(String error) {
    return Intl.message(
      '无法选择文件夹：$error',
      name: 'file_pick_error',
      desc: '',
      args: [error],
    );
  }

  /// `无法选择文件夹`
  String get file_pick_error_0 {
    return Intl.message(
      '无法选择文件夹',
      name: 'file_pick_error_0',
      desc: '',
      args: [],
    );
  }

  /// `无权限发送此文件夹`
  String get file_pick_error_1 {
    return Intl.message(
      '无权限发送此文件夹',
      name: 'file_pick_error_1',
      desc: '',
      args: [],
    );
  }

  /// `点击「打开」选择文件夹`
  String get file_pick_error_20 {
    return Intl.message(
      '点击「打开」选择文件夹',
      name: 'file_pick_error_20',
      desc: '',
      args: [],
    );
  }

  /// `搜索`
  String get search {
    return Intl.message(
      '搜索',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `设备已离线`
  String get device_offline {
    return Intl.message(
      '设备已离线',
      name: 'device_offline',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
