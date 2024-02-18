import 'dart:math';

extension DoubleExtension on double {
  double truncateDecimals(int decimals) {
    final num = pow(10, decimals);
    return (this * num).truncate() / num;
  }
}
