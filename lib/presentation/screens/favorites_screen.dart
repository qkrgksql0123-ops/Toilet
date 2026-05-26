import 'package:flutter/material.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/toilet_list_tile.dart';
import 'package:bol_il_bwa/data/mock/mock_data.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Set<String> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = {'1', '3'};
  }

  void _toggleFavorite(String toiletId) {
    setState(() {
      if (_favorites.contains(toiletId)) {
        _favorites.remove(toiletId);
      } else {
        _favorites.add(toiletId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritedToilets = MockData.toilets
        .where((toilet) => _favorites.contains(toilet.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        elevation: 2,
      ),
      body: favoritedToilets.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: favoritedToilets.length,
              itemBuilder: (context, index) {
                final toilet = favoritedToilets[index];
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
                    _toggleFavorite(toilet.id);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
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
