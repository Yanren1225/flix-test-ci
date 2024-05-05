
import 'package:dart_mappable/dart_mappable.dart';

part 'ship_command.mapper.dart';


@MappableClass()
class ShipCommand with ShipCommandMappable {
  final String command;
  final dynamic? data;

  ShipCommand(this.command, [this.data]);

  static const fromJson = ShipCommandMapper.fromJson;
}