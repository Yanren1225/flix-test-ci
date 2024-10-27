// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(count) => "Send (${count})";

  static String m1(time) => "Yesterday ${time}";

  static String m2(device) => "To ${device}";

  static String m3(error) => "Unable to select folder: ${error}";

  static String m4(platform) => "Save and jump to ${platform} to scan";

  static String m5(newVersion) => "New version v${newVersion}";

  static String m6(version) => "Current software version: v ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "android_app_send": m0,
        "android_apps_title":
            MessageLookupByLibrary.simpleMessage("Select local application"),
        "app_name": MessageLookupByLibrary.simpleMessage("Flix"),
        "base_storage_permission":
            MessageLookupByLibrary.simpleMessage("Storage permission"),
        "base_storage_permission_des": MessageLookupByLibrary.simpleMessage(
            "Receiving files requires storage permissions on the device"),
        "bubbles_accept":
            MessageLookupByLibrary.simpleMessage("Click to receive"),
        "bubbles_click_to_accept":
            MessageLookupByLibrary.simpleMessage("Click to confirm receipt"),
        "bubbles_copied":
            MessageLookupByLibrary.simpleMessage("Copy to clipboard"),
        "bubbles_dir": MessageLookupByLibrary.simpleMessage("Folder contents"),
        "bubbles_dir_load_error": MessageLookupByLibrary.simpleMessage(
            "Loading error, please try again later~"),
        "bubbles_dir_no_data":
            MessageLookupByLibrary.simpleMessage("No data available"),
        "bubbles_downloaded":
            MessageLookupByLibrary.simpleMessage("Downloaded"),
        "bubbles_menu_copy": MessageLookupByLibrary.simpleMessage("copy"),
        "bubbles_menu_delete": MessageLookupByLibrary.simpleMessage("delete"),
        "bubbles_menu_forward": MessageLookupByLibrary.simpleMessage("forward"),
        "bubbles_menu_free_copy":
            MessageLookupByLibrary.simpleMessage("Free copying"),
        "bubbles_menu_location":
            MessageLookupByLibrary.simpleMessage("file location"),
        "bubbles_menu_multiple":
            MessageLookupByLibrary.simpleMessage("Multiple Choice"),
        "bubbles_menu_open": MessageLookupByLibrary.simpleMessage("file open"),
        "bubbles_menu_save_as": MessageLookupByLibrary.simpleMessage("Save as"),
        "bubbles_receive_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelled"),
        "bubbles_receive_failed":
            MessageLookupByLibrary.simpleMessage("Receiving failed"),
        "bubbles_send_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelled"),
        "bubbles_send_done":
            MessageLookupByLibrary.simpleMessage("has been sent"),
        "bubbles_send_failed":
            MessageLookupByLibrary.simpleMessage("Sending exception"),
        "bubbles_toast_re_receive":
            MessageLookupByLibrary.simpleMessage("Re receive files"),
        "bubbles_toast_resend":
            MessageLookupByLibrary.simpleMessage("Resend the file"),
        "bubbles_toast_save_success":
            MessageLookupByLibrary.simpleMessage("Saved successfully"),
        "bubbles_wait_for_confirm": MessageLookupByLibrary.simpleMessage(
            "Waiting for confirmation from the other party"),
        "bubbles_wait_for_receive":
            MessageLookupByLibrary.simpleMessage("To be received"),
        "bubbles_yesterday": m1,
        "button_cancel_send":
            MessageLookupByLibrary.simpleMessage("Cancel sending"),
        "button_resend": MessageLookupByLibrary.simpleMessage("Resend"),
        "device_ap_connected":
            MessageLookupByLibrary.simpleMessage("Connected already"),
        "device_delete": MessageLookupByLibrary.simpleMessage("delete"),
        "device_name_input": MessageLookupByLibrary.simpleMessage(
            "Enter the local machine name"),
        "device_name_input_action":
            MessageLookupByLibrary.simpleMessage("complete"),
        "device_no_network":
            MessageLookupByLibrary.simpleMessage("Network not connected"),
        "device_offline":
            MessageLookupByLibrary.simpleMessage("Device Offline"),
        "device_wifi_connected":
            MessageLookupByLibrary.simpleMessage("WiFi connected"),
        "device_wifi_not_connected":
            MessageLookupByLibrary.simpleMessage("WiFi not connected"),
        "dialog_confirm_send_button":
            MessageLookupByLibrary.simpleMessage("Send"),
        "dialog_confirm_send_subtitle": m2,
        "dialog_confirm_send_title":
            MessageLookupByLibrary.simpleMessage("send files"),
        "dialog_exit_button": MessageLookupByLibrary.simpleMessage("Exit"),
        "dialog_exit_subtitle": MessageLookupByLibrary.simpleMessage(
            "After exiting, it will not be detected by nearby devices."),
        "dialog_exit_title": MessageLookupByLibrary.simpleMessage("Exit"),
        "dialog_new_version_button":
            MessageLookupByLibrary.simpleMessage("Upgrade"),
        "dialog_new_version_subtitle": MessageLookupByLibrary.simpleMessage(
            "Suggest upgrading to a new version for a better experience"),
        "dialog_new_version_title":
            MessageLookupByLibrary.simpleMessage("Update available"),
        "file_pick_error": m3,
        "file_pick_error_0":
            MessageLookupByLibrary.simpleMessage("Unable to select folder"),
        "file_pick_error_1": MessageLookupByLibrary.simpleMessage(
            "No permission to send this folder"),
        "file_pick_error_20": MessageLookupByLibrary.simpleMessage(
            "Click \'Open\' to select a folder"),
        "help_a_1": MessageLookupByLibrary.simpleMessage(
            "Please confirm that the sending and receiving devices are in the same network state. For example, using the same WIFI or connecting to other devices using a local hotspot."),
        "help_a_2": MessageLookupByLibrary.simpleMessage("Never."),
        "help_a_3": MessageLookupByLibrary.simpleMessage(
            "请先按照以下步骤，尝试将flix添加到Windows网络防火墙白名单中：\n1. 搜索「允许应用通过Windows防火墙」\n2. 点击「更改设置」\n3. 点击「允许其他应用」\n4. 添加flix.exe路径（C:\\Users\\[用户名]\\AppData\\Roaming\\Flix\\Flix\\flix.exe或C:\\Program Files\\Flix\\flix.exe）\n5. 点击「添加」返回到上一页面\n6. 查看列表中的flix项，勾选「专用」和「公用」\n7. 保存\nIf the above steps still cannot be received, please contact us."),
        "help_a_4": MessageLookupByLibrary.simpleMessage(
            "Please ensure that the PC and other devices are under the same subnet, meaning that their direct upper layer devices are on the same router. If the PC is connected to the optical modem, other devices connected to the router via WiFi will not be able to receive files properly."),
        "help_about": MessageLookupByLibrary.simpleMessage("About US"),
        "help_check_update":
            MessageLookupByLibrary.simpleMessage("Check for updates"),
        "help_description": MessageLookupByLibrary.simpleMessage(
            "This is Flix, a fast and simple multi terminal transmission software. Hope you like it 😆"),
        "help_dev_team": MessageLookupByLibrary.simpleMessage(
            "Flix Develop Team\n------\n✅Design：\nlemo\nkailun\n\n✅Develop：\nMovenLecker\nEava_wu\n炎忍\nMashiro.\nGnayoah\n张建\n广靓\nChengi\nxkeyC\n小灰灰\n何言\ngggxbbb\n一季或微凉\n暮间雾\nyuzh"),
        "help_donate":
            MessageLookupByLibrary.simpleMessage("❤️ Donate to support us"),
        "help_donate_alipay": MessageLookupByLibrary.simpleMessage("Alipay"),
        "help_donate_go": m4,
        "help_donate_title": MessageLookupByLibrary.simpleMessage("Sponsor"),
        "help_donate_wechat": MessageLookupByLibrary.simpleMessage("WeChat"),
        "help_finally":
            MessageLookupByLibrary.simpleMessage("Finally, you can also"),
        "help_hello": MessageLookupByLibrary.simpleMessage(
            "👋 Hello. Nice to meet you.!"),
        "help_join_qq": MessageLookupByLibrary.simpleMessage(
            "Welcome to join the QQ group and contact us~\n"),
        "help_latest_version": MessageLookupByLibrary.simpleMessage(
            "It is already the latest version"),
        "help_new_version": m5,
        "help_q_1": MessageLookupByLibrary.simpleMessage(
            "Can\'t find devices in the list?"),
        "help_q_2": MessageLookupByLibrary.simpleMessage(
            "Will transferring files consume data?"),
        "help_q_3": MessageLookupByLibrary.simpleMessage(
            "Why Windows cannot receive/send files?"),
        "help_q_4": MessageLookupByLibrary.simpleMessage(
            "Can\'t PC receive/send files when using Ethernet cable?"),
        "help_q_title":
            MessageLookupByLibrary.simpleMessage("About Connection"),
        "help_qq_1": MessageLookupByLibrary.simpleMessage("User QQ Group 1:\n"),
        "help_qq_2":
            MessageLookupByLibrary.simpleMessage("\nUser QQ Group 2:\n"),
        "help_qq_3":
            MessageLookupByLibrary.simpleMessage("\nUser QQ Group 3:\n"),
        "help_recommend":
            MessageLookupByLibrary.simpleMessage("👍 Recommend to friends"),
        "help_sponsor": MessageLookupByLibrary.simpleMessage(
            "Click me to sponsor this project"),
        "help_thanks": MessageLookupByLibrary.simpleMessage(
            ", thank you very much for supporting our continuous development 🙏"),
        "help_title": MessageLookupByLibrary.simpleMessage("App Help"),
        "help_version": m6,
        "homepage_select_device":
            MessageLookupByLibrary.simpleMessage("Please select a device"),
        "hotspot_connect_failed":
            MessageLookupByLibrary.simpleMessage("Hotspot connection failed"),
        "hotspot_connect_failed_action":
            MessageLookupByLibrary.simpleMessage("Retry"),
        "hotspot_connect_success": MessageLookupByLibrary.simpleMessage(
            "Hotspot connection successful"),
        "hotspot_connect_success_action":
            MessageLookupByLibrary.simpleMessage("Return to transfer"),
        "hotspot_connecting":
            MessageLookupByLibrary.simpleMessage("Connecting to hotspot"),
        "hotspot_disabled":
            MessageLookupByLibrary.simpleMessage("Hotspot has been closed"),
        "hotspot_disabled_action":
            MessageLookupByLibrary.simpleMessage("Restart"),
        "hotspot_enable_failed":
            MessageLookupByLibrary.simpleMessage("Failed to activate hotspot"),
        "hotspot_enable_failed_action":
            MessageLookupByLibrary.simpleMessage("Try again"),
        "hotspot_enable_failed_tip": MessageLookupByLibrary.simpleMessage(
            "Turn off your system hotspot,\nTry again after reopening WiFi."),
        "hotspot_enabling":
            MessageLookupByLibrary.simpleMessage("Opening hotspot"),
        "hotspot_get_ap_info_failed": MessageLookupByLibrary.simpleMessage(
            "Failed to obtain hotspot information"),
        "hotspot_get_ap_info_failed_action":
            MessageLookupByLibrary.simpleMessage("Retry"),
        "hotspot_info_password":
            MessageLookupByLibrary.simpleMessage("Hotspot password:"),
        "hotspot_info_ssid":
            MessageLookupByLibrary.simpleMessage("Hotspot Name:"),
        "hotspot_initializing":
            MessageLookupByLibrary.simpleMessage("Initializing hotspot"),
        "hotspot_missing_permission": MessageLookupByLibrary.simpleMessage(
            "Lack of necessary permissions"),
        "hotspot_missing_permission_action":
            MessageLookupByLibrary.simpleMessage("Grant necessary permissions"),
        "hotspot_my_qrcode": MessageLookupByLibrary.simpleMessage("My QR code"),
        "hotspot_qrcode_tip": MessageLookupByLibrary.simpleMessage(
            "Open Flix and scan to quickly establish hotspot connections."),
        "hotspot_wifi_disabled":
            MessageLookupByLibrary.simpleMessage("WiFi not turned on"),
        "hotspot_wifi_disabled_action":
            MessageLookupByLibrary.simpleMessage("Open"),
        "hotspot_wifi_initializing":
            MessageLookupByLibrary.simpleMessage("Initializing WiFi"),
        "menu_add_manually":
            MessageLookupByLibrary.simpleMessage("Manually adding devices"),
        "menu_add_manually_input":
            MessageLookupByLibrary.simpleMessage("Manually input and add"),
        "menu_add_this_device":
            MessageLookupByLibrary.simpleMessage("Add this device"),
        "menu_hotspot": MessageLookupByLibrary.simpleMessage("My hotspot code"),
        "menu_scan": MessageLookupByLibrary.simpleMessage("scan"),
        "navigation_config": MessageLookupByLibrary.simpleMessage("Configure"),
        "navigation_help": MessageLookupByLibrary.simpleMessage("Help"),
        "navigation_send": MessageLookupByLibrary.simpleMessage("Transfer"),
        "net_ap_close": MessageLookupByLibrary.simpleMessage("close"),
        "net_info": MessageLookupByLibrary.simpleMessage(
            "Network connection information"),
        "net_toast_ap_close":
            MessageLookupByLibrary.simpleMessage("Hotspot has been closed"),
        "paircode_add_IP": MessageLookupByLibrary.simpleMessage("IP"),
        "paircode_add_device":
            MessageLookupByLibrary.simpleMessage("Add device"),
        "paircode_add_failed":
            MessageLookupByLibrary.simpleMessage("Add failed"),
        "paircode_add_manually":
            MessageLookupByLibrary.simpleMessage("Manually input and add"),
        "paircode_add_port":
            MessageLookupByLibrary.simpleMessage("Network port"),
        "paircode_add_success":
            MessageLookupByLibrary.simpleMessage("Added successfully"),
        "paircode_dialog_add_device":
            MessageLookupByLibrary.simpleMessage("Add device"),
        "paircode_dialog_add_device_action":
            MessageLookupByLibrary.simpleMessage("Retry"),
        "paircode_dialog_adding_device":
            MessageLookupByLibrary.simpleMessage("Adding device…"),
        "paircode_local_IP":
            MessageLookupByLibrary.simpleMessage("Local IP address"),
        "paircode_local_port":
            MessageLookupByLibrary.simpleMessage("Local network port"),
        "paircode_scan_to_add": MessageLookupByLibrary.simpleMessage(
            "Scan to add this device with Flix"),
        "paircode_toast_config_incorrect":
            MessageLookupByLibrary.simpleMessage("Incorrect IP or port"),
        "permission_confirm": MessageLookupByLibrary.simpleMessage("confirm"),
        "pick_one": MessageLookupByLibrary.simpleMessage("Select a device"),
        "qr_no_camera_permission":
            MessageLookupByLibrary.simpleMessage("No camera permission"),
        "qr_scan": MessageLookupByLibrary.simpleMessage("scan"),
        "qr_scan_tip": MessageLookupByLibrary.simpleMessage(
            "Open the Flix QR code and quickly establish a hotspot connection."),
        "search": MessageLookupByLibrary.simpleMessage("search"),
        "setting_accessibility":
            MessageLookupByLibrary.simpleMessage("Auxiliary functions"),
        "setting_accessibility_add_devices":
            MessageLookupByLibrary.simpleMessage("Manually adding devices"),
        "setting_accessibility_add_devices_des":
            MessageLookupByLibrary.simpleMessage(
                "Enter other device connection information to manually add devices"),
        "setting_accessibility_add_self":
            MessageLookupByLibrary.simpleMessage("Add this device"),
        "setting_accessibility_add_self_des": MessageLookupByLibrary.simpleMessage(
            "View the connection information of this device to manually add on other devices"),
        "setting_advances": MessageLookupByLibrary.simpleMessage("Advanced"),
        "setting_auto_start": MessageLookupByLibrary.simpleMessage(
            "Automatically start upon startup"),
        "setting_confirm_clean_cache":
            MessageLookupByLibrary.simpleMessage("Clear Cache"),
        "setting_confirm_clean_cache_action":
            MessageLookupByLibrary.simpleMessage("Clear"),
        "setting_confirm_clean_cache_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Due to system limitations, sent files may be cached. Clearing the cache may interrupt the sending of files and result in some sent files being unable to preview. Clearing the cache does not affect received files"),
        "setting_cross_device_clipboard":
            MessageLookupByLibrary.simpleMessage("Cross-device Clipboard"),
        "setting_cross_device_clipboard_des":
            MessageLookupByLibrary.simpleMessage(
                "After linking devices, copied text can be shared"),
        "setting_cross_device_clipboard_other_devices":
            MessageLookupByLibrary.simpleMessage(
                "Other available devices on the current network:"),
        "setting_cross_device_clipboard_paircode":
            MessageLookupByLibrary.simpleMessage("View the pair code"),
        "setting_cross_device_clipboard_paired_devices":
            MessageLookupByLibrary.simpleMessage("Linked devices"),
        "setting_cross_device_clipboard_popup_input_paircode":
            MessageLookupByLibrary.simpleMessage("Enter pair code"),
        "setting_cross_device_clipboard_popup_input_paircode_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Enter the 4-digit number on the other device to enable cross device clipboard. Effective within 5 minutes."),
        "setting_cross_device_clipboard_popup_self_paircode":
            MessageLookupByLibrary.simpleMessage("Pair Code"),
        "setting_cross_device_clipboard_popup_self_paircode_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "The other party can enter your pair code to enable cross device clipboard. Effective within 5 minutes."),
        "setting_cross_device_clipboard_tip":
            MessageLookupByLibrary.simpleMessage(
                "After linking devices, copied text can be shared"),
        "setting_cross_device_clipboard_too_low_to_pair":
            MessageLookupByLibrary.simpleMessage(
                "The target device version is too low and does not support pairing"),
        "setting_device_name":
            MessageLookupByLibrary.simpleMessage("Local name"),
        "setting_exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "setting_more": MessageLookupByLibrary.simpleMessage("more"),
        "setting_more_clean_cache":
            MessageLookupByLibrary.simpleMessage("Clear cache"),
        "setting_more_dark_mode":
            MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "setting_more_dark_mode_off":
            MessageLookupByLibrary.simpleMessage("Always closed"),
        "setting_more_dark_mode_on":
            MessageLookupByLibrary.simpleMessage("Always open"),
        "setting_more_dark_mode_sync":
            MessageLookupByLibrary.simpleMessage("Follow the system"),
        "setting_more_new_discover": MessageLookupByLibrary.simpleMessage(
            "Enable new device discovery methods"),
        "setting_more_new_discover_des": MessageLookupByLibrary.simpleMessage(
            "Enabling it can solve the problem of not being able to detect the device after turning on the hotspot. If you encounter compatibility issues, please try turning off this switch and provide us with feedback ❤️"),
        "setting_receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "setting_receive_auto":
            MessageLookupByLibrary.simpleMessage("Automatic save"),
        "setting_receive_auto_des": MessageLookupByLibrary.simpleMessage(
            "The received files will be automatically saved"),
        "setting_receive_folder":
            MessageLookupByLibrary.simpleMessage("File receiving directory"),
        "setting_receive_to_album": MessageLookupByLibrary.simpleMessage(
            "Automatically save pictures and videos to the album"),
        "setting_receive_to_album_des": MessageLookupByLibrary.simpleMessage(
            "Do not save to receive directory"),
        "setting_title": MessageLookupByLibrary.simpleMessage("Settings"),
        "share_flix":
            MessageLookupByLibrary.simpleMessage("Recommend to friends"),
        "share_flix_action": MessageLookupByLibrary.simpleMessage("complete"),
        "share_flix_copied":
            MessageLookupByLibrary.simpleMessage("Copy to clipboard"),
        "share_flix_website": MessageLookupByLibrary.simpleMessage(
            "Official website (click to copy): flix.center"),
        "toast_copied":
            MessageLookupByLibrary.simpleMessage("Copy to clipboard"),
        "toast_msg_empty_folder": MessageLookupByLibrary.simpleMessage(
            "The folder is empty, please send to cancel"),
        "tray_menu_display": MessageLookupByLibrary.simpleMessage("Show"),
        "tray_menu_exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "tray_menu_hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "widget_delete_msg_history":
            MessageLookupByLibrary.simpleMessage("Delete message records"),
        "widget_delete_msg_history_action":
            MessageLookupByLibrary.simpleMessage("delete"),
        "widget_delete_msg_history_subtitle": MessageLookupByLibrary.simpleMessage(
            "If the file is being transferred, deleting the message will interrupt the transfer"),
        "widget_multiple_delete":
            MessageLookupByLibrary.simpleMessage("delete"),
        "widget_toast_prepare_sending": MessageLookupByLibrary.simpleMessage(
            "Preparing to send, please wait"),
        "widget_verification_action":
            MessageLookupByLibrary.simpleMessage("complete")
      };
}
