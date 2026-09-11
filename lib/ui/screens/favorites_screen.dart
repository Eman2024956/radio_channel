import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_translations.dart';
import '../widgets/station_list_tile.dart';
import '../widgets/language_toggle_button.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const FavoritesScreen({super.key, this.onNavigateToTab});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedTab = 0; // 0: Favorites, 1: History
  String _filterQuery = '';

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final favorites = context.watch<FavoritesProvider>();
    final rawList = _selectedTab == 0 ? favorites.favorites : favorites.recents;

    final displayList = rawList.where((s) {
      if (_filterQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_filterQuery.toLowerCase()) ||
          s.country.toLowerCase().contains(_filterQuery.toLowerCase()) ||
          s.tags.toLowerCase().contains(_filterQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: AppTheme.accentPink, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTab == 0 ? tr.favoriteStations : tr.playbackHistory,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedTab == 0
                              ? '${favorites.favorites.length} ${tr.favoriteStations}'
                              : '${favorites.recents.length} ${tr.playbackHistory}',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMutedOf(context)),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedTab == 1 && favorites.recents.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => favorites.clearRecents(),
                      icon: Icon(Icons.delete_sweep_rounded, size: 16, color: AppTheme.textMutedOf(context)),
                      label: Text(tr.clear, style: TextStyle(color: AppTheme.textMutedOf(context), fontSize: 12)),
                    ),
                  const SizedBox(width: 4),
                  const LanguageToggleButton(),
                ],
              ),
            ),

            // Segmented Switcher (Favorites / History)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.cardColorOf(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderOf(context)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppTheme.elevatedOf(context) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedTab == 0
                              ? Border.all(color: AppTheme.accentPink.withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: _selectedTab == 0 ? AppTheme.accentPink : AppTheme.textMutedOf(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${tr.navFavorites} (${favorites.favorites.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedTab == 0 ? AppTheme.textPrimaryOf(context) : AppTheme.textMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppTheme.elevatedOf(context) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedTab == 1
                              ? Border.all(color: AppTheme.primaryOf(context).withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 16,
                              color: _selectedTab == 1 ? AppTheme.primaryOf(context) : AppTheme.textMutedOf(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${tr.playbackHistory} (${favorites.recents.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedTab == 1 ? AppTheme.textPrimaryOf(context) : AppTheme.textMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search within list if list is not empty
            if (rawList.length > 5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  onChanged: (v) => setState(() => _filterQuery = v),
                  decoration: InputDecoration(
                    hintText: tr.filterFavoritesHint,
                    prefixIcon: const Icon(Icons.filter_list_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),

            const SizedBox(height: 6),

            // Station List or Empty State
            Expanded(
              child: displayList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedTab == 0 ? Icons.favorite_border_rounded : Icons.history_toggle_off_rounded,
                            size: 64,
                            color: AppTheme.textMutedOf(context),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _selectedTab == 0 ? tr.noFavoritesYet : tr.noHistoryYet,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _selectedTab == 0 ? tr.noFavoritesNote : tr.noHistoryNote,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOf(context),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => widget.onNavigateToTab?.call(0),
                            icon: const Icon(Icons.explore_rounded, size: 18),
                            label: Text(
                              tr.exploreStations,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: displayList.length,
                      itemBuilder: (ctx, i) {
                        return StationListTile(station: displayList[i]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
