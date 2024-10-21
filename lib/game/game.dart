import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:runner/game/world.dart';

enum GameState { start, playing, over }

class RunningGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  RunningGame() : super(world: RunningGameWorld());
  GameState state = GameState.start;

  //is issues occours set halve the values
  static const double characterheight = 132;
  static const double characterwidth = 60;

  static const double movementSpeed = 250;
  static Vector2 bulletSize = Vector2(16, 24);

  @override
  void onLoad() async {
    final parallax = await loadParallaxComponent(
      [
        // ParallaxImageData('repeat.png'),
        ParallaxImageData('stars_1.png'),
        ParallaxImageData('stars_0.png'),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 8),
    );
    add(parallax);
  }
}
