
import 'package:dart_mappable/dart_mappable.dart';

part 'isolate_command.mapper.dart';


@MappableClass()
class IsolateCommand with IsolateCommandMappable {
  final String command;
  final dynamic? data;

  IsolateCommand(this.command, [this.data]);

  static const fromJson = IsolateCommandMapper.fromJson;
}