import 'package:androp/model/shareable.dart';
import 'package:androp/presentation/share_concerto_screen.dart';

class BubbleEntity {
  String from;
  String to;
  Shareable shareable;

  BubbleEntity({required this.from, required this.to, required this.shareable});
}
