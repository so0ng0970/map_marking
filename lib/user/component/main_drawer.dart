import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_marking/user/provider/user_provider.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);

    return Drawer(
      child: ListView(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: userData.when(
              data: (user) {
                if (user == null) {
                  return const Text('로그인 해주세요');
                } else {
                  return Stack(
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                          color: Color(0xFF9fc5e8),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(45.0),
                            bottomRight: Radius.circular(45.0),
                          ),
                        ),
                        currentAccountPicture: CircleAvatar(
                          // 현재 계정 이미지 set
                          backgroundImage: NetworkImage(user.photoUrl),
                        ),
                        accountName: Text(
                          user.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        accountEmail: Text(
                          user.email ?? '',
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
          )
        ],
      ),
    );
  }
}
