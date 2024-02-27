import 'package:flame/components.dart';
import 'package:z1racing/domain/entities/slot/slot_model.dart';
import 'package:z1racing/game/car/components/car.dart';
import 'package:z1racing/game/controls/models/jcontrols_data.dart';

class IACar extends Car {
  IACar({
    required Vector2 startPosition,
    required this.velocity,
    required this.startVia,
    required super.images,
    required super.avatar,
    required super.delay,
  }) : super(
          startPosition: startPosition.translated((startVia - 3) * 5, 0),
          startAngle: 0,
          pressedKeys: {},
          controlsData: ControlsData.zero(),
          startLevel: SlotModelLevel.floor,
        );

  final int startVia;
  final double velocity;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    selectVia(viasSelected: [startVia]);
  }

  @override
  void update(double dt) {
    controlsData!.updateDelta(Vector2(0, -velocity));
    super.update(dt);
  }
}
