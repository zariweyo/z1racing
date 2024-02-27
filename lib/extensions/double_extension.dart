import 'dart:math';

extension DoubleExtension on double {
  double truncateDecimals(int decimals) {
    final num = pow(10, decimals);
    return (this * num).truncate() / num;
  }

  double normalizeAngle() {
    // [0, 2*PI]
    var angleRang = this % pi;
    if (angleRang < 0) {
      angleRang += pi;
    }
    return angleRang;
  }

  double normalizeAngleNegative() {
    // [-PI, PI]
    var angleRang = this % pi;
    if (angleRang < -pi) {
      angleRang += pi;
    } else if (angleRang > pi) {
      angleRang -= pi;
    }
    return angleRang;
  }

  double toAngle() {
    return (this * 180 / pi) % 360;
  }

  double subAngle(double otherAngle) {
    final diff = this - otherAngle;
    if (diff > 180) {
      return diff - 360;
    }
    if (diff < -180) {
      return diff + 360;
    }

    return diff;
  }
}
