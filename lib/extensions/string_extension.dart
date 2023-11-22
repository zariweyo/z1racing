extension StringExtension on String {
  String toLimitHash(int limit) {
    if (this.length == limit) {
      return this;
    }

    if (this.length > limit) {
      return this.substring(0, limit);
    }

    return List.generate(limit - this.length, (index) => "0").join() + this;
  }
}
