// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:map_marking/common/component/default_layout.dart';
import 'package:map_marking/record/screen/record_detail_list_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../record/model/record_model.dart';
import '../../record/provider/controller_provider.dart';
import '../../record/provider/record_detail_provider.dart';
import '../../record/screen/record_detail_screen.dart';
import '../../record/screen/record_screen.dart';
import '../../user/provider/user_provider.dart';
import '../const/color.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static String get routeName => 'home';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool detailTap = false;
  Future<String>? _locationFuture;
  Position? position;
  NaverMapController? mapController;
  bool markerTap = false;
  bool recordTap = false;
  double markerLatitude = 0.0;
  double markerLongitude = 0.0;
  Color markerColor = Colors.black;
  NMarker addMarker = NMarker(
    id: '1',
    position: const NLatLng(
      0.0,
      0.0,
    ),
  );
  static const pageSize = 8;
  String? markerId;
  String? postId;
  final PagingController<DocumentSnapshot?, RecordModel> pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    super.initState();
    mapController;
    _locationFuture = checkPermissionAndGetLocation();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NMarker? tapMarker;
    final detailProvider = ref.watch(recordDetailProvider.notifier);
    String testMarker = 'test1';
    final user = ref.watch(userDataProvider).value;

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
              maxHeight:
                  user == null ? 150 : MediaQuery.of(context).size.height - 140,
              minHeight: user == null
                  ? 30
                  : markerTap
                      ? 150
                      : 100,
              body: Stack(
                children: [
                  StreamBuilder<List<RecordModel>>(
                      stream: detailProvider.getPostListFromFirestore(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        } else {
                          final post = snapshot.data!;

                          return NaverMap(
                            options: NaverMapViewOptions(
                              initialCameraPosition: NCameraPosition(
                                target: NLatLng(latitude, longitude),
                                zoom: 15,
                                bearing: 0,
                                tilt: 0,
                              ),
                            ),
                            onMapTapped: (point, latLng) {
                              if (markerTap) {
                                setState(() {
                                  recordTap = true;
                                  markerLatitude = latLng.latitude;
                                  markerLongitude = latLng.longitude;

                                  tapMarker = NMarker(
                                    iconTintColor: ref
                                        .watch(markerColorProvider.notifier)
                                        .state,
                                    id: testMarker,
                                    position: NLatLng(
                                        latLng.latitude, latLng.longitude),
                                  );

                                  mapController?.addOverlay(tapMarker!);
                                });
                              } else {
                                print(addMarker);

                                addMarker.setOnTapListener((marker) {
                                  setState(() {
                                    for (var data in post) {
                                      postId = data.postId;
                                      markerId = marker.info.id;
                                    }
                                    detailTap = true;

                                    print('dd $markerId');
                                  });
                                });
                              }
                            },
                            onMapReady: (controller) {
                              ref
                                  .read(mapControllerProvider.notifier)
                                  .setMapController(controller);

                              mapController = controller;
                              addMarkers(post);
                            },
                          );
                        }
                      }),
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
              panel: user == null
                  ? Container(
                      color: RECORD_BG,
                      child: Column(
                        children: const [
                          Icon(
                            Icons.drag_handle,
                            color: LOCATION,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Center(
                            child: Text(
                              '로그인 후 마커 & 글쓰기 이용 가능합니다.',
                              style:
                                  TextStyle(fontSize: 17, color: MARKER_BUTTON),
                            ),
                          ),
                        ],
                      ),
                    )
                  : detailTap
                      ? Container(
                          color: RECORD_BG,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RecordDetailScreen(
                                markerTap: markerTap,
                                recordTap: recordTap,
                                onMarkerTapChanged: onMarkerTapChanged,
                                onRecordTapChanged: onRecordTapChanged,
                                testMarker: testMarker,
                                removeMarker: removeMarker,
                                mapController: mapController!,
                                markerId: markerId.toString(),
                                detailTap: detailTap,
                                onDetailTapChanged: onDetailTapChanged,
                                onMarkerCreated: (addMarker) {
                                  setState(() {
                                    this.addMarker = addMarker;
                                  });
                                },
                              )),
                        )
                      : Container(
                          color: RECORD_BG,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.drag_handle,
                                  color: LOCATION,
                                ),
                                markerTap
                                    ? RecordScreen(
                                        pagingController: pagingController,
                                        edit: false,
                                        onMarkerCreated: (addMarker) {
                                          setState(() {
                                            this.addMarker = addMarker;
                                          });
                                        },
                                        addMarker: addMarker,
                                        testMarker: testMarker,
                                        recordTap: recordTap,
                                        markerTap: markerTap,
                                        onMarkerTapChanged: onMarkerTapChanged,
                                        markerLongitude: markerLongitude,
                                        markerLatitude: markerLatitude,
                                        onRecordTapChanged: onRecordTapChanged,
                                        mapController: mapController,
                                        markerColor: markerColor,
                                      )
                                    : RecordDetailListScreen(
                                        removeMarker: removeMarker,
                                        markerTap: markerTap,
                                        testMarker: testMarker,
                                        markerId: markerId.toString(),
                                        detailTap: detailTap,
                                        recordTap: recordTap,
                                        onMarkerTapChanged: onMarkerTapChanged,
                                        onDetailTapChanged: onDetailTapChanged,
                                        onRecordTapChanged: onRecordTapChanged,
                                        onMarkerCreated: onMarkerCreated,
                                      ),
                              ],
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

  void onMarkerCreated(NMarker addMarker) {
    setState(() {
      this.addMarker = addMarker;
    });
  }

  void addMarkers(List<RecordModel> post) {
    for (var data in post) {
      final marker = NMarker(
        iconTintColor: Color(data.selectedColor),
        id: data.markerId,
        position: NLatLng(
          data.markerLatitude,
          data.markerLongitude,
        ),
      );
      mapController?.addOverlay(marker);

      final onMarkerInfoWindow = NInfoWindow.onMarker(
        id: marker.info.id,
        text: data.title,
      );
      marker.openInfoWindow(onMarkerInfoWindow);

      marker.setOnTapListener((marker) {
        setState(() {
          detailTap = true;
          markerId = marker.info.id;
          print('dd $markerId');
        });
      });
    }
  }

  void removeMarker(String id) {
    mapController!.deleteOverlay(NOverlayInfo(
      type: NOverlayType.marker,
      id: id,
    ));
    refreshMap();
  }

  void refreshMap() {
    setState(() {});
  }

  Future<void> fetchPage(DocumentSnapshot? pageKey) async {
    try {
      print('Fetching new page...');
      final newSnapshots = await ref
          .watch(recordDetailProvider.notifier)
          .getPostListScrollFromFirestore(
            pageKey,
            pageSize,
          );

      if (newSnapshots.isEmpty) {
        pagingController.appendLastPage([]);
        return;
      }
      final newItems = newSnapshots
          .map((snapshot) =>
              RecordModel.fromJson(snapshot.data() as Map<String, dynamic>))
          .toList();

      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
        print('Fetched last page with ${newItems.length} items.');
      } else {
        final nextPageKey = newSnapshots.last;
        pagingController.appendPage(newItems, nextPageKey);
        print('Fetched new page with ${newItems.length} items.');
      }
    } catch (error) {
      print('Error fetching page: $error');
      pagingController.error = error;
    }
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

  void onDetailTapChanged(bool detailTap) {
    setState(() {
      this.detailTap = detailTap;
    });
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
