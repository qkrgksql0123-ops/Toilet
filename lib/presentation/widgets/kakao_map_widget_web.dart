import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:bol_il_bwa/domain/entities/toilet.dart';

typedef MarkerTapCallback = void Function(String toiletId);

class KakaoMapController {
  _KakaoMapWidgetWebState? _state;

  void panTo(double lat, double lng) => _state?._panTo(lat, lng);

  void showCurrentLocation(double lat, double lng) =>
      _state?._showCurrentLocation(lat, lng);

  void getCurrentLocation({
    required void Function(double lat, double lng) onSuccess,
    void Function(String error)? onError,
  }) {
    html.window.navigator.geolocation.getCurrentPosition().then((pos) {
      final lat = pos.coords!.latitude!.toDouble();
      final lng = pos.coords!.longitude!.toDouble();
      onSuccess(lat, lng);
    }).catchError((e) {
      onError?.call(e.toString());
    });
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
  State<KakaoMapWidget> createState() => _KakaoMapWidgetWebState();
}

class _KakaoMapWidgetWebState extends State<KakaoMapWidget> {
  static int _counter = 0;
  late final String _viewType;
  html.IFrameElement? _iframe;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'kakao-map-${_counter++}';
    widget.controller?._state = this;

    _iframe = html.IFrameElement()
      ..src = '/kakao_map.html'
      ..allow = 'geolocation'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.pointerEvents = 'auto';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int id) {
      return _iframe!;
    });

    html.window.onMessage.listen((event) {
      try {
        final raw = event.data;
        if (raw is! String) return;
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final type = data['type'] as String?;
        if (type == 'mapReady') {
          _mapReady = true;
          _sendMarkers();
        } else if (type == 'markerTap') {
          widget.onMarkerTap?.call(data['toiletId'] as String);
        }
      } catch (_) {}
    });
  }

  @override
  void didUpdateWidget(KakaoMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?._state = this;
    if (_mapReady && oldWidget.markers != widget.markers) {
      _sendMarkers();
    }
  }

  void _sendMarkers() {
    final win = _iframe?.contentWindow;
    if (win == null) return;
    final list = widget.markers.take(300).map((t) => {
          'id': t.id,
          'name': t.name,
          'lat': t.latitude,
          'lng': t.longitude,
          'isLocked': t.isLocked,
        }).toList();
    win.postMessage(jsonEncode({'type': 'setMarkers', 'markers': list}), '*');
  }

  void _panTo(double lat, double lng) {
    _iframe?.contentWindow
        ?.postMessage(jsonEncode({'type': 'panTo', 'lat': lat, 'lng': lng}), '*');
  }

  void _showCurrentLocation(double lat, double lng) {
    _iframe?.contentWindow?.postMessage(
      jsonEncode({'type': 'showCurrentLocation', 'lat': lat, 'lng': lng}),
      '*',
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
