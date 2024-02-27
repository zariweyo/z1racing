import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class RaindropParticle extends CircleComponent {
  final double speed;
  final Vector2 centerPoint;
  RaindropParticle({required this.speed, required this.centerPoint})
      : super(
          radius: 1.0, // Tamaño de la gota de lluvia
          paint: Paint()..color = Colors.white70, // Color de la gota de lluvia
        );

  @override
  void update(double dt) {
    super.update(dt);
    final diff = position - centerPoint;
    position.add(
      Vector2(
        -diff.x * dt * speed,
        -diff.y * dt * speed,
      ),
    ); // Mueve la gota hacia abajo
    if (diff.length < 50) {
      removeFromParent(); // Elimina la gota cuando sale de la pantalla
    }
  }
}

class RainEffect extends Component with HasGameRef<FlameGame> {
  final double speed;

  final Random _random = Random();
  double _timer = 0.0;

  RainEffect({
    required this.speed,
    super.children,
    super.priority,
    super.key,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= 0.01) {
      // Ajusta para controlar la densidad de la lluvia
      _timer = 0.0;
      final raindrop = RaindropParticle(
        centerPoint: gameRef.size / 2,
        speed: speed,
      )..position = Vector2(
          _random.nextDouble() * gameRef.size.x,
          _random.nextDouble() * gameRef.size.y,
        );
      gameRef.add(raindrop);
    }
  }
}
