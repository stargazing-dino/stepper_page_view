Iterable<T> intersperseIndexed<T>(
  T Function(int index) elementBuilder,
  Iterable<T> iterable,
) sync* {
  final iterator = iterable.iterator;
  var index = 0;

  if (iterator.moveNext()) {
    yield iterator.current;
    index++;
    // 1, 3
    while (iterator.moveNext()) {
      yield elementBuilder(index);
      yield iterator.current;
      index += 2;
    }
  }
}

const _intersperseIndexed = intersperseIndexed;

extension ListExtension<T> on Iterable<T> {
  Iterable<T> intersperseIndexed(T Function(int index) builder) {
    return _intersperseIndexed(builder, this);
  }
}
