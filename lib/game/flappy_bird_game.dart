import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_game/components/background.dart';
import 'package:flappy_game/components/bird.dart';
import 'package:flappy_game/components/configuration.dart';
import 'package:flappy_game/components/ground.dart';
import 'package:flappy_game/components/pipe_group.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  FlappyBirdGame();

  late Bird bird;
  late TextComponent score;
  late int highScore;
  Timer interval = Timer(Config.pipeInterval, repeat: true);
  bool isHit = false;

  @override
  FutureOr<void> onLoad() async {
        SharedPreferences sharedPref = await SharedPreferences.getInstance();
        highScore = sharedPref.getInt('highScore') ?? 0;
    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      // PipeGroup(),
      score = buildScoreMethod(),
    ]);
    interval.onTick = () => add(PipeGroup());
  }

  TextComponent buildScoreMethod() {
    return TextComponent(
      text: '0',
      position: Vector2(size.x / 2, size.y / 2 * 0.2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'Game',
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void onTap() {
    super.onTap();
    bird.fly();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);

    score.text = ' ${bird.score}';
  }
}
