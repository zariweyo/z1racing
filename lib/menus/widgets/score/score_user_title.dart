import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/models/z1track.dart';
import 'package:z1racing/repositories/track_repository_impl.dart';

class ScoreUserTitle extends StatelessWidget {
  final Z1Track currentTrack;
  final Function(TrackRequestDirection)? changeTrack;
  const ScoreUserTitle({
    required this.currentTrack,
    this.changeTrack,
    super.key,
  });

  Widget button2({
    required BuildContext context,
    required IconData iconData,
    Function()? onPressed,
  }) {
    return ButtonActions(
      onTap: onPressed,
      child: Icon(
        iconData,
        color: Colors.pink.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bodyMedium = textTheme.bodyMedium
        ?.copyWith(fontSize: 14, fontWeight: FontWeight.bold);
    final numLaps = AppLocalizations.of(context)!
        .numLaps
        .replaceAll('%%LAPS%%', currentTrack.numLaps.toString());
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Flexible(
            child: button2(
              context: context,
              onPressed: () =>
                  changeTrack?.call(TrackRequestDirection.previous),
              iconData: Icons.fast_rewind,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${currentTrack.name} ($numLaps)',
              style: bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: button2(
              context: context,
              onPressed: () => changeTrack?.call(TrackRequestDirection.next),
              iconData: Icons.fast_forward,
            ),
          ),
        ],
      ),
    );
  }
}
