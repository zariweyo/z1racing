import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';

class AlertUpdateForced extends StatelessWidget {
  const AlertUpdateForced({super.key});

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
        AppLocalizations.of(context)!.update.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_alpha.png',
              height: 100,
              fit: BoxFit.contain,
            ),
            Text(
              AppLocalizations.of(context)!.updateNeeded,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            _linkUpdate(context),
          ],
        ),
      ),
    );
  }
}
