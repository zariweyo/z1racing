extension StringExtension on String {
  String toLimitHash(int limit) {
    if (length == limit) {
      return this;
    }

    if (length > limit) {
      return substring(0, limit);
    }

    return List.generate(limit - length, (index) => '0').join() + this;
  }
}
