import 'package:go_router/go_router.dart';
import 'package:klearn/screens/init/screen.dart';
import 'package:klearn/screens/stt/screen.dart';

final router = GoRouter(
  routes: <GoRoute>[
    GoRoute(path: '/', builder: (context, state) => const InitScreen()),
    GoRoute(path: '/stt', builder: (context, state) => const SttScreen()),
  ],
);
