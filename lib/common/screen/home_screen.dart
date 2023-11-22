import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:map_marking/common/component/default_layout.dart';

class HomeScreen extends StatelessWidget {
  static String get routeName => 'home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      body: NaverMap(
        options: const NaverMapViewOptions(),
        onMapReady: (controller) {
          print("네이버 맵 로딩됨!");
        },
      ),
    );
  }
}
