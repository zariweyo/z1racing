import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/domain/repositories/firebase_auth_repository.dart';

class SettingsVersion extends StatelessWidget {
  const SettingsVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final version = FirebaseAuthRepository.instance.packageInfo.version;
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        AppLocalizations.of(context)!
            .version
            .replaceAll('%%VERSION%%', version),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white38),
        textAlign: TextAlign.center,
      ),
    );
  }
}
