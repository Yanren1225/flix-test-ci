import 'package:flix/model/notification/reception_notification.dart';

class BadgeService {
  BadgeService._privateConstructor();

  static final _instance = BadgeService._privateConstructor();

  static BadgeService get instance => _instance;

  var badges = <String, int>{};
  final onBadgesChanged = <OnBadgesChanged>[];


  void addBadge(MessageNotification notification) {
    final from = notification.from;
    badges[from] = (badges[from] ?? 0) + 1;
    notifyBadgesChanged();
  }

  void clearBadgesFrom(String from) {
    badges.remove(from);
    notifyBadgesChanged();
  }

  void notifyBadgesChanged() {
    for (var listener in onBadgesChanged) {
      listener(badges);
    }
  }

  void addOnBadgesChangedListener(OnBadgesChanged listener) {
    onBadgesChanged.add(listener);
  }

  void removeOnBadgeChangedListener(OnBadgesChanged listener) {
    onBadgesChanged.remove(listener);
  }
}

typedef OnBadgesChanged = void Function(Map<String, int> badges);
