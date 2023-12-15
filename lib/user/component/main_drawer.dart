// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:map_marking/user/provider/user_provider.dart';

import '../../common/const/color.dart';
import '../../record/provider/controller_provider.dart';
import '../screen/login_sign_screen.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({
    super.key,
  });

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
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: userData.when(
            data: (user) {
              return ListView(
                children: [
                  if (user != null)
                    SizedBox(
                      height: 200,
                      child: Stack(
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
                              backgroundImage:
                                  NetworkImage(user.photoUrl.toString()),
                            ),
                            accountName: Text(
                              user.userName.toString(),
                            ),
                            accountEmail: Text(
                              user.email.toString(),
                            ),
                          ),
                          if (user != null)
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
                      ),
                    ),
                  if (user == null)
                    const SizedBox(
                      height: 10,
                    ),
                  textButton(
                    () async {
                      if (user != null) {
                        await logout.logout(context);
                        ref
                            .watch(mapControllerProvider.notifier)
                            .clearOverlays();
                        ref
                            .watch(mapControllerProvider.notifier)
                            .disposeController();

                        context.pop();
                      } else {
                        context.goNamed(LoginSignScreen.routeName);
                      }
                    },
                    Text(
                      user != null ? '로그아웃' : '로그인 하기',
                      style: const TextStyle(color: SIGN_TEXT),
                    ),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
