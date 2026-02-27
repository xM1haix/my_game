import "package:flame/game.dart";
import "package:flame_splash_screen/flame_splash_screen.dart";
import "package:flutter/material.dart";
import "package:my_game_flutter/extensions/build_context.dart";
import "package:my_game_flutter/games/my_game.dart";

class SplashScreenGame extends StatefulWidget {
  const SplashScreenGame({super.key});

  @override
  SplashScreenGameState createState() => SplashScreenGameState();
}

class SplashScreenGameState extends State<SplashScreenGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlameSplashScreen(
        showBefore: (context) => const Text("Before logo"),
        showAfter: (context) => const Text("After logo"),
        theme: FlameSplashTheme.dark,
        onFinish: (context) =>
            context.nav(GameWidget(game: MyGame()), pushReplacement: true),
      ),
    );
  }
}
