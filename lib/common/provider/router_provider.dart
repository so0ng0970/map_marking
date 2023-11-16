import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/common/router/routers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  AlwaysAliveProviderListenable authProvider;

  return GoRouter(
    routes: GoRouters().routes,
    initialLocation: '/splash',
    redirect: GoRouters().redirectLogic,
  );
});
