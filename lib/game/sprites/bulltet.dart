import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:runner/game/game.dart';
import 'package:runner/utils/sprite.dart';

class Bullet extends PositionComponent
    with HasGameRef<RunningGame>, CollisionCallbacks {
  Vector2 bulletSpritePosition = Vector2(552, 312);
  Vector2 bulletSpriteSize = Vector2(108, 144);

  late Sprite bulletSprite;
  late RectangleHitbox hitbox;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    hitbox = RectangleHitbox(
      size: RunningGame.bulletSize,
    )
      ..position = Vector2(0, 0)
      ..renderShape = false;

    add(hitbox);
    // FlameAudio.play("bullet.mp3", volume: 0.3);
    bulletSprite = loadSprite(
      path: "bullet.png",
      position: bulletSpritePosition,
      size: bulletSpriteSize,
    );
  }

  @override
  void render(Canvas canvas) {
    // print("Bullet Position: $position");
    if (game.state == GameState.over) return;
    bulletSprite.render(
      canvas,
      position: Vector2(0, -size.y / 2),
      size: RunningGame.bulletSize,
      anchor: Anchor.bottomCenter,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 300 * dt;
    if (position.y < -RunningGame.characterheight * 10) {
      removeFromParent();
    }
  }

  @override
  bool get debugMode => false;
}
