import 'package:flame/components.dart';
import 'package:flame/flame.dart';

Sprite loadSprite(
    {required String path, required Vector2 position, required Vector2? size}) {
  return Sprite(
    Flame.images.fromCache(path),
    srcPosition: position,
    srcSize: size,
  );
}
