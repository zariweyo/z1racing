import 'package:z1racing/game/car/components/car.dart';

class PlayerCar extends Car {
  PlayerCar({
    required super.images,
    required super.avatar,
    required super.startPosition,
    super.cameraComponent,
    super.controlsData,
    super.pressedKeys,
  }) : super(startAngle: 0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    cameraComponent?.follow(this);

    selectVia(viasSelected: []);
  }
}
