import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:z1racing/domain/entities/object/object_model.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/domain/entities/z1user.dart';

class Z1Track {
  final String trackId;
  final String name;
  final int numLaps;
  final List<SlotModel> slots;
  final int version;
  final int season;
  final int chapter;
  final bool enabled;
  final List<ObjectModel> objects;
  final Z1TrackSettings settings;
  final List<Z1TrackIACar> iaCars;

  String get id => '${trackId}_$numLaps';

  Z1Track({
    required this.trackId,
    required this.name,
    required this.numLaps,
    required this.slots,
    required this.season,
    required this.chapter,
    required this.enabled,
    required this.version,
    required this.objects,
    required this.settings,
    required this.iaCars,
  });

  Z1Track copyWith({
    String? trackId,
    String? name,
    int? numLaps,
    List<SlotModel>? slots,
    int? season,
    int? chapter,
    bool? enabled,
    int? version,
    List<ObjectModel>? objects,
    Z1TrackSettings? settings,
    List<Z1TrackIACar>? iaCars,
  }) {
    return Z1Track(
      trackId: trackId ?? this.trackId,
      name: name ?? this.name,
      numLaps: numLaps ?? this.numLaps,
      slots: slots ?? this.slots,
      season: season ?? this.season,
      chapter: chapter ?? this.chapter,
      enabled: enabled ?? this.enabled,
      version: version ?? this.version,
      objects: objects ?? this.objects,
      settings: settings ?? this.settings,
      iaCars: iaCars ?? this.iaCars,
    );
  }

  factory Z1Track.fromMap(Map<String, dynamic> map) {
    return Z1Track(
      trackId: map['trackId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      numLaps: int.tryParse(map['numLaps']?.toString() ?? '') ?? 0,
      season: int.tryParse(map['season']?.toString() ?? '') ?? 0,
      chapter: int.tryParse(map['chapter']?.toString() ?? '') ?? 0,
      enabled: bool.tryParse(map['enabled']?.toString() ?? '') ?? true,
      slots: map['slots'] != null
          ? (map['slots'] as List<dynamic>)
              .map<SlotModel>(SlotModel.fromMap)
              .toList()
          : [],
      version: int.tryParse(map['version']?.toString() ?? '') ?? 0,
      objects: map['objects'] != null
          ? (map['objects'] as List<dynamic>)
              .map<ObjectModel>(ObjectModel.fromMap)
              .toList()
          : [],
      settings: map['settings'] != null
          ? Z1TrackSettings.fromMap(map['settings'] as Map<String, dynamic>)
          : Z1TrackSettings.zero(),
      iaCars: map['iaCars'] != null
          ? (map['iaCars'] as List<dynamic>)
              .map<Z1TrackIACar>(Z1TrackIACar.fromMap)
              .toList()
          : [],
    );
  }

  factory Z1Track.empty() {
    return Z1Track(
      trackId: '',
      name: '',
      numLaps: 0,
      enabled: false,
      slots: [],
      season: 0,
      chapter: 0,
      version: 0,
      objects: [],
      settings: Z1TrackSettings.zero(),
      iaCars: [],
    );
  }

  bool get isActive => enabled;

  bool get isEmpty => trackId == '';

  List<Vector2> get points =>
      slots.map((slot) => slot.points1).flattened.toList();

  double get width => maxX - minX;
  double get height => maxY - minY;

  double get minX => points.map((e) => e.x).min;
  double get maxX => points.map((e) => e.x).max;
  double get minY => points.map((e) => e.y).min;
  double get maxY => points.map((e) => e.y).max;
  Rect get rect => Rect.fromLTRB(minX, minY, maxX, maxY);

  int get distance => slots
      .map((e) => e.lenght)
      .reduce((value, element) => value + element)
      .toInt();

  /* dynamic toJson() {
    return {
      "trackId": trackId,
      "name": name,
      "slots": slots.map((e) => e.toJson()).toList()
    };
  } */
}

class Z1TrackSettings {
  final double slide;
  final double dark;
  final double rain;

  Z1TrackSettings({
    required this.slide,
    required this.dark,
    required this.rain,
  });

  factory Z1TrackSettings.fromMap(Map<String, dynamic> map) {
    return Z1TrackSettings(
      slide: double.tryParse(map['slide']?.toString() ?? '') ?? 0,
      dark: double.tryParse(map['dark']?.toString() ?? '') ?? 0,
      rain: double.tryParse(map['rain']?.toString() ?? '') ?? 0,
    );
  }

  factory Z1TrackSettings.zero() {
    return Z1TrackSettings(
      slide: 0,
      dark: 0,
      rain: 0,
    );
  }
}

class Z1TrackIACar {
  final int via;
  final double speed;
  final double delay;
  final Z1UserAvatar avatar;
  Z1TrackIACar({
    required this.via,
    required this.speed,
    required this.delay,
    required this.avatar,
  });

  factory Z1TrackIACar.fromMap(dynamic mapDyn) {
    final map = mapDyn as Map<String, dynamic>;
    return Z1TrackIACar(
      via: int.tryParse(map['via']?.toString() ?? '') ?? 0,
      speed: double.tryParse(map['speed']?.toString() ?? '') ?? 0,
      delay: double.tryParse(map['delay']?.toString() ?? '') ?? 0,
      avatar: Z1UserAvatar.values.firstWhereOrNull(
            (element) => element.name == (map['avatar'] ?? ''),
          ) ??
          Z1UserAvatar.boy_1,
    );
  }
}
