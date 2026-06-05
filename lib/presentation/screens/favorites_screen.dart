import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/toilet_list_tile.dart';
import 'package:bol_il_bwa/data/mock/mock_data.dart';
import 'package:bol_il_bwa/application/view_models/favorites_view_model.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  void _toggleFavorite(String toiletId, WidgetRef ref) {
    final viewModel = ref.read(favoritesViewModelProvider.notifier);
    viewModel.toggleFavorite(toiletId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        elevation: 2,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.favorites.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final toilet = state.favorites[index];
                    final distance = 0.5 + (index * 0.3);

                    return ToiletListTile(
                      toilet: toilet,
                      distance: distance,
                      isFavorited: true,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/toilet-detail',
                          arguments: toilet.id,
                        );
                      },
                      onFavoriteTap: () {
                        _toggleFavorite(toilet.id, ref);
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppTheme.textSecondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '즐겨찾기가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 화장실을 저장해보세요',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.map),
            label: const Text('지도 보기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
