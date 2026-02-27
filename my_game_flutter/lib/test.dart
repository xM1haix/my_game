// import "package:flame/game.dart";
// import "package:flutter/material.dart";
// import "package:my_game_client/my_game_client.dart";
// import "package:my_game_flutter/world.dart";
// import "package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart";
// import "package:serverpod_flutter/serverpod_flutter.dart";
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final serverUrl = await getServerUrl();
//   client = Client(serverUrl)
//     ..connectivityMonitor = FlutterConnectivityMonitor()
//     ..authSessionManager = FlutterAuthSessionManager();
//   await client.auth.initialize();
//   runApp(const MyApp());
// }
// late final Client client;
// late String serverUrl;

// import "package:flutter/material.dart";
// import "package:my_game_flutter/pages/splash_screen.dart";

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const SplashScreenGame(),
//       theme: ThemeData.dark(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
