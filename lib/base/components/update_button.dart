import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';

class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key});

  Widget _linkUpdate(BuildContext context) {
    final z1Version = FirebaseFirestoreRepository.instance.z1version;
    return ElevatedButton(
      onPressed: () {
        var url = '';
        if (Platform.isAndroid) {
          url = z1Version.android;
        } else if (Platform.isIOS) {
          url = z1Version.ios;
        }

        if (url.isNotEmpty) {
          launchUrl(Uri.parse(url));
        }
      },
      child: Text(
        AppLocalizations.of(context)!.updateAvailable,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseFirestoreRepository.instance.z1version
            .check(FirebaseAuthRepository.instance.packageInfo) ==
        Z1VersionState.updateAvailable) {
      return _linkUpdate(context);
    }

    return Container();
  }
}
