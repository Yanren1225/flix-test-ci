import 'package:flix/domain/dev/flags.dart';

var defaultPort = FlagRepo.instance.defaultPort.value;

/// The default multicast group should be 224.0.0.0/24
/// because on some Android devices this is the only IP range
/// that can receive UDP multicast messages.
var defaultMulticastGroup = FlagRepo.instance.multicastGroup.value;
var defaultMulticastPort = FlagRepo.instance.multicastPort.value;
