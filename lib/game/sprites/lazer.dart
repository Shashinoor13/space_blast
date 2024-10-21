import 'dart:async';

import 'package:flame/components.dart';
import 'package:runner/game/game.dart';

class Lazer extends SpriteAnimationComponent
    with HasGameReference<RunningGame> {
  final String spritePath = "lazer.png";
  final int noOfImages = 4;
  final double textureHeight = 8;
  final double textureWidth = 12;

  @override
  FutureOr<void> onLoad() async {
    animation = await game.loadSpriteAnimation(
      "lazerS.png",
      SpriteAnimationData.sequenced(
        amount: noOfImages,
        stepTime: 0.2,
        textureSize: Vector2(63, 30),
      ),
    );
  }

  @override
  bool get debugMode => true;
}
