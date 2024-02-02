import 'package:flutter/material.dart';
import 'package:z1racing/base/components/duration_widget.dart';
import 'package:z1racing/models/z1user_race.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';

class ScoreUserRow extends StatelessWidget {
  final int position;
  final Z1UserRace race;

  const ScoreUserRow({required this.position, required this.race, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorAvatar = FirebaseFirestoreRepository.instance.avatarColor;
    var color = colorAvatar[50];
    if (FirebaseFirestoreRepository.instance.currentUser?.uid == race.uid) {
      color = colorAvatar[200];
    }
    final bodyMedium =
        textTheme.bodyMedium?.copyWith(fontSize: 12, color: color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(1),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color ?? Colors.white70,
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Text(
              position.toString(),
              style: bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            race.metadata.displayName,
            style: bodyMedium?.copyWith(fontSize: 16),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          flex: 3,
          child: DurationWidget(
            duration: race.time,
            color: color,
            size: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          flex: 3,
          child: DurationWidget(
            duration: race.bestLapTime,
            color: color,
            size: 28,
          ),
        ),
      ],
    );
  }
}
