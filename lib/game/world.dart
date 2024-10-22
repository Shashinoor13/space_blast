import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/text.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:runner/game/game.dart';
import 'package:runner/game/sprites/aestroid.dart';
import 'package:runner/game/sprites/lazer.dart';
import 'package:runner/game/sprites/player.dart';
import 'package:runner/utils/sprite.dart';

class RunningGameWorld extends World
    with HasGameReference<RunningGame>, TapCallbacks {
  late final Player player;
  late TextComponent healthText;
  late TextComponent scoreText;
  late SpawnComponent aestroids;
  late CameraComponent camera;
  late Sprite gameOverSprite;
  late Sprite titleSprite;
  late Sprite controlsSprite;

  Timer interval = Timer(0.5, repeat: true);

  @override
  FutureOr<void> onLoad() async {
    Flame.device.fullScreen();
    Flame.device.setLandscape();

    await Flame.images.loadAll([
      "rocket.png",
      "space-bg.jpg",
      "bullet.png",
      "aestroids.png",
      "repeat.png",
      "GAME_OVER.png",
      "SPACE_BLAST.png",
      "controls.png",
      "lazer.png",
      "lazerS.png",
    ]);

    await FlameAudio.audioCache.loadAll([
      "background.mp3",
      "bullet.mp3",
      "whoosh.mp3",
      "TheJourney.mp3",
      "blast.mp3",
    ]);

    FlameAudio.bgm.initialize();
    player = Player()
      ..anchor = Anchor.center
      ..position = Vector2(0, 0)
      ..size = Vector2(RunningGame.characterwidth, RunningGame.characterheight);
    add(player);
    FlameAudio.bgm.play("TheJourney.mp3", volume: 0.5);
    camera = CameraComponent.withFixedResolution(
        width: RunningGame.characterwidth * 2 * 10,
        height: RunningGame.characterheight * 10);
    camera.viewfinder.position = Vector2(0, 0);
    camera.viewfinder.anchor = Anchor.topCenter;
    camera.viewfinder.zoom = 3;
    camera.follow(player);
    final textPaint = TextPaint(
        style: const TextStyle(
      fontFamily: "Minecraft",
      color: Color(0xffffffff),
      fontSize: 20,
    ));
    healthText = TextComponent(
      text: "Player Health: ${player.health}",
      textRenderer: textPaint,
      position: Vector2(
        -(game.size.x / 2) + 10,
        -(game.size.y / 2) + 10,
      ),
    );
    scoreText = TextComponent(
      text: "Score: ${player.score}",
      textRenderer: textPaint,
      position: Vector2(
        -(game.size.x / 2) + 10,
        -(game.size.y / 2) + 30,
      ),
    )..priority = 10;

    aestroids = SpawnComponent.periodRange(
        factory: (index) {
          return Aestroid.fromIndex(index % 6)
            ..position = Vector2(0, 0)
            ..size = Vector2(50, 50);
        },
        minPeriod: 0.1,
        maxPeriod: 0.5,
        spawnWhenLoaded: true,
        area:
            Rectangle.fromLTWH(-game.size.x, -game.size.y, 2 * game.size.x, 40))
      ..priority = 20
      ..debugMode = true;

    gameOverSprite = loadSprite(
        path: "GAME_OVER.png", position: Vector2(0, 0), size: Vector2(350, 49));
    titleSprite = loadSprite(
        path: "SPACE_BLAST.png",
        position: Vector2(0, 0),
        size: Vector2(389, 49));
    controlsSprite = loadSprite(
        path: "controls.png",
        position: Vector2(0, 28),
        size: Vector2(875, 243));

    if (game.state == GameState.over) {
      remove(aestroids);
      remove(healthText);
      remove(scoreText);
    }

    if (game.state == GameState.playing) {
      add(aestroids);
      add(camera);
      add(healthText);
      add(scoreText);
      add(FpsComponent());
      camera.viewfinder.zoom = 1;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
    healthText.text = "Player Health: ${player.health}";
    scoreText.text = "Score :${player.score}";

    if (game.state == GameState.start) {
      add(SpriteComponent(
          sprite: titleSprite,
          position: Vector2(0, -300),
          anchor: Anchor.center));
      add(SpriteComponent(
          sprite: controlsSprite,
          scale: Vector2(.3, 0.3),
          position: Vector2(0, -200),
          anchor: Anchor.center));
    }

    if (player.health <= 0) {
      player.add(MoveToEffect(Vector2(0, 0), EffectController(duration: 1)));
      add(SpriteComponent(
        sprite: gameOverSprite,
        position: Vector2(-175, -300),
      ));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (game.state == GameState.playing) return;
    player.health = 100;
    player.playerScore = 0;
    player.add(
      MoveToEffect(Vector2(0, 0), EffectController(duration: 2)),
    );
    game.state = GameState.playing;
    game.world = RunningGameWorld();
  }
}
