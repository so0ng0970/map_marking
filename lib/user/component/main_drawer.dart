import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/user/provider/user_provider.dart';
import 'package:map_marking/user/screen/login_sign_screen.dart';

import '../../common/const/color.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);
    final logout = ref.watch(authProvider.notifier);

    TextButton textButton(VoidCallback onpressed, Text text) {
      return TextButton(
        onPressed: onpressed,
        child: text,
      );
    }

    return SafeArea(
      child: Drawer(
        backgroundColor: DRAWER_BG,
        child: ListView(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: userData.when(
                data: (user) {
                  final login = FirebaseAuth.instance.authStateChanges();
                  if (login == null) {
                    return const Text('로그인 해주세요');
                  } else {
                    return Stack(
                      children: [
                        UserAccountsDrawerHeader(
                          decoration: const BoxDecoration(
                            color: DRAWER_HEADER_BG,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(45.0),
                            ),
                          ),
                          currentAccountPicture: CircleAvatar(
                            // 현재 계정 이미지 set
                            backgroundImage: NetworkImage(user.photoUrl),
                          ),
                          accountName: Text(
                            user.userName,
                          ),
                          accountEmail: Text(
                            user.email,
                          ),
                        ),
                        Positioned(
                          left: 55,
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.settings,
                              size: 25,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    );
                  }
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stackTrace) => Text('Error: $error'),
              ),
            ),
            textButton(
              () async {
                await logout.logout(context);
                context.goNamed(LoginSignScreen.routeName);
              },
              const Text(
                '로그아웃',
                style: TextStyle(color: SIGN_TEXT),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
