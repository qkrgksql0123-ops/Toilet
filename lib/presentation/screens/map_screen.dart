import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/toilet_list_tile.dart';
import 'package:bol_il_bwa/application/view_models/map_view_model.dart';
import 'package:bol_il_bwa/domain/entities/toilet.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapViewModelProvider);
    final viewModel = ref.read(mapViewModelProvider.notifier);

    // 초기 로드 (한 번만)
    ref.listen(mapViewModelProvider, (previous, next) {
      if (previous == null && next.toilets.isEmpty && !next.isLoading) {
        Future.microtask(() => viewModel.loadAllToilets());
      }
    });

    final toiletList = state.toilets
        .asMap()
        .entries
        .map((entry) => {
              'toilet': entry.value,
              'distance': 0.5 + (entry.key * 0.3),
            })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('볼일봐 🚻'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ToiletSearchDelegate(toiletList, viewModel),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.surfaceColor,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 64,
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '지도가 표시됩니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '주변 화장실 (${toiletList.length}개)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (toiletList.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            '화장실이 없습니다',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ...toiletList.map((item) {
                        final toilet = item['toilet'] as Toilet;
                        final distance = item['distance'] as double;
                        return ToiletListTile(
                          toilet: toilet,
                          distance: distance,
                          isFavorited: viewModel.isFavorited(toilet.id),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/toilet-detail',
                              arguments: toilet.id,
                            );
                          },
                          onFavoriteTap: () {
                            viewModel.toggleFavorite(toilet.id);
                          },
                        );
                      }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('내 위치: 37.5547, 126.9706'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: const Icon(Icons.location_searching),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  '익명 사용자',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('지도'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('즐겨찾기'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('비번 공유'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/password');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('정보'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ToiletSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> toilets;
  final dynamic viewModel;

  _ToiletSearchDelegate(this.toilets, this.viewModel);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = toilets
        .where((item) =>
            item['toilet'].name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ToiletListTile(
          toilet: item['toilet'],
          distance: item['distance'],
          onTap: () {
            close(context, item['toilet'].id);
            Navigator.of(context).pushNamed(
              '/toilet-detail',
              arguments: item['toilet'].id,
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = toilets
        .where((item) =>
            item['toilet'].name.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(item['toilet'].name),
          subtitle: Text(item['toilet'].address),
          onTap: () {
            close(context, item['toilet'].id);
            Navigator.of(context).pushNamed(
              '/toilet-detail',
              arguments: item['toilet'].id,
            );
          },
        );
      },
    );
  }
}
