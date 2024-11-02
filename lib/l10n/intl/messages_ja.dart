// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(count) => "送信(${count})";

  static String m1(time) => "昨日 ${time}";

  static String m2(device) => "${device}へ";

  static String m3(error) => "フォルダを選択できませんでした:${error}";

  static String m4(platform) => "保存して${platform} スイープにジャンプ";

  static String m5(newVersion) => "新バージョンv${newVersion}";

  static String m6(version) => "現在のソフトウェアバージョン：v${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "android_app_send": m0,
        "android_apps_title":
            MessageLookupByLibrary.simpleMessage("ネイティブアプリケーションの選択"),
        "app_name": MessageLookupByLibrary.simpleMessage("Flix"),
        "base_storage_permission":
            MessageLookupByLibrary.simpleMessage("ストレージ権限"),
        "base_storage_permission_des":
            MessageLookupByLibrary.simpleMessage("ファイルの受信にはデバイスの記憶権限が必要です"),
        "bubbles_accept": MessageLookupByLibrary.simpleMessage("クリックして受信"),
        "bubbles_click_to_accept":
            MessageLookupByLibrary.simpleMessage("クリックして受信を確認"),
        "bubbles_copied":
            MessageLookupByLibrary.simpleMessage("クリップボードにコピーされました"),
        "bubbles_dir": MessageLookupByLibrary.simpleMessage("フォルダの内容"),
        "bubbles_dir_load_error":
            MessageLookupByLibrary.simpleMessage("ロードミスしましたよ、あとでやってみましょう~"),
        "bubbles_dir_no_data": MessageLookupByLibrary.simpleMessage("データなし"),
        "bubbles_downloaded": MessageLookupByLibrary.simpleMessage("ダウンロード済み"),
        "bubbles_menu_copy": MessageLookupByLibrary.simpleMessage("コピー"),
        "bubbles_menu_delete": MessageLookupByLibrary.simpleMessage("削除"),
        "bubbles_menu_forward": MessageLookupByLibrary.simpleMessage("転送"),
        "bubbles_menu_free_copy":
            MessageLookupByLibrary.simpleMessage("フリー・レプリケーション"),
        "bubbles_menu_location":
            MessageLookupByLibrary.simpleMessage("ファイルの場所"),
        "bubbles_menu_multiple": MessageLookupByLibrary.simpleMessage("複数選択"),
        "bubbles_menu_open": MessageLookupByLibrary.simpleMessage("ファイルを開く"),
        "bubbles_menu_save_as":
            MessageLookupByLibrary.simpleMessage("名前を付けて保存"),
        "bubbles_receive_cancel":
            MessageLookupByLibrary.simpleMessage("キャンセル済み"),
        "bubbles_receive_failed": MessageLookupByLibrary.simpleMessage("受信失敗"),
        "bubbles_send_cancel": MessageLookupByLibrary.simpleMessage("キャンセル済み"),
        "bubbles_send_done": MessageLookupByLibrary.simpleMessage("送信済み"),
        "bubbles_send_failed": MessageLookupByLibrary.simpleMessage("送信例外"),
        "bubbles_toast_re_receive":
            MessageLookupByLibrary.simpleMessage("ファイルを再受信"),
        "bubbles_toast_resend":
            MessageLookupByLibrary.simpleMessage("ファイルを再送信"),
        "bubbles_toast_save_success":
            MessageLookupByLibrary.simpleMessage("保存に成功しました"),
        "bubbles_wait_for_confirm":
            MessageLookupByLibrary.simpleMessage("相手の確認待ち"),
        "bubbles_wait_for_receive":
            MessageLookupByLibrary.simpleMessage("受入保留中"),
        "bubbles_yesterday": m1,
        "button_cancel_send": MessageLookupByLibrary.simpleMessage("送信をキャンセル"),
        "button_resend": MessageLookupByLibrary.simpleMessage("再送信"),
        "device_ap_connected": MessageLookupByLibrary.simpleMessage("接続済み"),
        "device_delete": MessageLookupByLibrary.simpleMessage("削除"),
        "device_name_input": MessageLookupByLibrary.simpleMessage("ネイティブ名を入力"),
        "device_name_input_action": MessageLookupByLibrary.simpleMessage("完了"),
        "device_no_network":
            MessageLookupByLibrary.simpleMessage("ネットワークが接続されていません"),
        "device_offline":
            MessageLookupByLibrary.simpleMessage("デバイスがオフラインになっています"),
        "device_wifi_connected":
            MessageLookupByLibrary.simpleMessage("WiFi接続済み"),
        "device_wifi_not_connected":
            MessageLookupByLibrary.simpleMessage("WiFi未接続"),
        "dialog_confirm_send_button":
            MessageLookupByLibrary.simpleMessage("送信"),
        "dialog_confirm_send_subtitle": m2,
        "dialog_confirm_send_title":
            MessageLookupByLibrary.simpleMessage("ファイルを送信"),
        "dialog_exit_button": MessageLookupByLibrary.simpleMessage("終了"),
        "dialog_exit_subtitle":
            MessageLookupByLibrary.simpleMessage("終了すると、近くのデバイスに検出されません。"),
        "dialog_exit_title": MessageLookupByLibrary.simpleMessage("アプリ終了"),
        "dialog_new_version_button":
            MessageLookupByLibrary.simpleMessage("アップグレード"),
        "dialog_new_version_subtitle": MessageLookupByLibrary.simpleMessage(
            "新しいバージョンにアップグレードして、より良い体験をすることをお勧めしますよ～"),
        "dialog_new_version_title":
            MessageLookupByLibrary.simpleMessage("新しいバージョンの検出"),
        "file_pick_error": m3,
        "file_pick_error_0":
            MessageLookupByLibrary.simpleMessage("フォルダを選択できません"),
        "file_pick_error_1":
            MessageLookupByLibrary.simpleMessage("このフォルダを送信する権限がありません"),
        "file_pick_error_20":
            MessageLookupByLibrary.simpleMessage("「開く」をクリックしてフォルダを選択"),
        "help_a_1": MessageLookupByLibrary.simpleMessage(
            "送信側と受信側のデバイスが同じネットワーク状態にあることを確認してください。例：同じWIFI、またはローカルホットスポットを使用して他のデバイスに接続して使用します。"),
        "help_a_2": MessageLookupByLibrary.simpleMessage("できません。"),
        "help_a_3": MessageLookupByLibrary.simpleMessage(
            "上記の手順を試してもまだ受信できませんので、お問い合わせください。"),
        "help_a_4": MessageLookupByLibrary.simpleMessage(
            "PCと他のデバイスがサブネットの下にあることを保証してください。つまり、それらの直接上位デバイスは同じルータです。PCが接続された光猫を通過すると、他のデバイスがWifiで接続されたルータではファイルを正常に受信できません。"),
        "help_about": MessageLookupByLibrary.simpleMessage("私たちについて"),
        "help_check_update": MessageLookupByLibrary.simpleMessage("更新のチェック"),
        "help_description": MessageLookupByLibrary.simpleMessage(
            "ここはFlixで、迅速で簡潔なマルチエンド相互転送ソフトウェアです。お好きになってください。😆"),
        "help_dev_team": MessageLookupByLibrary.simpleMessage("yuzh"),
        "help_donate": MessageLookupByLibrary.simpleMessage("❤️ 寄付によるサポート"),
        "help_donate_alipay": MessageLookupByLibrary.simpleMessage("アリペイ"),
        "help_donate_go": m4,
        "help_donate_title": MessageLookupByLibrary.simpleMessage("寄付する"),
        "help_donate_wechat": MessageLookupByLibrary.simpleMessage("ウィーチャット"),
        "help_finally": MessageLookupByLibrary.simpleMessage("最後に、あなたもできます"),
        "help_hello":
            MessageLookupByLibrary.simpleMessage("👋 こんにちは。よろしくお願いします。！"),
        "help_join_qq":
            MessageLookupByLibrary.simpleMessage("QQグループに参加して私たちと連絡してください~\n"),
        "help_latest_version":
            MessageLookupByLibrary.simpleMessage("最新バージョンです"),
        "help_new_version": m5,
        "help_q_1": MessageLookupByLibrary.simpleMessage("リストにデバイスが見つかりませんか？"),
        "help_q_2":
            MessageLookupByLibrary.simpleMessage("ファイルを転送するとトラフィックが消費されますか？"),
        "help_q_3":
            MessageLookupByLibrary.simpleMessage("Windows側でファイルを受信/送信できませんか？"),
        "help_q_4": MessageLookupByLibrary.simpleMessage(
            "PCがネットワークケーブルを使用しているときにファイルを受信/送信できませんか？"),
        "help_q_title": MessageLookupByLibrary.simpleMessage("接続について"),
        "help_qq_1": MessageLookupByLibrary.simpleMessage("ユーザQQ群1：\n"),
        "help_qq_2": MessageLookupByLibrary.simpleMessage("\nユーザQQ群2：\n"),
        "help_qq_3": MessageLookupByLibrary.simpleMessage("\nユーザQQ群3：\n"),
        "help_recommend": MessageLookupByLibrary.simpleMessage("👍 友人におすすめ"),
        "help_sponsor": MessageLookupByLibrary.simpleMessage("ポイント私は寄付ルートに入る"),
        "help_thanks":
            MessageLookupByLibrary.simpleMessage("ああ、継続的な開発をサポートしてくれてありがとう🙏"),
        "help_title": MessageLookupByLibrary.simpleMessage("ソフトウェアヘルプ"),
        "help_version": m6,
        "homepage_select_device":
            MessageLookupByLibrary.simpleMessage("デバイスを選択してください"),
        "hotspot_connect_failed":
            MessageLookupByLibrary.simpleMessage("ホットスポット接続に失敗しました"),
        "hotspot_connect_failed_action":
            MessageLookupByLibrary.simpleMessage("再試行"),
        "hotspot_connect_success":
            MessageLookupByLibrary.simpleMessage("ホットスポット接続成功"),
        "hotspot_connect_success_action":
            MessageLookupByLibrary.simpleMessage("リターントランスポート"),
        "hotspot_connecting":
            MessageLookupByLibrary.simpleMessage("ホットスポットを接続中"),
        "hotspot_disabled":
            MessageLookupByLibrary.simpleMessage("ホットスポットが閉じられました"),
        "hotspot_disabled_action":
            MessageLookupByLibrary.simpleMessage("再オープン"),
        "hotspot_enable_failed":
            MessageLookupByLibrary.simpleMessage("ホットスポットのオープンに失敗しました"),
        "hotspot_enable_failed_action":
            MessageLookupByLibrary.simpleMessage("再試行"),
        "hotspot_enable_failed_tip":
            MessageLookupByLibrary.simpleMessage("WiFiを再起動して再試行します。"),
        "hotspot_enabling":
            MessageLookupByLibrary.simpleMessage("ホットスポットをオンにしています"),
        "hotspot_get_ap_info_failed":
            MessageLookupByLibrary.simpleMessage("ホットスポット情報を取得できませんでした"),
        "hotspot_get_ap_info_failed_action":
            MessageLookupByLibrary.simpleMessage("再試行"),
        "hotspot_info_password":
            MessageLookupByLibrary.simpleMessage("ホットスポットパスワード："),
        "hotspot_info_ssid": MessageLookupByLibrary.simpleMessage("ホットスポット名："),
        "hotspot_initializing":
            MessageLookupByLibrary.simpleMessage("ホットスポットを初期化しています"),
        "hotspot_missing_permission":
            MessageLookupByLibrary.simpleMessage("必要な権限がありません"),
        "hotspot_missing_permission_action":
            MessageLookupByLibrary.simpleMessage("必要な権限を許可する"),
        "hotspot_my_qrcode": MessageLookupByLibrary.simpleMessage("マイQRコード"),
        "hotspot_qrcode_tip": MessageLookupByLibrary.simpleMessage(
            "Flixスイープを開き、ホットスポット接続を迅速に確立します。"),
        "hotspot_wifi_disabled":
            MessageLookupByLibrary.simpleMessage("WiFiがオープンしていません"),
        "hotspot_wifi_disabled_action":
            MessageLookupByLibrary.simpleMessage("オープン"),
        "hotspot_wifi_initializing":
            MessageLookupByLibrary.simpleMessage("WiFiを初期化しています"),
        "intro_last": MessageLookupByLibrary.simpleMessage("前へ"),
        "intro_next": MessageLookupByLibrary.simpleMessage("続ける"),
        "intro_permission_1":
            MessageLookupByLibrary.simpleMessage("Flixに必要な権限"),
        "intro_permission_2":
            MessageLookupByLibrary.simpleMessage("次の権限があります。"),
        "intro_permission_3a":
            MessageLookupByLibrary.simpleMessage("WIFIのオン/オフ"),
        "intro_permission_3b":
            MessageLookupByLibrary.simpleMessage("近くのデバイスをスキャン"),
        "intro_permission_4a": MessageLookupByLibrary.simpleMessage("ストレージ"),
        "intro_permission_4b":
            MessageLookupByLibrary.simpleMessage("受信したファイルを保存"),
        "intro_permission_5a": MessageLookupByLibrary.simpleMessage("通知"),
        "intro_permission_5b":
            MessageLookupByLibrary.simpleMessage("新しいファイル通知の受信"),
        "intro_permission_6a": MessageLookupByLibrary.simpleMessage("位置情報"),
        "intro_permission_6b":
            MessageLookupByLibrary.simpleMessage("ネットワーク名の取得"),
        "intro_permission_7a": MessageLookupByLibrary.simpleMessage("カメラ"),
        "intro_permission_7b":
            MessageLookupByLibrary.simpleMessage("QRコードをスキャン"),
        "intro_permission_8a":
            MessageLookupByLibrary.simpleMessage("読んで同意しました "),
        "intro_permission_8b": MessageLookupByLibrary.simpleMessage("利用規約"),
        "intro_permission_8c": MessageLookupByLibrary.simpleMessage(" と "),
        "intro_permission_8d":
            MessageLookupByLibrary.simpleMessage("プライバシーポリシー"),
        "intro_permission_9": MessageLookupByLibrary.simpleMessage("利用開始"),
        "intro_welcome_1":
            MessageLookupByLibrary.simpleMessage("チャットのようにファイルを渡す。"),
        "intro_welcome_2": MessageLookupByLibrary.simpleMessage("探索を始める"),
        "intro_wifi_1": MessageLookupByLibrary.simpleMessage("他のデバイスへの接続"),
        "intro_wifi_2": MessageLookupByLibrary.simpleMessage("デバイスを検出します。"),
        "menu_add_manually": MessageLookupByLibrary.simpleMessage("手動でデバイスを追加"),
        "menu_add_manually_input":
            MessageLookupByLibrary.simpleMessage("手動入力による追加"),
        "menu_add_this_device":
            MessageLookupByLibrary.simpleMessage("このデバイスを追加"),
        "menu_hotspot": MessageLookupByLibrary.simpleMessage("ホットスポット"),
        "menu_scan": MessageLookupByLibrary.simpleMessage("スキャン"),
        "navigation_config": MessageLookupByLibrary.simpleMessage("構成"),
        "navigation_help": MessageLookupByLibrary.simpleMessage("ヘルプ"),
        "navigation_send": MessageLookupByLibrary.simpleMessage("クロスオーバ"),
        "net_ap_close": MessageLookupByLibrary.simpleMessage("閉じる"),
        "net_info": MessageLookupByLibrary.simpleMessage("ネットワーク接続情報"),
        "net_toast_ap_close":
            MessageLookupByLibrary.simpleMessage("ホットスポットが閉じられました"),
        "paircode_add_IP": MessageLookupByLibrary.simpleMessage("IP"),
        "paircode_add_device": MessageLookupByLibrary.simpleMessage("デバイスの追加"),
        "paircode_add_failed":
            MessageLookupByLibrary.simpleMessage("追加に失敗しました"),
        "paircode_add_manually":
            MessageLookupByLibrary.simpleMessage("手動入力による追加"),
        "paircode_add_port": MessageLookupByLibrary.simpleMessage("ネットワークポート"),
        "paircode_add_success": MessageLookupByLibrary.simpleMessage("追加成功"),
        "paircode_dialog_add_device":
            MessageLookupByLibrary.simpleMessage("デバイスの追加"),
        "paircode_dialog_add_device_action":
            MessageLookupByLibrary.simpleMessage("再試行"),
        "paircode_dialog_adding_device":
            MessageLookupByLibrary.simpleMessage("デバイスを追加しています…"),
        "paircode_local_IP": MessageLookupByLibrary.simpleMessage("ネイティブIP"),
        "paircode_local_port":
            MessageLookupByLibrary.simpleMessage("ネイティブネットワークポート"),
        "paircode_scan_to_add":
            MessageLookupByLibrary.simpleMessage("Flixスキャン、本装置の追加"),
        "paircode_toast_config_incorrect":
            MessageLookupByLibrary.simpleMessage("IPまたはポートが正しくありません"),
        "permission_confirm": MessageLookupByLibrary.simpleMessage("確認"),
        "pick_one": MessageLookupByLibrary.simpleMessage("デバイスを選択"),
        "qr_no_camera_permission":
            MessageLookupByLibrary.simpleMessage("カメラ権限がありません"),
        "qr_scan": MessageLookupByLibrary.simpleMessage("スキャン"),
        "qr_scan_tip": MessageLookupByLibrary.simpleMessage(
            "Flix QRコードを開き、ホットスポット接続を迅速に確立します。"),
        "search": MessageLookupByLibrary.simpleMessage("検索"),
        "setting_accessibility":
            MessageLookupByLibrary.simpleMessage("アクセシビリティ"),
        "setting_accessibility_add_devices":
            MessageLookupByLibrary.simpleMessage("手動でデバイスを追加"),
        "setting_accessibility_add_devices_des":
            MessageLookupByLibrary.simpleMessage(
                "デバイスを手動で追加するための他のデバイス接続情報の入力"),
        "setting_accessibility_add_self":
            MessageLookupByLibrary.simpleMessage("このデバイスを追加"),
        "setting_accessibility_add_self_des":
            MessageLookupByLibrary.simpleMessage(
                "このデバイス接続情報を表示して、他のデバイスに手動で追加します"),
        "setting_advances": MessageLookupByLibrary.simpleMessage("アドバンス機能"),
        "setting_auto_start":
            MessageLookupByLibrary.simpleMessage("電源投入時に自動起動"),
        "setting_confirm_clean_cache":
            MessageLookupByLibrary.simpleMessage("キャッシュを消去"),
        "setting_confirm_clean_cache_action":
            MessageLookupByLibrary.simpleMessage("消去"),
        "setting_confirm_clean_cache_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "システムの制限により、送信されたファイルはキャッシュされ、キャッシュをクリアすると送信中のファイルが中断され、送信されたファイルの一部がプレビューできなくなります。キャッシュをクリアすると、受信したファイルに影響しません"),
        "setting_cross_device_clipboard":
            MessageLookupByLibrary.simpleMessage("デバイス間でコピー＆ペースト"),
        "setting_cross_device_clipboard_des":
            MessageLookupByLibrary.simpleMessage(
                "デバイスを関連付けた後、コピーされたテキストは共有できます"),
        "setting_cross_device_clipboard_other_devices":
            MessageLookupByLibrary.simpleMessage("現在のネットワークの下にある他の使用可能なデバイス："),
        "setting_cross_device_clipboard_paircode":
            MessageLookupByLibrary.simpleMessage("ネイティブ関連コードの表示"),
        "setting_cross_device_clipboard_paired_devices":
            MessageLookupByLibrary.simpleMessage("関連付けられたデバイス"),
        "setting_cross_device_clipboard_popup_input_paircode":
            MessageLookupByLibrary.simpleMessage("相互関係コードの入力"),
        "setting_cross_device_clipboard_popup_input_paircode_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "相手機器の4桁の数字を入力すると、クロスデバイスコピー貼り付けが開始されます。5分以内に有効です。"),
        "setting_cross_device_clipboard_popup_self_paircode":
            MessageLookupByLibrary.simpleMessage("ネイティブアソシエーションコード"),
        "setting_cross_device_clipboard_popup_self_paircode_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "相手があなたの関連コードを入力すれば、クロスデバイスコピー貼り付けを開くことができます。5分以内に有効です。"),
        "setting_cross_device_clipboard_tip":
            MessageLookupByLibrary.simpleMessage(
                "デバイスを関連付けた後、コピーされたテキストは共有できます"),
        "setting_cross_device_clipboard_too_low_to_pair":
            MessageLookupByLibrary.simpleMessage(
                "ターゲットデバイスのバージョンが低すぎてペアリングがサポートされていません"),
        "setting_device_name": MessageLookupByLibrary.simpleMessage("ネイティブ名"),
        "setting_exit": MessageLookupByLibrary.simpleMessage("アプリ終了"),
        "setting_more": MessageLookupByLibrary.simpleMessage("詳細"),
        "setting_more_clean_cache":
            MessageLookupByLibrary.simpleMessage("キャッシュを消去"),
        "setting_more_dark_mode":
            MessageLookupByLibrary.simpleMessage("ダークモード"),
        "setting_more_dark_mode_off":
            MessageLookupByLibrary.simpleMessage("常にオフ"),
        "setting_more_dark_mode_on":
            MessageLookupByLibrary.simpleMessage("常にオン"),
        "setting_more_dark_mode_sync":
            MessageLookupByLibrary.simpleMessage("システムに合わせる"),
        "setting_more_new_discover":
            MessageLookupByLibrary.simpleMessage("新しいデバイス検出方式を有効にする"),
        "setting_more_new_discover_des": MessageLookupByLibrary.simpleMessage(
            "オンにすると、ホットスポットを開いた後にデバイスを発見できない問題を解決できます。互換性の問題が発生したら、このスイッチをオフにしてフィードバックしてみてください❤️"),
        "setting_receive": MessageLookupByLibrary.simpleMessage("受信設定"),
        "setting_receive_auto": MessageLookupByLibrary.simpleMessage("自動受信"),
        "setting_receive_auto_des":
            MessageLookupByLibrary.simpleMessage("受信したファイルは自動的に保存されます"),
        "setting_receive_folder":
            MessageLookupByLibrary.simpleMessage("ファイル受信ディレクトリ"),
        "setting_receive_to_album":
            MessageLookupByLibrary.simpleMessage("写真ビデオを自動的にアルバムに保存"),
        "setting_receive_to_album_des":
            MessageLookupByLibrary.simpleMessage("受信ディレクトリに保存しない"),
        "setting_title": MessageLookupByLibrary.simpleMessage("アプリ設定"),
        "share_flix": MessageLookupByLibrary.simpleMessage("友人におすすめ"),
        "share_flix_action": MessageLookupByLibrary.simpleMessage("完了"),
        "share_flix_copied":
            MessageLookupByLibrary.simpleMessage("クリップボードにコピーされました"),
        "share_flix_website": MessageLookupByLibrary.simpleMessage(
            "公式サイト（クリックしてコピー）：flix.center"),
        "toast_copied":
            MessageLookupByLibrary.simpleMessage("クリップボードにコピーされました"),
        "toast_msg_empty_folder":
            MessageLookupByLibrary.simpleMessage("フォルダが空で、キャンセルを送信します"),
        "tray_menu_display": MessageLookupByLibrary.simpleMessage("表示"),
        "tray_menu_exit": MessageLookupByLibrary.simpleMessage("終了"),
        "tray_menu_hide": MessageLookupByLibrary.simpleMessage("非表示"),
        "widget_delete_msg_history":
            MessageLookupByLibrary.simpleMessage("メッセージ・ログの削除"),
        "widget_delete_msg_history_action":
            MessageLookupByLibrary.simpleMessage("削除"),
        "widget_delete_msg_history_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "ファイルが転送中の場合、削除メッセージは転送を中断します"),
        "widget_multiple_delete": MessageLookupByLibrary.simpleMessage("削除"),
        "widget_toast_prepare_sending":
            MessageLookupByLibrary.simpleMessage("送信準備中です、お待ちください"),
        "widget_verification_action": MessageLookupByLibrary.simpleMessage("完了")
      };
}
