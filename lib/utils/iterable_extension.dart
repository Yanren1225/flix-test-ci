extension IterableExtension<E> on Iterable<E> {
  E? find(bool Function(E element) match) {
    for (final element in this) {
      if (match(element)) return element;
    }
    return null;
  }
}
