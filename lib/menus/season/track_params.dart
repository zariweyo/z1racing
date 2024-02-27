import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:z1racing/domain/entities/z1track.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';

class TrackParams extends StatelessWidget {
  final Z1Track track;
  final double scale;

  const TrackParams({required this.track, this.scale = 1, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (track.numLaps > 1)
          param(
            iconData: Icons.repeat,
            value: track.numLaps.toString(),
          ),
        param(
          iconData: Icons.straighten,
          value: '${(track.distance / 1000).toStringAsFixed(1)} km',
        ),
        if (track.settings.dark > 0)
          param(
            iconData: Icons.dark_mode,
            value: '',
          ),
        if (track.settings.rain > 0)
          param(
            iconData: Icons.cloudy_snowing,
            value: '',
          ),
      ],
    );
  }

  Widget param({required IconData iconData, required String value}) =>
      Container(
        height: 40 * scale,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Icon(
                iconData,
                size: 24 * scale,
                color: FirebaseFirestoreRepository.instance.avatarColor
                    .brighten(0.3),
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 12 * scale),
            ),
          ],
        ),
      );
}
