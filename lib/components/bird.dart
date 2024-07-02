import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flappy_game/components/configuration.dart';
import 'package:flappy_game/game/assets.dart';
import 'package:flappy_game/game/bird_movement.dart';
import 'package:flappy_game/game/flappy_bird_game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bird extends SpriteGroupComponent<BirdMovement>
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  Bird();
  int score = 0;
  @override
  FutureOr<void> onLoad() async {
    final birdMidFlap = await gameRef.loadSprite(Assets.birdMidFlap);
    final birdUpFlap = await gameRef.loadSprite(Assets.birdUpFlap);
    final birdDownFlap = await gameRef.loadSprite(Assets.birdDownFlap);
    size = Vector2(50, 40);
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    current = BirdMovement.middle;
    sprites = {
      BirdMovement.up: birdUpFlap,
      BirdMovement.down: birdDownFlap,
      BirdMovement.middle: birdMidFlap,
    };
    add(CircleHitbox());
  }

  void fly() {
    add(MoveByEffect(
      Vector2(0, Config.gravity),
      EffectController(duration: 0.2, curve: Curves.decelerate),
      onComplete: () => current = BirdMovement.down,
    ));
    current = BirdMovement.up;
    FlameAudio.play(Assets.flying);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    FlameAudio.play(Assets.collision);

    super.onCollisionStart(intersectionPoints, other);
    gameOver();
  }

  Future<void> gameOver() async {
    if (int.parse(game.score.text) > game.highScore) {
      game.highScore = score;
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      sharedPref.setInt('highScore', score);
    }
    game.isHit = true;
    gameRef.overlays.add('gameOver');
    gameRef.pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += Config.birdVelocity * dt;
    if (position.y < 1) {
      gameOver();
    }
  }

  void reset() {
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
  }
}