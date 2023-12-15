import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mapControllerProvider =
    StateNotifierProvider<MapControllerState, NaverMapController?>(
        (ref) => MapControllerState());

class MapControllerState extends StateNotifier<NaverMapController?> {
  MapControllerState() : super(null);

  void setMapController(NaverMapController? controller) {
    state = controller;
  }

  void clearOverlays() {
    state?.clearOverlays();
  }

  void disposeController() {
    state?.dispose();
    state = null;
  }
}
