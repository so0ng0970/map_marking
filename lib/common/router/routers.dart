import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/common/screen/spalsh_screen.dart';
import 'package:map_marking/record/screen/record_detail_screen.dart';
import '../../user/screen/login_sign_screen.dart';
import '../screen/home_screen.dart';

class GoRouters {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<GoRoute> get routes => [
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginSignScreen.routeName,
          builder: (context, state) => const LoginSignScreen(),
        ),
        GoRoute(
          path: '/',
          name: HomeScreen.routeName,
          builder: (context, state) => const HomeScreen(),
          routes: const [],
        )
      ];
  String? redirectLogic(_, GoRouterState state) {
    final loginIn = state.location == '/login';
    final splashPage = state.location == '/splash';
    final signPage = state.location == '/sign';

    User? user = _firebaseAuth.currentUser;
    return null;
  }
}
