// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_marking/common/component/default_layout.dart';
import 'package:map_marking/record/screen/record_detail_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../record/provider/record_detail_provider.dart';
import '../../record/screen/record_screen.dart';
import '../const/color.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static String get routeName => 'home';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<String>? _locationFuture;
  Position? position;
  NaverMapController? mapController;
  bool markerTap = false;
  bool recordTap = false;
  double markerLatitude = 0.0;
  double markerLongitude = 0.0;
  Color markerColor = Colors.black;
  @override
  void initState() {
    super.initState();

    _locationFuture = checkPermissionAndGetLocation();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
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
            return SlidingUpPanel(
              maxHeight: MediaQuery.of(context).size.height - 140,
              minHeight: markerTap ? 150 : 100,
              body: Stack(
                children: [
                  NaverMap(
                    options: NaverMapViewOptions(
                      initialCameraPosition: NCameraPosition(
                          target: NLatLng(latitude, longitude),
                          zoom: 15,
                          bearing: 0,
                          tilt: 0),
                    ),
                    onMapTapped: (point, latLng) {
                      if (markerTap) {
                        setState(() {
                          recordTap = true;
                          markerLatitude = latLng.latitude;
                          markerLongitude = latLng.longitude;

                          final marker = NMarker(
                            iconTintColor:
                                ref.watch(markerColorProvider.notifier).state,
                            id: 'test2',
                            position:
                                NLatLng(latLng.latitude, latLng.longitude),
                          );

                          mapController?.addOverlay(marker);
                        });

                        print('Marker');
                      } else {
                        print(latLng);
                      }
                    },
                    onMapReady: (controller) {
                      mapController = controller;
                      print("네이버 맵 로딩됨!");
                      final marker = NMarker(
                        id: 'test',
                        position: const NLatLng(
                          37.5676438505,
                          126.83211565,
                        ),
                      );
                      final marker1 = NMarker(
                        id: 'test1',
                        position: const NLatLng(
                          97.5676438505,
                          126.83211565,
                        ),
                      );
                      controller.addOverlayAll({marker, marker1});

                      final onMarkerInfoWindow = NInfoWindow.onMarker(
                        id: marker.info.id,
                        text: "서울 식물원",
                      );
                      marker.openInfoWindow(onMarkerInfoWindow);
                    },
                  ),
                  Positioned(
                    top: 395,
                    right: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LOCATION_BG,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                      ),
                      onPressed: () {
                        setState(() {
                          updateCamera(position);
                        });
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  )
                ],
              ),
              panel: Container(
                color: RECORD_BG,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: markerTap
                      ? RecordScreen(
                          recordTap: recordTap,
                          markerTap: markerTap,
                          onMarkerTapChanged: onMarkerTapChanged,
                          markerLongitude: markerLongitude,
                          markerLatitude: markerLatitude,
                          onRecordTapChanged: onRecordTapChanged,
                          mapController: mapController,
                          markerColor: markerColor,
                        )
                      : RecordDetailScreen(
                          markerTap: markerTap,
                          onMarkerTapChanged: onMarkerTapChanged,
                        ),
                ),
              ),
            );
          }
          return ErrorScreen(
            snapshot: snapshot,
          );
        },
      ),
    );
  }

  Future<void> updateCamera(Position? position) async {
    NCameraPosition cameraPosition1 = NCameraPosition(
      zoom: 15,
      target: NLatLng(position!.latitude, position.longitude),
    );
    mapController
        ?.updateCamera(NCameraUpdate.fromCameraPosition(cameraPosition1));

    print('이동');
  }

  void onMarkerTapChanged(bool markerTap) {
    setState(() {
      this.markerTap = markerTap;
    });
  }

  void onRecordTapChanged(bool recordTap) {
    setState(() {
      this.recordTap = recordTap;
    });
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
}

class ErrorScreen extends StatelessWidget {
  AsyncSnapshot<String> snapshot;
  ErrorScreen({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}
