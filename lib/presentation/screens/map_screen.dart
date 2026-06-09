import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/toilet_list_tile.dart';
import 'package:bol_il_bwa/presentation/widgets/kakao_map_widget.dart';
import 'package:bol_il_bwa/application/view_models/map_view_model.dart';
import 'package:bol_il_bwa/application/view_models/favorites_view_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = KakaoMapController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _locating = false;

  static const double _defaultLat = 37.5665;
  static const double _defaultLng = 126.9780;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mapViewModelProvider.notifier).loadAllToilets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _locating = true);
    _mapController.getCurrentLocation(
      onSuccess: (lat, lng) {
        if (!mounted) return;
        setState(() => _locating = false);
        _mapController.showCurrentLocation(lat, lng);
        _mapController.panTo(lat, lng);
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _locating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 정보를 가져올 수 없습니다. 브라우저 위치 권한을 확인해주세요.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapViewModelProvider);
    final viewModel = ref.read(mapViewModelProvider.notifier);
    // 즐겨찾기는 favoritesViewModelProvider를 단일 소스로 사용
    ref.watch(favoritesViewModelProvider); // 상태 변경 시 리빌드 구독
    final favoritesNotifier = ref.read(favoritesViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 지도 (전체 화면) - 이벤트가 iframe에 전달되도록 아래에 위치
          Positioned.fill(
            child: KakaoMapWidget(
              centerLat: _defaultLat,
              centerLng: _defaultLng,
              markers: state.toilets,
              controller: _mapController,
              onMarkerTap: (toiletId) {
                Navigator.of(context).pushNamed('/toilet-detail', arguments: toiletId);
              },
            ),
          ),

          // 상단 검색바 + 햄버거 - pointer interceptor로 지도 이벤트 차단 방지
          SafeArea(
            child: PointerInterceptor(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: const Icon(Icons.menu_rounded, color: AppTheme.textPrimaryColor, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '화장실 검색',
                            hintStyle: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondaryColor, size: 20),
                            suffixIcon: _isSearching
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() => _isSearching = false);
                                      viewModel.loadAllToilets();
                                    },
                                    child: const Icon(Icons.close_rounded, color: AppTheme.textSecondaryColor, size: 18),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (v) {
                            setState(() => _isSearching = v.isNotEmpty);
                            if (v.isEmpty) {
                              viewModel.loadAllToilets();
                            } else {
                              viewModel.searchToilets(v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 로딩 인디케이터
          if (state.isLoading)
            const Center(child: CircularProgressIndicator()),

          // 하단 시트 - PointerInterceptor로 지도 이벤트와 분리
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.12,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              final toilets = state.toilets;
              return PointerInterceptor(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      // 핸들
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDE1E7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // 헤더
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(
                          children: [
                            const Icon(Icons.wc_rounded, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              state.isLoading ? '불러오는 중...' : '화장실 ${toilets.length}개',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimaryColor),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '내 주변',
                                style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      // 목록
                      Expanded(
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : toilets.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
                                        const SizedBox(height: 12),
                                        Text('화장실이 없습니다', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                                    itemCount: toilets.length,
                                    itemBuilder: (context, index) {
                                      final toilet = toilets[index];
                                      return ToiletListTile(
                                        toilet: toilet,
                                        distance: 0.5 + index * 0.3,
                                        isFavorited: favoritesNotifier.isFavorited(toilet.id),
                                        onTap: () {
                                          _mapController.panTo(toilet.latitude, toilet.longitude);
                                          Navigator.of(context).pushNamed(
                                            '/toilet-detail',
                                            arguments: toilet.id,
                                          );
                                        },
                                        onFavoriteTap: () =>
                                            favoritesNotifier.toggleFavorite(toilet.id, toilet),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      // GPS + 현재위치 FAB
      floatingActionButton: PointerInterceptor(
        child: FloatingActionButton(
          onPressed: _locating ? null : _goToCurrentLocation,
          backgroundColor: AppTheme.primaryColor,
          child: _locating
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.my_location_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return PointerInterceptor(
      child: Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text('볼일봐 🚻', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('익명 사용자', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(context, Icons.map_rounded, '지도', () => Navigator.pop(context)),
                _drawerItem(context, Icons.bookmark_rounded, '즐겨찾기', () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/favorites');
                }),
                const Divider(indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('내 기록', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ),
                _drawerItem(context, Icons.rate_review_rounded, '내 리뷰 기록', () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/my-reviews');
                }),
                _drawerItem(context, Icons.lock_rounded, '내 비번 공유 기록', () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/my-passwords');
                }),
                const Divider(indent: 16, endIndent: 16),
                _drawerItem(context, Icons.info_outline_rounded, '정보', () => Navigator.pop(context)),
              ],
            ),
          ),
        ],
      ),
    ), // Drawer
    ); // PointerInterceptor
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      horizontalTitleGap: 8,
    );
  }
}
