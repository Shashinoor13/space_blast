import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:runner/game/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = RunningGame();
  runApp(GameWidget(game: game));
}
