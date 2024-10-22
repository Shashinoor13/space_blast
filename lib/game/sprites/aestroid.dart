import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:runner/game/game.dart';
import 'package:runner/game/sprites/bulltet.dart';
import 'package:runner/game/sprites/player.dart';
import 'package:runner/utils/sprite.dart';

class Aestroid extends PositionComponent
    with HasGameReference<RunningGame>, CollisionCallbacks {
  final Sprite sprite;
  final rotationDirection = Random().nextBool() ? 1 : -1;
  final rotationSpeed = Random().nextDouble() * 2 + 1;

  // Base speed of the asteroid
  final double baseSpeed = Random().nextDouble() * 50 + 250;
  final double maxSpeed = 500;

  // This will be used to increase speed over time
  double currentSpeed;

  // Speed increment per second
  static final double _incrementPerSecond = 10.0;

  late ShapeHitbox hitbox;

  // Array of asteroid positions and sizes (can expand this if needed)
  static final List<List<Vector2>> asteroidData = [
    [Vector2(17, 27), Vector2(90, 83)],
    [Vector2(132, 24), Vector2(99, 88)],
    [Vector2(270, 21), Vector2(84, 94)],
    [Vector2(383, 25), Vector2(98, 88)],
    [Vector2(5, 147), Vector2(104, 94)],
    [Vector2(132, 138), Vector2(97, 107)],
    [Vector2(247, 135), Vector2(124, 111)],
    [Vector2(385, 140), Vector2(100, 104)],
  ];

  Aestroid(Vector2 positionOnPng, Vector2 sizeOnPng)
      : sprite = loadSprite(
            path: "aestroids.png", position: positionOnPng, size: sizeOnPng),
        currentSpeed = Random().nextDouble() * 50 + 100 + _incrementPerSecond;

  // Factory constructor to create Aestroid based on an index
  factory Aestroid.fromIndex(int index) {
    assert(index >= 0 && index < asteroidData.length);
    return Aestroid(asteroidData[index][0], asteroidData[index][1]);
  }

  @override
  void render(Canvas canvas) {
    if (game.state == GameState.over) return;
    sprite.render(
      canvas,
      size: Vector2(50, 50),
    );
  }

  @override
  Future<void> onLoad() async {
    hitbox = RectangleHitbox();
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Increase the asteroid's speed over time
    currentSpeed += _incrementPerSecond * dt;

    if (currentSpeed > maxSpeed) {
      currentSpeed = maxSpeed;
    }
    // Move the asteroid
    position.y += currentSpeed * dt;
    angle += rotationDirection * rotationSpeed * dt;
    anchor = Anchor.center;

    // Check if the asteroid goes off the screen and remove it
    if (!game.camera.canSee(this) && position.y > 0) {
      removeFromParent();
    }

    if (position.y > RunningGame.characterheight * 15) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, other) {
    super.onCollision(intersectionPoints, other);

    if (!game.camera.canSee(this)) {
      return;
    }

    if (other is Bullet) {
      if (game.state != GameState.playing) return;
      removeFromParent();
      other.removeFromParent();
      Player().playerScore += 10;
    }
    if (other is Player) {
      if (game.state == GameState.playing) removeFromParent();
    }
  }

  @override
  void onCollisionEnd(other) {
    super.onCollisionEnd(other);

    if (game.camera.canSee(this)) return;

    FlameAudio.play("blast.mp3");
  }

  @override
  bool get debugMode => false;
}
