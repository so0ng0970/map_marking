import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_marking/common/component/default_layout.dart';

import '../const/color.dart';

class HomeScreen extends StatefulWidget {
  static String get routeName => 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String>? _locationFuture;
  Position? position;
  @override
  void initState() {
    super.initState();
    _locationFuture = checkPermissionAndGetLocation();
  }

  Future<String> checkPermissionAndGetLocation() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화 해주세요';
    }
    LocationPermission checkedPermission = await Geolocator.checkPermission();
    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();
      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요';
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 세팅에서 허가해주세요';
    }

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return '위치 권한이 허가 되었습니다.';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      body: FutureBuilder<String>(
        future: _locationFuture,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.contains('위치 권한이 허가 되었습니다')) {
            final latitude = position!.latitude;
            final longitude = position!.longitude;
            return NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                    target: NLatLng(latitude, longitude),
                    zoom: 15,
                    bearing: 0,
                    tilt: 0),
              ),
              onMapReady: (controller) {
                print("네이버 맵 로딩됨!");
              },
            );
          }
          return Container(
            color: HOME_FAIL_BG,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon/character3.png',
                  scale: 2,
                ),
                Text(
                  snapshot.data!,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LOCATION_BG,
        onPressed: () {},
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
