import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:runner/game/game.dart';
import 'package:runner/game/sprites/aestroid.dart';
import 'package:runner/game/sprites/bulltet.dart';
import 'package:runner/game/sprites/lazer.dart';
import 'package:runner/game/world.dart';

enum PlayerState { idle, run }

enum PlayerDirection {
  left,
  right,
  up,
  down,
  leftUp,
  leftDown,
  rightUp,
  rightDown,
}

class Player extends SpriteAnimationComponent
    with
        KeyboardHandler,
        DragCallbacks,
        HasGameReference<RunningGame>,
        CollisionCallbacks {
  PlayerState state = PlayerState.idle;
  PlayerDirection? currentDirection;
  final double speed = RunningGame.movementSpeed;
  bool _isDragging = false;
  late final SpawnComponent _bulletSpawner;
  late ShapeHitbox hitbox_1;
  late ShapeHitbox hitbox_2;
  bool _canPlaySwooshSound = false;
  double _lastPlayedTimeStamp = 0;
  double bulletGenerationSpeed = 0.4;
  double playerHealth = 100;
  int score = 0;

  double get health => playerHealth;
  set health(double value) {
    playerHealth = value;
  }

  int get playerScore => score;

  set playerScore(int value) {
    score = value;
  }

  Player._();
  static final Player _instance = Player._();

  factory Player() {
    return _instance;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = const Color(0xff00ff00);
    hitbox_1 = RectangleHitbox(
      size: Vector2(20, RunningGame.characterheight - 50),
    )
      ..position = Vector2(RunningGame.characterwidth / 2 - 10, 0)
      ..renderShape = false
      ..paint = paint;
    priority = 120;
    hitbox_2 = RectangleHitbox(
      size: Vector2(RunningGame.characterwidth, 20),
    )
      ..position = Vector2(0, RunningGame.characterheight / 2 - 10)
      ..renderShape = false
      ..paint = paint;
    add(hitbox_1);
    add(hitbox_2);
    animation = await game.loadSpriteAnimation(
      "rocket.png",
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2(32, 48),
      ),
    );
    _bulletSpawner = SpawnComponent(
      period: bulletGenerationSpeed,
      selfPositioning: true,
      factory: (index) => Bullet()
        ..size = RunningGame.bulletSize
        ..position = position.clone(),
      // ..x += RunningGame.characterwidth / 2 -
      //     RunningGame.bulletSize.x /
      //         2, // Bullet position should be the same as player position
      autoStart: true,
    );
    FlameAudio.play("whoosh.mp3", volume: 1.0);
    add(MoveAlongPathEffect(
        Path()
          ..moveTo(-100, 400)
          ..quadraticBezierTo(-50, 100, 0, 0),
        EffectController(
          duration: 1.5,
        )));
  }

  void moveInDirection(PlayerDirection direction, double dt) {
    double dx = 0, dy = 0;

    switch (direction) {
      case PlayerDirection.left:
        dx = -speed * dt;
        // print("position.x: ${position.x} size.x: ${.x}");
        if (position.x < -(RunningGame.characterwidth * 10)) {
          position.x = -(RunningGame.characterwidth * 10);
        }
        break;
      case PlayerDirection.right:
        dx = speed * dt;
        if (position.x > RunningGame.characterwidth * 10) {
          position.x = RunningGame.characterwidth * 10;
        }
        break;
      case PlayerDirection.up:
        dy = -speed * dt;
        if (position.y < -(RunningGame.characterheight * 10)) {
          position.y = -(RunningGame.characterheight * 10);
        }
        break;
      case PlayerDirection.down:
        dy = speed * dt;
        if (position.y > RunningGame.characterheight * 10) {
          position.y = RunningGame.characterheight * 10;
        }
        break;
      case PlayerDirection.leftUp:
        dx = -speed * dt * 0.7071; // Reduce speed for diagonal movement
        dy = -speed * dt * 0.7071;

        if (position.x < -(RunningGame.characterwidth * 10)) {
          position.x = -(RunningGame.characterwidth * 10);
        }
        break;
      case PlayerDirection.leftDown:
        dx = -speed * dt * 0.7071;
        dy = speed * dt * 0.7071;

        if (position.x < -(RunningGame.characterwidth * 10)) {
          position.x = -(RunningGame.characterwidth * 10);
        }
        if (position.y > RunningGame.characterheight * 10) {
          position.y = RunningGame.characterheight * 10;
        }
        break;
      case PlayerDirection.rightUp:
        dx = speed * dt * 0.7071;
        dy = -speed * dt * 0.7071;

        if (position.x > RunningGame.characterwidth * 10) {
          position.x = RunningGame.characterwidth * 10;
        }

        break;
      case PlayerDirection.rightDown:
        dx = speed * dt * 0.7071;
        dy = speed * dt * 0.7071;

        if (position.x > RunningGame.characterwidth * 10) {
          position.x = RunningGame.characterwidth * 10;
        }
        if (position.y > RunningGame.characterheight * 10) {
          position.y = RunningGame.characterheight * 10;
        }
        break;
      default:
        break;
    }
    add(MoveToEffect(
      position + Vector2(dx, dy),
      EffectController(
        duration: 0.1,
      ),
    ));
    position.add(Vector2(dx, dy));
  }

  PlayerDirection? getMovementDirection(
      bool isMoveUp, bool isMoveDown, bool isMoveLeft, bool isMoveRight) {
    if (isMoveLeft && isMoveUp) {
      return PlayerDirection.leftUp;
    } else if (isMoveLeft && isMoveDown) {
      return PlayerDirection.leftDown;
    } else if (isMoveRight && isMoveUp) {
      return PlayerDirection.rightUp;
    } else if (isMoveRight && isMoveDown) {
      return PlayerDirection.rightDown;
    } else if (isMoveUp) {
      return PlayerDirection.up;
    } else if (isMoveDown) {
      return PlayerDirection.down;
    } else if (isMoveLeft) {
      return PlayerDirection.left;
    } else if (isMoveRight) {
      return PlayerDirection.right;
    } else {
      return null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state == GameState.playing) {
      game.world.add(_bulletSpawner);
    }
    // if (game.state == GameState.start) {
    //   _bulletSpawner.removeFromParent();
    // }

    if (health <= 0) {
      game.state = GameState.over;
      playerHealth = 100;
      score = 0;
    }

    if (!_canPlaySwooshSound &&
        game.currentTime() - _lastPlayedTimeStamp > 0.5) {
      _canPlaySwooshSound = true;
    }

    // Move the player in the current direction if they are in "run" state
    if (state == PlayerState.run && currentDirection != null) {
      moveInDirection(currentDirection!, dt);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;

    final isMoveUp = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);
    final isMoveDown = keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS);
    final isMoveLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isMoveRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    // Determine current movement direction based on pressed keys
    currentDirection =
        getMovementDirection(isMoveUp, isMoveDown, isMoveLeft, isMoveRight);

    if (isKeyDown && currentDirection != null) {
      state = PlayerState.run;
    } else if (event is KeyUpEvent && keysPressed.isEmpty) {
      state = PlayerState.idle; // Stop moving when no keys are pressed
    }

    return false;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_isDragging) {
      if (event.localDelta.length > 40 && _canPlaySwooshSound) {
        _canPlaySwooshSound = false;
        _lastPlayedTimeStamp = game.currentTime();
        FlameAudio.play("whoosh.mp3", volume: 0.5);
      }

      final delta = event.localDelta;
      position.add(delta);
    }
    bulletGenerationSpeed = 0.1;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    bulletGenerationSpeed = 0.2;
    _bulletSpawner.timer.start();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Aestroid) {
      takeDamage(10);
    }
  }

  void takeDamage(double damage) {
    playerHealth -= damage;
    if (playerHealth <= 0) {
      print("Player died");
    }
  }

  @override
  bool get debugMode => false;
}
