import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/radio_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/search_filter_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import '../../utils/app_translations.dart';
import '../widgets/station_card.dart';
import '../widgets/station_list_tile.dart';
import '../widgets/language_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  final Function(int tabIndex)? onNavigateToTab;
  final VoidCallback? onOpenDrawer;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final radioProvider = context.watch<RadioProvider>();
    final player = context.watch<PlayerProvider>();
    final searchFilter = context.read<SearchFilterProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryOf(context),
          backgroundColor: AppTheme.cardColorOf(context),
          onRefresh: () => radioProvider.loadHomeData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Welcome Header Bar with Side Menu, Dark/Light Mode Switcher & Language Toggle Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      // Hamburger Side Menu Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.cardColorOf(context),
                          side: BorderSide(color: AppTheme.borderOf(context)),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(38, 38),
                        ),
                        icon: Icon(Icons.menu_rounded, color: AppTheme.primaryOf(context), size: 20),
                        tooltip: tr.menuTitle,
                        onPressed: () => onOpenDrawer?.call(),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryCyan, AppTheme.secondaryPurple],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.radio_rounded, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.appName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: AppTheme.textPrimaryOf(context),
                              ),
                            ),
                            Text(
                              tr.appSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Language Toggle (English / Arabic)
                      const LanguageToggleButton(),
                      const SizedBox(width: 6),
                      // Theme Switcher Button (Dark / Light Mode)
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.cardColorOf(context),
                          side: BorderSide(color: AppTheme.borderOf(context)),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                        icon: Icon(
                          themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: themeProvider.isDarkMode ? AppTheme.accentAmber : AppTheme.secondaryPurple,
                          size: 18,
                        ),
                        tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                        onPressed: () => themeProvider.toggleTheme(),
                      ),
                      const SizedBox(width: 6),
                      // Search Shortcut Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.cardColorOf(context),
                          side: BorderSide(color: AppTheme.borderOf(context)),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                        icon: Icon(Icons.search_rounded, color: AppTheme.primaryOf(context), size: 18),
                        tooltip: tr.navSearch,
                        onPressed: () => onNavigateToTab?.call(2), // Tab 2 is Search
                      ),
                    ],
                  ),
                ),
              ),

              // Error notification if failed
              if (radioProvider.errorMessage != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            radioProvider.errorMessage!,
                            style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () => radioProvider.loadHomeData(),
                          child: Text(tr.retry, style: const TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
                ),

              // Welcome Stats Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColorOf(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderOf(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(context, '30,000+', tr.liveRadios, Icons.wifi_tethering_rounded, AppTheme.primaryOf(context)),
                      Container(height: 24, width: 1, color: AppTheme.borderOf(context)),
                      _buildQuickStat(context, '180+', tr.countriesCount, Icons.public_rounded, AppTheme.secondaryPurple),
                      Container(height: 24, width: 1, color: AppTheme.borderOf(context)),
                      _buildQuickStat(context, 'MP3/AAC', tr.recordable, Icons.fiber_manual_record_rounded, AppTheme.accentPink),
                    ],
                  ),
                ),
              ),

              // Hero Featured Live Channel Banner
              if (radioProvider.featuredStation != null)
                SliverToBoxAdapter(
                  child: _buildHeroBanner(context, radioProvider.featuredStation!, player, tr),
                ),

              // Country Categories Quick Preview (Link to Countries Tab)
              SliverToBoxAdapter(
                child: _buildCountriesQuickSection(context, radioProvider, tr),
              ),

              // Explore by Genre
              SliverToBoxAdapter(
                child: _buildGenreCategories(context, searchFilter, tr),
              ),

              // Trending Worldwide (Horizontal list)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr.mostListened,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          searchFilter.setOrderBy('clickcount', true);
                          onNavigateToTab?.call(2);
                        },
                        child: Text(
                          tr.seeAll,
                          style: TextStyle(color: AppTheme.primaryOf(context), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 165,
                  child: radioProvider.isLoading
                      ? Center(child: CircularProgressIndicator(color: AppTheme.primaryOf(context)))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: radioProvider.topClickedStations.length,
                          itemBuilder: (ctx, i) {
                            return StationCard(
                              station: radioProvider.topClickedStations[i],
                              width: 155,
                            );
                          },
                        ),
                ),
              ),

              // Top Rated Stations (Vertical List)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr.communityTopRated,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          searchFilter.setOrderBy('votes', true);
                          onNavigateToTab?.call(2);
                        },
                        child: Text(
                          tr.seeAll,
                          style: TextStyle(color: AppTheme.primaryOf(context), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (radioProvider.isLoading && radioProvider.topVotedStations.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: AppTheme.primaryOf(context)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final station = radioProvider.topVotedStations[i];
                      return StationListTile(station: station);
                    },
                    childCount: radioProvider.topVotedStations.take(15).length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 90),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String count, String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textMutedOf(context))),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context, dynamic station, PlayerProvider player, AppTranslations tr) {
    final isPlaying = player.currentStation?.stationUuid == station.stationUuid && player.isPlaying;
    final flag = CountryFlags.getFlag(station.countryCode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? const [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF064E3B)]
              : const [Color(0xFFE0F2FE), Color(0xFFF0FDF4), Color(0xFFFAF5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.primaryOf(context).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOf(context).withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fiber_manual_record_rounded, color: AppTheme.accentPink, size: 9),
                      const SizedBox(width: 5),
                      Text(
                        tr.featuredLive,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentPink,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  station.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$flag ${station.country.isNotEmpty ? station.country : tr.global} • ${station.formatBadge}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => player.playStation(station),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryCyan, Color(0xFF00B4D8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesQuickSection(BuildContext context, RadioProvider radioProvider, AppTranslations tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.countryCategories,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              TextButton(
                onPressed: () => onNavigateToTab?.call(1), // Tab 1 is Countries
                child: Text(
                  tr.viewAllCountries,
                  style: TextStyle(color: AppTheme.primaryOf(context), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: CountryFlags.popularCountries.length,
            itemBuilder: (ctx, i) {
              final item = CountryFlags.popularCountries[i];
              final code = item['code']!;
              if (code.isEmpty) return const SizedBox.shrink();
              final isSelected = radioProvider.selectedCountryCode.toUpperCase() == code.toUpperCase();
              final flag = CountryFlags.getFlag(code);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  avatar: Text(flag, style: const TextStyle(fontSize: 14)),
                  label: Text(item['name']!),
                  selected: isSelected,
                  selectedColor: AppTheme.secondaryPurple,
                  backgroundColor: AppTheme.cardColorOf(context),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.secondaryPurple : AppTheme.borderOf(context),
                  ),
                  onSelected: (_) => radioProvider.setQuickCountry(code),
                ),
              );
            },
          ),
        ),
        if (radioProvider.currentCountryStations.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 165,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: radioProvider.currentCountryStations.length,
              itemBuilder: (ctx, i) {
                return StationCard(
                  station: radioProvider.currentCountryStations[i],
                  width: 155,
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenreCategories(BuildContext context, SearchFilterProvider searchFilter, AppTranslations tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            tr.exploreByGenre,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: CountryFlags.popularGenres.length,
            itemBuilder: (ctx, i) {
              final genre = CountryFlags.popularGenres[i];
              final tag = genre['tag'] as String;
              final isSelected = (tag.isEmpty && searchFilter.selectedGenre == null) ||
                  (tag.isNotEmpty && searchFilter.selectedGenre?.toLowerCase() == tag.toLowerCase());

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(genre['name'] as String),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryOf(context),
                  backgroundColor: AppTheme.cardColorOf(context),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
                  ),
                  onSelected: (_) {
                    searchFilter.setGenre(tag.isEmpty ? null : tag);
                    onNavigateToTab?.call(2); // Jump to search tab
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
