import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart' as kakao;
import 'package:bol_il_bwa/domain/entities/toilet.dart';

typedef MarkerTapCallback = void Function(String toiletId);

class KakaoMapController {
  _KakaoMapWidgetStubState? _state;

  void panTo(double lat, double lng) => _state?._panTo(lat, lng);

  void showCurrentLocation(double lat, double lng) => _state?._panTo(lat, lng);

  Future<void> getCurrentLocation({
    required void Function(double lat, double lng) onSuccess,
    void Function(String error)? onError,
  }) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        onError?.call('위치 권한이 거부되었습니다');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      onSuccess(pos.latitude, pos.longitude);
    } catch (e) {
      onError?.call(e.toString());
    }
  }
}

class KakaoMapWidget extends StatefulWidget {
  final double centerLat;
  final double centerLng;
  final List<Toilet> markers;
  final MarkerTapCallback? onMarkerTap;
  final KakaoMapController? controller;

  const KakaoMapWidget({
    super.key,
    this.centerLat = 37.5665,
    this.centerLng = 126.9780,
    this.markers = const [],
    this.onMarkerTap,
    this.controller,
  });

  @override
  State<KakaoMapWidget> createState() => _KakaoMapWidgetStubState();
}

class _KakaoMapWidgetStubState extends State<KakaoMapWidget> {
  kakao.KakaoMapController? _nativeController;

  List<kakao.Marker> get _kakaoMarkers => widget.markers.take(300).map((t) {
        return kakao.Marker(
          markerId: t.id,
          latLng: kakao.LatLng(t.latitude, t.longitude),
          infoWindowContent: t.name,
        );
      }).toList();

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(KakaoMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?._state = this;
  }

  void _panTo(double lat, double lng) {
    _nativeController?.panTo(kakao.LatLng(lat, lng));
  }

  @override
  Widget build(BuildContext context) {
    return kakao.KakaoMap(
      onMapCreated: (controller) {
        _nativeController = controller;
      },
      center: kakao.LatLng(widget.centerLat, widget.centerLng),
      markers: _kakaoMarkers,
      onMarkerTap: (markerId, latLng, zoomLevel) {
        widget.onMarkerTap?.call(markerId);
      },
    );
  }

  @override
  void dispose() {
    _nativeController = null;
    super.dispose();
  }
}
