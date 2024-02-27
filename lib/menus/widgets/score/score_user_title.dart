import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/domain/entities/z1track.dart';

class ScoreUserTitle extends StatelessWidget {
  final Z1Track currentTrack;
  const ScoreUserTitle({
    required this.currentTrack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bodyMedium = textTheme.bodyMedium
        ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold);
    final numLaps = AppLocalizations.of(context)!
        .numLaps
        .replaceAll('%%LAPS%%', currentTrack.numLaps.toString());
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '${currentTrack.name} ($numLaps)',
        style: bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
