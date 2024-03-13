import 'package:talker/talker.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    /// You can enable/disable all talker processes with this field
    enabled: true,
    /// You can enable/disable saving logs data in history
    useHistory: true,
    /// Length of history that saving logs data
    maxHistoryItems: 100,
    /// You can enable/disable console logs
    useConsoleLogs: true,
  ),
  /// Setup your implementation of logger
  logger: TalkerLogger(),
  ///etc...
);

void aa() {

}

// /// Jsut logs
// talker.warning('The pizza is over 😥');
// talker.debug('Thinking about order new one 🤔');
//
// // Handling Exception's and Error's
// try {
// throw Exception('The restaurant is closed ❌');
// } catch (e, st) {
// talker.handle(e, st);
// }
//
// /// Jsut logs
// talker.info('Ordering from other restaurant...');
// talker.info('Payment started...');
// talker.good('Payment completed. Waiting for pizza 🍕');