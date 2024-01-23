abstract class Shareable<C> {
  String get id;
  C get content;
}

class SharedText extends Shareable<String> {
  @override
  final String content;

  @override
  final String id;

  SharedText({required this.id, required this.content});
}

class SharedImage extends Shareable<String> {
  /// image uri
  @override
  final String content;

  @override
  final String id;

  SharedImage({required this.id, required this.content});
}

class SharedVideo extends Shareable<String> {
  /// video uri
  @override
  final String content;

  @override
  final String id;

  SharedVideo({required this.id, required this.content});
}
