import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScoreUserColumnsTitle extends StatelessWidget {
  const ScoreUserColumnsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bodyMedium =
        textTheme.bodyMedium?.copyWith(fontSize: 12, color: Colors.white);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(),
        ),
        Expanded(
          flex: 5,
          child: Text(
            AppLocalizations.of(context)!.name.toUpperCase(),
            style: bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            AppLocalizations.of(context)!.time.toUpperCase(),
            style: bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            AppLocalizations.of(context)!.fastLap.toUpperCase(),
            style: bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
