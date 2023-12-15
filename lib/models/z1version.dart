import 'package:package_info_plus/package_info_plus.dart';

enum Z1VersionState { none, updateAvailable, updateForced }

class Z1Version {
  final String last;
  final String forced;
  final String android;
  final String ios;

  Z1Version(
      {this.last = '0.0.0',
      this.forced = '0.0.0',
      this.android = '',
      this.ios = '',});

  factory Z1Version.fromMap(Map<String, dynamic> map) {
    return Z1Version(
      last: map['last']?.toString() ?? '',
      forced: map['forced']?.toString() ?? '',
      android: map['android']?.toString() ?? '',
      ios: map['ios']?.toString() ?? '',
    );
  }

  Z1VersionState check(PackageInfo pInfo) {
    final localVersion = pInfo.version;
    if (localVersion.compareTo(forced) < 0) {
      return Z1VersionState.updateForced;
    }
    if (localVersion.compareTo(last) < 0) {
      return Z1VersionState.updateAvailable;
    }

    return Z1VersionState.none;
  }
}
