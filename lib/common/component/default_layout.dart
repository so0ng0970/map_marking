// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:map_marking/user/component/main_drawer.dart';

import '../const/color.dart';

class DefaultLayout extends StatelessWidget {
  Widget body;
  FloatingActionButton? floatingActionButton;
  DefaultLayout({
    Key? key,
    required this.body,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DRAWER_HEADER_BG,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo/logo_maap.png',
          scale: 3.5,
        ),
      ),
      drawer: const MainDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
